#!/usr/bin/env python3
"""Offline command/API scanner for unpacked GEM2 / MoWAS2 / Cold War / NEU scripts.

Usage:
    python tools/scan_bot_commands.py D:\\GPT_NEU
    python tools/scan_bot_commands.py D:\\COLDWAR-MOD- --out command_scan

It does not execute game code. It only extracts script-visible API call names and locations.
"""

from __future__ import annotations

import argparse
import json
import re
from collections import Counter
from pathlib import Path

EXTS = {".lua", ".inc", ".script", ".set", ".mi"}

PATTERNS = [
    ("BotApi.Commands", re.compile(r"BotApi\s*\.\s*Commands\s*:\s*([A-Za-z_][A-Za-z0-9_]*)")),
    ("BotApi.Scene", re.compile(r"BotApi\s*\.\s*Scene\s*:\s*([A-Za-z_][A-Za-z0-9_]*)")),
    ("BotApi.Instance", re.compile(r"BotApi\s*\.\s*Instance\s*:\s*([A-Za-z_][A-Za-z0-9_]*)")),
    ("BotApi", re.compile(r"BotApi\s*:\s*([A-Za-z_][A-Za-z0-9_]*)")),
    ("NEU bridge", re.compile(r"\b(NEU_Engine[A-Za-z0-9_]*)\s*\(")),
    ("md/global", re.compile(r"\b(md[A-Z_][A-Za-z0-9_]*)\s*\(")),
    ("Squad/global", re.compile(r"\b(Squad[A-Z_][A-Za-z0-9_]*)\s*\(")),
    ("Actor/global", re.compile(r"\b(Actor[A-Z_][A-Za-z0-9_]*)\s*\(")),
    ("Entity/global", re.compile(r"\b(Entity[A-Z_][A-Za-z0-9_]*)\s*\(")),
    ("Vehicle/global", re.compile(r"\b(Vehicle[A-Z_][A-Za-z0-9_]*)\s*\(")),
]

INTERESTING_GENERIC = re.compile(
    r"\b([A-Za-z_][A-Za-z0-9_]*(?:Move|Order|Attack|Capture|Spawn|Target|Waypoint|"
    r"Formation|Stance|Enter|Exit|Load|Unload|Fire|Stop|Follow|Patrol|Land|Crew)"
    r"[A-Za-z0-9_]*)\s*\("
)


def iter_files(root: Path):
    for p in root.rglob("*"):
        if p.is_file() and p.suffix.lower() in EXTS:
            yield p


def read_text(path: Path) -> str | None:
    data = path.read_bytes()
    for enc in ("utf-8-sig", "utf-8", "cp1251", "latin-1"):
        try:
            return data.decode(enc)
        except UnicodeDecodeError:
            pass
    return None


def scan(root: Path):
    results = []
    files_scanned = 0
    for path in iter_files(root):
        text = read_text(path)
        if text is None:
            continue
        files_scanned += 1
        rel = str(path.relative_to(root)).replace("\\", "/")
        lines = text.splitlines()
        for line_no, line in enumerate(lines, 1):
            for owner, rx in PATTERNS:
                for m in rx.finditer(line):
                    results.append({
                        "owner": owner,
                        "name": m.group(1),
                        "file": rel,
                        "line": line_no,
                        "text": line.strip()[:400],
                    })
            for m in INTERESTING_GENERIC.finditer(line):
                name = m.group(1)
                if not any(x["name"] == name and x["file"] == rel and x["line"] == line_no for x in results[-16:]):
                    results.append({
                        "owner": "interesting/global",
                        "name": name,
                        "file": rel,
                        "line": line_no,
                        "text": line.strip()[:400],
                    })
    return files_scanned, results


def write_reports(root: Path, out_base: Path, files_scanned: int, results: list[dict]):
    grouped: dict[str, dict[str, list[dict]]] = {}
    for r in results:
        grouped.setdefault(r["owner"], {}).setdefault(r["name"], []).append(r)

    payload = {
        "root": str(root),
        "files_scanned": files_scanned,
        "matches": len(results),
        "unique_names": sum(len(v) for v in grouped.values()),
        "groups": grouped,
    }
    json_path = out_base.with_suffix(".json")
    txt_path = out_base.with_suffix(".txt")
    json_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")

    counts = Counter((r["owner"], r["name"]) for r in results)
    with txt_path.open("w", encoding="utf-8") as f:
        f.write("GEM2 / MoWAS2 command scan\n")
        f.write(f"Root: {root}\nFiles scanned: {files_scanned}\nMatches: {len(results)}\n\n")
        for owner in sorted(grouped):
            f.write(f"=== {owner} ===\n")
            for name in sorted(grouped[owner]):
                f.write(f"{name}  occurrences={counts[(owner, name)]}\n")
                for hit in grouped[owner][name][:20]:
                    f.write(f"  {hit['file']}:{hit['line']}  {hit['text']}\n")
                if len(grouped[owner][name]) > 20:
                    f.write(f"  ... +{len(grouped[owner][name]) - 20} more\n")
            f.write("\n")

    return json_path, txt_path


def main() -> int:
    ap = argparse.ArgumentParser(description="Scan unpacked GEM2/MoWAS2 scripts for bot/API command calls")
    ap.add_argument("root", type=Path, help="Root folder to scan")
    ap.add_argument("--out", type=Path, default=Path("gem2_command_scan"), help="Output base name")
    args = ap.parse_args()

    root = args.root.resolve()
    if not root.is_dir():
        raise SystemExit(f"Folder not found: {root}")

    files_scanned, results = scan(root)
    json_path, txt_path = write_reports(root, args.out, files_scanned, results)
    print(f"Scanned files: {files_scanned}")
    print(f"Matches: {len(results)}")
    print(f"JSON: {json_path.resolve()}")
    print(f"TXT : {txt_path.resolve()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
