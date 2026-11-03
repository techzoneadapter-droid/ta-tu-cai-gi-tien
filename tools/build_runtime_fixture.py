#!/usr/bin/env python3
"""Generate topdown_p00 runtime fixture from the canonical snapshot (offline).

After a new snapshot is exported from connected Google Sheets, run:
python tools/validate_design_snapshot.py design_data/sheet_snapshot.json
python tools/build_runtime_fixture.py
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "design_data" / "sheet_snapshot.json"
TARGET = ROOT / "topdown_p00" / "data" / "p00_reference.json"


def records(doc, tab):
    spec = doc["tabs"][tab]
    head = spec["headers"]
    return [dict(zip(head, row)) for row in spec["rows"]]


def generate(doc):
    classes = records(doc, "Hệ phái chiến đấu")
    maps = records(doc, "Bản đồ thế giới")
    npcs = records(doc, "NPC & Vai trò")
    quests = records(doc, "Nhiệm vụ cốt truyện")
    return {
        "source": "Google Sheets canonical snapshot",
        "source_sheet_id": doc["source_spreadsheet_id"],
        "classes": [
            {
                "id": f"CLASS-{i+1:03}",
                "name": row["Hệ phái chính"],
                "range": row["Tầm chiến đấu"],
            }
            for i, row in enumerate(classes)
        ],
        "maps": [{"id": r["Map ID"], "name": r["Châu / Vực / Giới"]} for r in maps[:1]],
        "npcs": [
            {"id": r["NPC ID"], "name": r["Tên NPC"], "role": r["Vai trò chính"]}
            for r in npcs[:3]
        ],
        "quests": [{"id": r["ID"], "name": r["Tên nhiệm vụ"]} for r in quests[:2]],
    }


def main():
    doc = json.loads(SOURCE.read_text(encoding="utf-8"))
    fixture = generate(doc)
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    TARGET.write_text(json.dumps(fixture, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {TARGET.relative_to(ROOT)} with {len(fixture['classes'])} classes, {len(fixture['npcs'])} NPCs")


if __name__ == "__main__":
    main()
