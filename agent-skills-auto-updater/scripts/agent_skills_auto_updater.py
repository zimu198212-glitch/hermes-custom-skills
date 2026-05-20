#!/usr/bin/env python3
"""Check and safely update local Git-backed AI agent skills."""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable, List, Optional


@dataclass
class RepoResult:
    path: str
    name: str
    status: str
    branch: str = ""
    local: str = ""
    upstream: str = ""
    remote: str = ""
    message: str = ""


def config_path() -> Path:
    base = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")).expanduser()
    return base / "agent-skills-auto-updater" / "config.json"


def load_config() -> dict:
    path = config_path()
    if not path.exists():
        return {"auto_prompt": False}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {"auto_prompt": False}
    return data if isinstance(data, dict) else {"auto_prompt": False}


def save_config(data: dict) -> None:
    path = config_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def set_auto_prompt(enabled: bool) -> None:
    data = load_config()
    data["auto_prompt"] = enabled
    save_config(data)


def run_git(repo: Path, args: List[str], timeout: int) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["git", "-C", str(repo)] + args,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=timeout,
    )


def first_line(text: str) -> str:
    return text.strip().splitlines()[0] if text.strip() else ""


def codex_home() -> Path:
    return Path(os.environ.get("CODEX_HOME", Path.home() / ".codex")).expanduser()


def known_roots(agent: str, include_plugin_cache: bool) -> List[Path]:
    home = codex_home()
    user_home = Path.home()
    candidates = {
        "codex": [home / "skills"],
        "claude": [user_home / ".claude" / "skills"],
        "cursor": [user_home / ".cursor" / "skills", user_home / ".cursor" / "skills-cursor"],
        "gemini": [user_home / ".gemini" / "skills"],
        "opencode": [user_home / ".opencode" / "skills"],
        "ai-skills": [user_home / "ai-skills"],
        "hermes": [user_home / ".hermes" / "skills"],
    }
    roots = []
    if agent == "all":
        roots = list(candidates.values())
    elif agent in candidates:
        roots = candidates[agent]
    if include_plugin_cache:
        roots.append(home / "plugins" / "cache")
    return [r.expanduser() for r in roots]


def discover_repos(roots: List[Path], include_system: bool) -> Iterable[Path]:
    for root in roots:
        root = Path(root).expanduser()
        if not root.exists():
            continue
        for item in root.iterdir():
            if item.is_dir() and (include_system or not item.name.startswith(".")):
                git_dir = item / ".git"
                if git_dir.exists():
                    yield item


def get_repo_state(repo: Path, timeout: int) -> tuple[str, str, str, str]:
    try:
        # Check remote exists before attempting fetch
        remote_result = run_git(repo, ["remote", "-v"], 5)
        has_remote = bool(remote_result.stdout.strip())

        if has_remote:
            fetch_result = run_git(repo, ["fetch"], timeout)
            fetch_err = fetch_result.stderr.strip()
        else:
            fetch_err = "(no remote)"

        branch_result = run_git(repo, ["branch", "--show-current"], timeout)
        branch = branch_result.stdout.strip()

        rev_result = run_git(repo, ["rev-parse", "HEAD"], timeout)
        local = rev_result.stdout.strip()[:8]

        try:
            remote_rev = run_git(repo, ["rev-parse", "@{u}"], timeout)
            upstream = remote_rev.stdout.strip()[:8]
        except Exception:
            upstream = ""

        return branch, local, upstream, fetch_err
    except Exception as e:
        return "", "", "", str(e)


def process_repo(repo: Path, apply: bool, timeout: int) -> RepoResult:
    branch, local, upstream, fetch_err = get_repo_state(repo, timeout)

    try:
        status_result = run_git(repo, ["status", "--porcelain"], timeout)
        is_dirty = bool(status_result.stdout.strip())
    except Exception:
        is_dirty = True

    if is_dirty:
        return RepoResult(
            path=str(repo), name=repo.name, status="skipped (dirty)",
            branch=branch, local=local, upstream=upstream,
            message="Local changes — skipping"
        )

    if not upstream:
        return RepoResult(
            path=str(repo), name=repo.name, status="skipped (no upstream)",
            branch=branch, local=local, upstream=upstream,
            message="No upstream tracking branch"
        )

    if local == upstream:
        return RepoResult(
            path=str(repo), name=repo.name, status="already current",
            branch=branch, local=local, upstream=upstream
        )

    if apply:
        try:
            ff_result = run_git(repo, ["merge", "--ff-only"], timeout)
            if ff_result.returncode == 0:
                new_rev = run_git(repo, ["rev-parse", "--short", "HEAD"], timeout).stdout.strip()
                return RepoResult(
                    path=str(repo), name=repo.name, status="updated",
                    branch=branch, local=new_rev, upstream=new_rev
                )
            else:
                return RepoResult(
                    path=str(repo), name=repo.name, status="failed",
                    branch=branch, local=local, upstream=upstream,
                    message=f"FF merge failed: {ff_result.stderr}"
                )
        except Exception as e:
            return RepoResult(
                path=str(repo), name=repo.name, status="failed",
                branch=branch, local=local, upstream=upstream,
                message=str(e)
            )
    else:
        return RepoResult(
            path=str(repo), name=repo.name, status="pending",
            branch=branch, local=local, upstream=upstream
        )


def run_update(args: argparse.Namespace) -> int:
    roots = args.root if args.root else known_roots(args.agent, args.include_plugin_cache)
    repos = list(discover_repos(roots, args.include_system))
    results = [process_repo(repo, apply=args.apply, timeout=args.timeout) for repo in repos]

    if args.json:
        print(json.dumps([asdict(r) for r in results], indent=2))
        return 0

    # Pretty table
    updated = [r for r in results if r.status == "updated"]
    current = [r for r in results if r.status == "already current"]
    pending = [r for r in results if r.status == "pending"]
    skipped = [r for r in results if "skipped" in r.status]
    failed = [r for r in results if r.status == "failed"]

    print(f"\n{'='*60}")
    print(f"  Agent Skills Auto-Updater — {len(repos)} repos scanned")
    print(f"{'='*60}\n")

    for r in results:
        icon = {"updated": "✅", "already current": "✅", "pending": "🔼",
                "skipped (dirty)": "⏭️", "skipped (no upstream)": "⏭️", "failed": "❌"}.get(r.status, "❓")
        print(f"  {icon} [{r.status}] {r.name}")
        if r.branch:
            print(f"     branch={r.branch}  local={r.local}  upstream={r.upstream}")
        if r.message:
            print(f"     {r.message}")

    print(f"\n  Summary: {len(updated)} updated | {len(current)} current | "
          f"{len(pending)} pending | {len(skipped)} skipped | {len(failed)} failed\n")

    return 0 if not failed else 1


def run_prompt(args: argparse.Namespace) -> int:
    data = load_config()
    if not data.get("auto_prompt"):
        print("Auto-prompt is not enabled. Run with --enable-auto-prompt first.")
        return 1
    print("Auto-prompt mode is enabled.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Check and update Git-backed agent skills")
    sub = parser.add_subparsers(dest="command", required=True)

    mode = sub.add_parser("update", help="Update mode")
    mode.add_argument("--check", action="store_true", help="check only; do not update")
    mode.add_argument("--apply", action="store_true", help="apply safe fast-forward updates")
    mode.add_argument("--agent", help="known local skill roots: codex, claude, cursor, gemini, opencode, hermes, all")
    mode.add_argument("--root", nargs="+", help="specific skill root directories to scan")
    mode.add_argument("--include-system", action="store_true", help="include .system skills")
    mode.add_argument("--include-plugin-cache", action="store_true", help="include plugin cache")
    mode.add_argument("--list-roots", action="store_true", help="list selected roots and exit")
    mode.add_argument("--json", action="store_true", help="emit JSON")
    mode.add_argument("--timeout", type=int, default=60, help="per-git-command timeout in seconds")

    auto = sub.add_parser("auto", help="Auto-prompt controls")
    auto.add_argument("--enable", action="store_true")
    auto.add_argument("--disable", action="store_true")
    auto.add_argument("--status", action="store_true")

    args = parser.parse_args()

    if args.command == "update":
        if args.list_roots:
            roots = args.root if args.root else known_roots(args.agent or "all", args.include_plugin_cache)
            for root in roots:
                marker = "exists" if root.expanduser().exists() else "missing"
                print(f"{root.expanduser()} ({marker})")
            return 0
        return run_update(args)

    if args.command == "auto":
        if args.enable:
            set_auto_prompt(True)
            print("Auto-prompt enabled.")
            return 0
        if args.disable:
            set_auto_prompt(False)
            print("Auto-prompt disabled.")
            return 0
        if args.status:
            data = load_config()
            print(f"auto_prompt: {data.get('auto_prompt', False)}")
            return 0
        return run_prompt(args)

    return 0


if __name__ == "__main__":
    sys.exit(main())
