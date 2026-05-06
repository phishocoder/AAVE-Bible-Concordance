#!/usr/bin/env python3
"""
Classify AAVE Bible verse tone/register for internal content audit.

This is intentionally rule-based and does not call external APIs. It reads the
bundled AAVE scripture JSON, writes a per-verse classification JSON file, and
generates a Markdown summary for editorial review.
"""

from __future__ import annotations

import argparse
import json
import re
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


TONES = ("SOLEMN", "NARRATIVE", "DIALOGUE", "TEACHING", "POETIC", "WISDOM", "PROPHECY")

POETIC_BOOKS = {"Psalms", "Song of Solomon", "Lamentations"}
WISDOM_BOOKS = {"Proverbs", "Ecclesiastes"}
PROPHECY_BOOKS = {
    "Isaiah",
    "Jeremiah",
    "Ezekiel",
    "Daniel",
    "Hosea",
    "Joel",
    "Amos",
    "Obadiah",
    "Jonah",
    "Micah",
    "Nahum",
    "Habakkuk",
    "Zephaniah",
    "Haggai",
    "Zechariah",
    "Malachi",
}
LAW_BOOKS = {"Exodus", "Leviticus", "Numbers", "Deuteronomy"}
GOSPELS = {"Matthew", "Mark", "Luke", "John"}
EPISTLES = {
    "Romans",
    "1 Corinthians",
    "2 Corinthians",
    "Galatians",
    "Ephesians",
    "Philippians",
    "Colossians",
    "1 Thessalonians",
    "2 Thessalonians",
    "1 Timothy",
    "2 Timothy",
    "Titus",
    "Philemon",
    "Hebrews",
    "James",
    "1 Peter",
    "2 Peter",
    "1 John",
    "2 John",
    "3 John",
    "Jude",
}

PROPHECY_TERMS = re.compile(
    r"\b("
    r"says the lord|declares the lord|lord says|day of the lord|in that day|"
    r"behold|woe to|judg(?:e|ment)|wrath|restore|restoration|exile|remnant|"
    r"oracle|vision|prophet|prophes|nations? will|shall come|will come to pass"
    r")\b",
    re.IGNORECASE,
)
SOLEMN_TERMS = re.compile(
    r"\b("
    r"covenant|command(?:ment)?|statutes?|law|holy|sin|curse|curses|bless(?:ed|ing)?|"
    r"blood|sacrifice|altar|temple|wrath|judg(?:e|ment)|repent|righteous|wicked|"
    r"lord your god|i am the lord|fear the lord|kingdom of god|eternal life"
    r")\b",
    re.IGNORECASE,
)
TEACHING_TERMS = re.compile(
    r"\b("
    r"therefore|because|for this reason|so then|remember|understand|learn|teach|"
    r"believe|faith|grace|truth|doctrine|wisdom|parable|kingdom|repent|"
    r"blessed are|you have heard|i tell you|truly|for real"
    r")\b",
    re.IGNORECASE,
)
WISDOM_TERMS = re.compile(
    r"\b("
    r"wise|wisdom|fool|foolish|knowledge|understanding|instruction|discipline|"
    r"better is|fear of the lord|heart|tongue|path|listen|my son|teacher"
    r")\b",
    re.IGNORECASE,
)
POETIC_TERMS = re.compile(
    r"\b("
    r"praise|sing|song|psalm|selah|my soul|heart|tears|cry out|deliver me|"
    r"refuge|shepherd|mercy|steadfast|love endures|worship"
    r")\b",
    re.IGNORECASE,
)
NARRATIVE_TERMS = re.compile(
    r"\b("
    r"then|after|before|when|while|next day|went|came|saw|heard|took|made|"
    r"brought|called|sent|returned|rose|walked|entered|left|arrived"
    r")\b",
    re.IGNORECASE,
)
HUMAN_DIALOGUE_TERMS = re.compile(
    r"\b("
    r"said|asked|answered|replied|told|called out|shouted|cried out|responded"
    r")\b",
    re.IGNORECASE,
)
DIVINE_SPEAKER_TERMS = re.compile(
    r"\b("
    r"god said|lord said|lord told|lord spoke|says the lord|declares the lord|"
    r"i am the lord|this is what the lord"
    r")\b",
    re.IGNORECASE,
)
JESUS_TEACHING_TERMS = re.compile(
    r"\b("
    r"jesus said|jesus answered|jesus told|jesus replied|jesus taught|"
    r"he said to them|he told them|truly|for real,? i'?m tellin|"
    r"kingdom of (god|heaven)|blessed are"
    r")\b",
    re.IGNORECASE,
)


def load_json_safely(path: Path) -> tuple[dict[str, Any] | None, str | None]:
    raw = path.read_text(encoding="utf-8")
    try:
        return json.loads(raw), None
    except json.JSONDecodeError as error:
        # Production content is not modified. This only lets audit tooling survive
        # common JSON export issues like trailing commas.
        sanitized = re.sub(r",\s*([}\]])", r"\1", raw)
        try:
            return json.loads(sanitized), f"{error}; parsed with in-memory trailing-comma cleanup"
        except json.JSONDecodeError as sanitized_error:
            return None, f"{error}; sanitized parse failed: {sanitized_error}"


def iter_verses(data: dict[str, Any]) -> list[tuple[str, str, str]]:
    verses: list[tuple[str, str, str]] = []
    for chapter, chapter_data in data.items():
        if not isinstance(chapter_data, dict):
            continue
        for verse, text in chapter_data.items():
            if isinstance(text, str):
                verses.append((str(chapter), str(verse), text))
    return sorted(verses, key=lambda item: (safe_int(item[0]), safe_int(item[1]), item[0], item[1]))


def safe_int(value: str) -> int:
    try:
        return int(value)
    except ValueError:
        return 10**9


def book_name_from_path(path: Path) -> str:
    return path.name.removesuffix("_AAVE.json")


def has_direct_quote(text: str) -> bool:
    return '"' in text or "'" in text and HUMAN_DIALOGUE_TERMS.search(text) is not None


def score_tones(book: str, chapter: str, verse: str, text: str) -> tuple[Counter[str], list[str]]:
    normalized = " ".join(text.split())
    scores: Counter[str] = Counter()
    reasons: list[str] = []

    if book in POETIC_BOOKS:
        scores["POETIC"] += 5
        reasons.append("poetic book")
    if book in WISDOM_BOOKS:
        scores["WISDOM"] += 6
        reasons.append("wisdom book")
    if book in PROPHECY_BOOKS:
        scores["PROPHECY"] += 3
        reasons.append("prophetic book")
    if book in LAW_BOOKS:
        scores["SOLEMN"] += 2
        reasons.append("law/covenant book")
    if book in EPISTLES:
        scores["TEACHING"] += 3
        reasons.append("epistle instruction")

    if DIVINE_SPEAKER_TERMS.search(normalized):
        scores["PROPHECY" if book in PROPHECY_BOOKS else "SOLEMN"] += 6
        reasons.append("direct divine speech")
    if PROPHECY_TERMS.search(normalized):
        scores["PROPHECY"] += 4
        reasons.append("prophetic/judgment/restoration language")
    if SOLEMN_TERMS.search(normalized):
        scores["SOLEMN"] += 4
        reasons.append("law/covenant/judgment language")
    if WISDOM_TERMS.search(normalized):
        scores["WISDOM"] += 4
        reasons.append("wisdom/instruction language")
    if POETIC_TERMS.search(normalized):
        scores["POETIC"] += 3
        reasons.append("prayer/song imagery")
    if JESUS_TEACHING_TERMS.search(normalized):
        scores["TEACHING"] += 5
        reasons.append("Jesus teaching marker")
        if SOLEMN_TERMS.search(normalized) or PROPHECY_TERMS.search(normalized):
            scores["SOLEMN"] += 2
            reasons.append("weighty Jesus saying")
    elif book in GOSPELS and TEACHING_TERMS.search(normalized):
        scores["TEACHING"] += 3
        reasons.append("gospel teaching language")
    elif TEACHING_TERMS.search(normalized):
        scores["TEACHING"] += 2
        reasons.append("instruction/doctrine language")

    if has_direct_quote(normalized) and HUMAN_DIALOGUE_TERMS.search(normalized):
        if not DIVINE_SPEAKER_TERMS.search(normalized):
            scores["DIALOGUE"] += 4
            reasons.append("direct human conversation")

    if NARRATIVE_TERMS.search(normalized):
        scores["NARRATIVE"] += 2
        reasons.append("story movement")

    if not scores:
        scores["NARRATIVE"] += 1
        reasons.append("fallback")

    # Protect obvious book-level registers from weak incidental matches.
    if book in POETIC_BOOKS and scores["POETIC"] >= 5:
        scores["POETIC"] += 1
    if book in WISDOM_BOOKS and scores["WISDOM"] >= 6:
        scores["WISDOM"] += 1

    return scores, reasons


def classify_verse(book: str, chapter: str, verse: str, text: str) -> dict[str, Any]:
    scores, reasons = score_tones(book, chapter, verse, text)
    ranked = scores.most_common()
    tone = ranked[0][0]
    top_score = ranked[0][1]
    runner_up = ranked[1][1] if len(ranked) > 1 else 0
    uncertain = top_score <= 1 or (top_score < 5 and top_score - runner_up <= 1)

    result: dict[str, Any] = {
        "tone": tone,
        "text": text,
    }
    if uncertain:
        result["uncertain"] = True
    return result


def density_rows(classifications: dict[str, Any], target_tones: set[str]) -> list[tuple[str, int, int, float]]:
    rows: list[tuple[str, int, int, float]] = []
    for book, chapters in classifications.items():
        total = 0
        matching = 0
        for verses in chapters.values():
            for item in verses.values():
                total += 1
                if item["tone"] in target_tones:
                    matching += 1
        density = matching / total if total else 0
        rows.append((book, matching, total, density))
    return sorted(rows, key=lambda row: (-row[3], -row[1], row[0]))


def write_summary(
    summary_path: Path,
    total: int,
    tone_counts: Counter[str],
    classifications: dict[str, Any],
    uncertain_refs: list[tuple[str, str, str, str, str]],
    parse_warnings: list[tuple[str, str]],
) -> None:
    solemn_rows = density_rows(classifications, {"SOLEMN", "PROPHECY"})[:15]
    prophecy_rows = density_rows(classifications, {"PROPHECY"})[:15]

    lines: list[str] = [
        "# Verse Tone Classification Summary",
        "",
        "Generated by `Scripts/classify_verse_tone.py`.",
        "",
        "## Totals",
        "",
        f"- Total verses classified: {total}",
        f"- Uncertain classifications: {len(uncertain_refs)}",
        "",
        "## Count By Tone",
        "",
        "| Tone | Count |",
        "|---|---:|",
    ]
    for tone in TONES:
        lines.append(f"| {tone} | {tone_counts.get(tone, 0)} |")

    if parse_warnings:
        lines.extend(["", "## Parse Warnings", ""])
        for path, warning in parse_warnings:
            lines.append(f"- `{path}`: {warning}")

    lines.extend(
        [
            "",
            "## Top Books By SOLEMN / PROPHECY Density",
            "",
            "| Rank | Book | SOLEMN+PROPHECY verses | Total verses | Density |",
            "|---:|---|---:|---:|---:|",
        ]
    )
    for index, (book, matching, book_total, density) in enumerate(solemn_rows, 1):
        lines.append(f"| {index} | {book} | {matching} | {book_total} | {density:.1%} |")

    lines.extend(
        [
            "",
            "## Top Books By PROPHECY Density",
            "",
            "| Rank | Book | PROPHECY verses | Total verses | Density |",
            "|---:|---|---:|---:|---:|",
        ]
    )
    for index, (book, matching, book_total, density) in enumerate(prophecy_rows, 1):
        lines.append(f"| {index} | {book} | {matching} | {book_total} | {density:.1%} |")

    lines.extend(["", "## Uncertain Classifications", ""])
    if uncertain_refs:
        lines.extend(
            [
                "| Reference | Tone | Text |",
                "|---|---|---|",
            ]
        )
        for book, chapter, verse, tone, text in uncertain_refs[:250]:
            reference = f"{book} {chapter}:{verse}"
            cleaned = " ".join(text.split()).replace("|", "\\|")
            if len(cleaned) > 220:
                cleaned = cleaned[:219].rstrip() + "..."
            lines.append(f"| {reference} | {tone} | {cleaned} |")
        if len(uncertain_refs) > 250:
            lines.append(f"")
            lines.append(f"_Showing first 250 of {len(uncertain_refs)} uncertain classifications._")
    else:
        lines.append("No uncertain classifications were produced.")

    lines.extend(
        [
            "",
            "## Notes",
            "",
            "- This is a rule-based audit aid, not a theological authority.",
            "- `uncertain: true` means the top rule score was weak or close to another tone.",
            "- Production Bible JSON files are not modified by this script.",
        ]
    )
    summary_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def run(resources_dir: Path, output_dir: Path) -> dict[str, Any]:
    files = sorted(resources_dir.rglob("*_AAVE.json"))
    classifications: dict[str, Any] = {}
    tone_counts: Counter[str] = Counter()
    parse_warnings: list[tuple[str, str]] = []
    uncertain_refs: list[tuple[str, str, str, str, str]] = []
    total = 0

    for path in files:
        book = book_name_from_path(path)
        data, warning = load_json_safely(path)
        if warning:
            parse_warnings.append((str(path), warning))
        if data is None:
            continue

        classifications.setdefault(book, {})
        for chapter, verse, text in iter_verses(data):
            item = classify_verse(book, chapter, verse, text)
            classifications[book].setdefault(chapter, {})[verse] = item
            tone_counts[item["tone"]] += 1
            total += 1
            if item.get("uncertain"):
                uncertain_refs.append((book, chapter, verse, item["tone"], text))

    output_dir.mkdir(parents=True, exist_ok=True)
    output_json = output_dir / "verse-tone-classifications.json"
    output_summary = output_dir / "verse-tone-summary.md"

    output_json.write_text(
        json.dumps(classifications, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    write_summary(output_summary, total, tone_counts, classifications, uncertain_refs, parse_warnings)

    return {
        "files_scanned": len(files),
        "total": total,
        "tone_counts": dict(tone_counts),
        "uncertain": len(uncertain_refs),
        "outputs": [str(output_json), str(output_summary)],
        "parse_warnings": parse_warnings,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Classify AAVE Bible verse tone/register.")
    parser.add_argument("--resources-dir", default="Resources/Books", type=Path)
    parser.add_argument("--output-dir", default="ContentAudit", type=Path)
    args = parser.parse_args()

    result = run(args.resources_dir, args.output_dir)
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
