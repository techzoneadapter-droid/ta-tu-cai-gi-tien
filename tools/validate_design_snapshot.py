#!/usr/bin/env python3
"""Validate the canonical Google Sheets design snapshot (Python stdlib only).

Usage: python tools/validate_design_snapshot.py design_data/sheet_snapshot.json
"""
import json
import pathlib
import sys

KEYS = {
    "Cảnh Giới": "STT",
    "Hệ phái chiến đấu": "STT",
    "Bí kíp & Kỹ năng": "STT",
    "Chi tiết chiêu thức": "Mã chiêu",
    "Kho vật phẩm": "ID",
    "Trang bị & Bộ đồ": "ID",
    "Nguyên liệu rèn đan": "ID",
    "Công thức & Nâng cấp": "ID",
    "Bảo vật & Linh bảo": "ID",
    "Nhiệm vụ cốt truyện": "ID",
    "NPC & Vai trò": "NPC ID",
    "Bản đồ thế giới": "Map ID",
    "Khu vực & Điểm đến": "ID",
}


def validate(document):
    errors, warnings = [], []
    tabs = document.get("tabs", {})
    if not isinstance(tabs, dict):
        return ["tabs must be a dictionary"], warnings
    for tab_name, spec in tabs.items():
        head, rows = spec.get("headers", []), spec.get("rows", [])
        if not head:
            errors.append(f"{tab_name}: missing headers")
            continue
        if len(head) != len(set(head)):
            errors.append(f"{tab_name}: duplicate headers")
        if any(len(r) > len(head) for r in rows):
            errors.append(f"{tab_name}: row wider than header")
        key = KEYS.get(tab_name)
        if key is None:
            continue
        if key not in head:
            errors.append(f"{tab_name}: missing key column {key}")
            continue
        idx = head.index(key)
        seen = set()
        for nr, row in enumerate(rows, start=2):
            value = str(row[idx]).strip() if idx < len(row) else ""
            if not value:
                errors.append(f"{tab_name}!row{nr}: empty {key}")
            elif value in seen:
                errors.append(f"{tab_name}!row{nr}: duplicate {key} {value}")
            seen.add(value)
    maps = tabs.get("Bản đồ thế giới", {})
    zones = tabs.get("Khu vực & Điểm đến", {})
    if maps and zones:
        map_h = maps["headers"]
        zone_h = zones["headers"]
        if "Map ID" in map_h and "Map cha" in zone_h:
            valid = {str(r[map_h.index("Map ID")]) for r in maps["rows"] if len(r) > map_h.index("Map ID")}
            for n, r in enumerate(zones["rows"], 2):
                j = zone_h.index("Map cha")
                if j >= len(r) or str(r[j]) not in valid:
                    errors.append(f"Khu vực & Điểm đến!row{n}: missing parent map")
    equipment = tabs.get("Trang bị & Bộ đồ", {})
    recipes = tabs.get("Công thức & Nâng cấp", {})
    if equipment and recipes:
        eh = equipment["headers"]
        rh = recipes["headers"]
        if "Công thức liên kết" in eh and "ID" in rh:
            known = {str(r[rh.index("ID")]) for r in recipes["rows"] if len(r)>rh.index("ID")}
            bad = sorted({str(r[eh.index("Công thức liên kết")]) for r in equipment["rows"] if len(r)>eh.index("Công thức liên kết") and r[eh.index("Công thức liên kết")] and str(r[eh.index("Công thức liên kết")]) not in known})
            if bad:
                warnings.append("Equipment recipe references need mapping: " + ", ".join(bad[:12]) + (" ..." if len(bad)>12 else ""))
    return errors, warnings


def main():
    path = pathlib.Path(sys.argv[1]) if len(sys.argv)>1 else pathlib.Path("design_data/sheet_snapshot.json")
    doc = json.loads(path.read_text(encoding="utf-8"))
    errors, warnings = validate(doc)
    for msg in warnings: print("WARNING:", msg)
    for msg in errors: print("ERROR:", msg)
    count = sum(len(t.get("rows", [])) for t in doc.get("tabs", {}).values())
    print(f"Validated {len(doc.get('tabs', {}))} tabs, {count} data rows: {len(errors)} errors, {len(warnings)} warnings")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
