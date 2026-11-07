#!/usr/bin/env python3
"""Audit bundled commentary structure and the reviewed Deuteronomy regressions.

Missing commentary is allowed: the app deliberately supports partial coverage.
Legacy out-of-range references are reported; --strict makes them fail the audit.
This checks structure and specific editorial regressions, not semantic accuracy
of every Bible commentary entry.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def unique_object(pairs: list[tuple[str, object]]) -> dict:
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def read_json(path: Path) -> dict:
    value = json.loads(path.read_text(encoding="utf-8-sig"), object_pairs_hook=unique_object)
    if not isinstance(value, dict):
        raise ValueError("top level must be an object")
    return value


def positive_key(value: str) -> bool:
    return value.isascii() and value.isdecimal() and int(value) > 0 and str(int(value)) == value


def audit(root: Path) -> tuple[list[str], list[str], dict, dict, dict]:
    errors = []
    invalid_references = []
    scriptures = {}
    commentaries = {}
    stats = {"scripture_books": 0, "commentary_files": 0, "entries": 0, "missing": 0}
    for path in sorted((root / "Resources/Books").rglob("*_AAVE.json")):
        try:
            book = path.stem.removesuffix("_AAVE")
            if book in scriptures:
                raise ValueError(f"duplicate scripture book: {book}")
            chapters = read_json(path)
            for chapter, verses in chapters.items():
                if not positive_key(chapter) or not isinstance(verses, dict):
                    raise ValueError(f"invalid chapter key or verse object: {chapter}")
                for verse, text in verses.items():
                    # The reader explicitly supports empty translation placeholders.
                    if not positive_key(verse) or not isinstance(text, str):
                        raise ValueError(f"invalid verse key or non-text scripture: {chapter}:{verse}")
            scriptures[book] = chapters
            stats["scripture_books"] += 1
        except (ValueError, OSError) as error:
            errors.append(f"{path.relative_to(root)}: {error}")
    for path in sorted((root / "Resources/Commentary").rglob("Commentary_*.json")):
        try:
            data = read_json(path)
            stats["commentary_files"] += 1
        except (ValueError, OSError) as error:
            errors.append(f"{path.relative_to(root)}: {error}")
            continue
        for book, chapters in data.items():
            if book in commentaries:
                errors.append(f"{book}: duplicate book across commentary files")
                continue
            if not isinstance(chapters, dict) or book not in scriptures:
                errors.append(f"{book}: unknown book or invalid chapter object")
                continue
            commentaries[book] = chapters
            for chapter, verses in chapters.items():
                if not positive_key(chapter) or not isinstance(verses, dict):
                    errors.append(f"{book} {chapter}: invalid chapter key or verse object")
                    continue
                for verse, text in verses.items():
                    reference = f"{book} {chapter}:{verse}"
                    stats["entries"] += 1
                    if not positive_key(verse) or not isinstance(text, str) or not text.strip():
                        errors.append(f"{reference}: invalid verse key or empty/non-text commentary")
                        continue
                    scripture = scriptures[book].get(chapter, {}).get(verse)
                    if scripture is None:
                        invalid_references.append(reference)
                    elif text.strip() == scripture.strip():
                        errors.append(f"{reference}: commentary duplicates scripture")
    for book, chapters in scriptures.items():
        for chapter, verses in chapters.items():
            stats["missing"] += len(set(verses) - set(commentaries.get(book, {}).get(chapter, {})))
    return errors, invalid_references, scriptures, commentaries, stats


def check_deuteronomy(scriptures: dict, commentaries: dict) -> list[str]:
    errors = []
    chapters = commentaries.get("Deuteronomy", {})
    scripture = scriptures.get("Deuteronomy", {})
    for chapter in ("23", "24", "25", "26", "27"):
        if set(chapters.get(chapter, {})) != set(scripture.get(chapter, {})):
            errors.append(f"Deuteronomy {chapter}: reviewed chapter must match real verse references")

    # These checks distinguish the previously shifted topics from their correct
    # neighbors, without requiring an exact editorial sentence.
    topics = {
        (23, 15): ("slavery", "refuge"),
        (23, 17): ("prostitution",),
        (23, 19): ("interest", "loans"),
        (23, 21): ("vow",),
        (23, 24): ("grapes", "vineyard"),
        (23, 25): ("grain", "sickle"),
        (24, 6): ("millstone",),
        (24, 7): ("kidnapping",),
        (24, 9): ("miriam",),
        (24, 14): ("workers",),
        (24, 15): ("wages", "paid"),
        (24, 16): ("responsible", "crime"),
        (24, 17): ("widow", "foreigners"),
        (24, 18): ("egypt",),
        (24, 19): ("grain",),
        (24, 20): ("olive",),
        (24, 21): ("grape",),
        (24, 22): ("egypt",),
        (25, 4): ("ox",),
        (25, 5): ("levirate", "widow"),
        (25, 6): ("son", "name"),
        (25, 9): ("sandal",),
        (25, 13): ("weights",),
        (25, 18): ("amalek",),
        (26, 6): ("oppression", "labor"),
        (26, 7): ("heard", "cried"),
        (26, 8): ("rescue", "egypt"),
        (26, 12): ("tithe",),
        (27, 8): ("written", "law"),
        (27, 9): ("people",),
        (27, 10): ("obedience",),
        (27, 11): ("ceremony",),
        (27, 15): ("idols",),
        (27, 17): ("boundary", "land"),
        (27, 25): ("bribe",),
        (27, 26): ("law",),
    }
    for (chapter, verse), terms in topics.items():
        text = chapters.get(str(chapter), {}).get(str(verse), "").casefold()
        if not any(term in text for term in terms):
            errors.append(f"Deuteronomy {chapter}:{verse}: missing reviewed verse topic {terms}")
    for verse in (20, 21):
        text = chapters.get("24", {}).get(str(verse), "").casefold()
        if any(term in text for term in ("wage", "fair pay", "workers be paid")):
            errors.append(f"Deuteronomy 24:{verse}: wage commentary returned to harvest verse")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT, help="repository to audit")
    parser.add_argument("--strict", action="store_true", help="fail on legacy out-of-range references too")
    args = parser.parse_args()
    errors, invalid, scriptures, commentaries, stats = audit(args.root)
    errors.extend(check_deuteronomy(scriptures, commentaries))
    print(f"Loaded {stats['scripture_books']} scripture books and {stats['commentary_files']} commentary files.")
    print(f"Audited {stats['entries']} commentary records; {stats['missing']} scripture verses have no commentary (allowed partial coverage).")
    for reference in invalid:
        print(f"LEGACY OUT-OF-RANGE: {reference}")
    for error in errors:
        print(f"ERROR: {error}")
    print(f"Structural errors / focused regression failures: {len(errors)}; out-of-range references: {len(invalid)}.")
    print("This audit does not validate the meaning of every commentary entry.")
    return 1 if errors or (args.strict and invalid) else 0


if __name__ == "__main__":
    sys.exit(main())
