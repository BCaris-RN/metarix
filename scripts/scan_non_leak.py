from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def _decode_hex(value: str) -> str:
    return bytes.fromhex(value).decode("utf-8")


REPO_ROOT = Path(__file__).resolve().parents[1]
POLICY_DOC = REPO_ROOT / "docs" / "repo_provenance_and_non_leak_policy.md"
IGNORED_DIRS = {".git", "build", "dist", "node_modules", ".dart_tool", ".idea", ".vscode"}
TEXT_EXTENSIONS = {
    ".bat",
    ".cmd",
    ".css",
    ".csv",
    ".dart",
    ".gitignore",
    ".gradle",
    ".html",
    ".ini",
    ".js",
    ".json",
    ".kt",
    ".md",
    ".ps1",
    ".py",
    ".sh",
    ".sql",
    ".swift",
    ".toml",
    ".ts",
    ".txt",
    ".xml",
    ".yaml",
    ".yml",
}
SPECIAL_FILENAMES = {
    "Dockerfile",
    "LICENSE",
    "NOTICE",
    "README",
    "README.md",
    "pubspec.lock",
    "pubspec.yaml",
}

FORBIDDEN_TOKENS = [
    _decode_hex("53757072656d615f43"),
    _decode_hex("63705f73757065725f737461636b"),
    _decode_hex("6c65676163795f70686f656e69785f726566"),
    _decode_hex("676f7665726e616e63655f6a6f625f7265676973747279"),
    _decode_hex("706f6c6963795f62756e646c655f6d616e69666573742e6a736f6e"),
]
FORBIDDEN_PATH_SEGMENTS = [
    _decode_hex("5f696e74616b652f"),
    _decode_hex("3867656e7469432f"),
    _decode_hex("53757072656d615f432f"),
    _decode_hex("70686f656e69782f"),
]
SEMANTIC_MARKERS = [
    _decode_hex("3d3d3d20434f4445582053454d414e54494320534e415053484f54203d3d3d"),
    _decode_hex("2d2d2d2053544152542053454d414e5449432046494c453a"),
]


def _should_skip(path: Path) -> bool:
    if any(part in IGNORED_DIRS for part in path.parts):
        return True
    try:
        completed = subprocess.run(
            ["git", "check-ignore", "-q", str(path)],
            cwd=REPO_ROOT,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
        return completed.returncode == 0
    except OSError:
        return False


def _is_text_file(path: Path) -> bool:
    return path.name in SPECIAL_FILENAMES or path.suffix.lower() in TEXT_EXTENSIONS


def _scan_file(path: Path) -> list[tuple[str, str]]:
    hits: list[tuple[str, str]] = []
    if path == POLICY_DOC:
        return hits
    if not _is_text_file(path):
        return hits

    try:
        raw = path.read_bytes()
    except OSError:
        return hits

    if b"\x00" in raw[:4096]:
        return hits

    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        try:
            text = raw.decode("utf-8", errors="ignore")
        except Exception:
            return hits

    lowered = text.casefold()
    for token in FORBIDDEN_TOKENS:
        if token.casefold() in lowered:
            hits.append((str(path), token))

    for marker in SEMANTIC_MARKERS:
        if marker in text:
            hits.append((str(path), marker))

    return hits


def _scan_paths(path: Path) -> list[tuple[str, str]]:
    hits: list[tuple[str, str]] = []
    relative = path.relative_to(REPO_ROOT).as_posix()
    lowered = relative.casefold()
    for segment in FORBIDDEN_PATH_SEGMENTS:
        if segment.casefold() in lowered:
            hits.append((str(path), segment.rstrip("/")))
    return hits


def main() -> int:
    hits: list[tuple[str, str]] = []

    for path in REPO_ROOT.rglob("*"):
        if _should_skip(path):
            continue
        if path.is_dir():
            hits.extend(_scan_paths(path))
            continue
        hits.extend(_scan_paths(path))
        if _is_text_file(path):
            hits.extend(_scan_file(path))

    if not hits:
        print("Non-leak scan passed.")
        return 0

    print("Non-leak scan failed. Forbidden material detected:")
    seen: set[tuple[str, str]] = set()
    for file_path, token in hits:
        key = (file_path, token)
        if key in seen:
            continue
        seen.add(key)
        print(f"{file_path}: {token}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
