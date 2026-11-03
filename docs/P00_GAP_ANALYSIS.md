# P00 — Audit of existing repository versus approved design

Source design: [Ta Tu Cái Gì Tiên Google Sheet](https://docs.google.com/spreadsheets/d/1SQO5_lZZMe1EWVFkH4vEQq4fWH44UDUCSH_WuAtpMkM/edit)

## Existing main branch — preserve
- `main` currently runs **Thiên Đạo Viết Lại — Thanh Khê Demo** in Godot 4.6.
- `game.gd` implements **horizontal 2D movement with jump**, 1 map, village NPCs, local save.
- Story/factions currently include Thái Hư, Vạn Pháp, Thiên Đạo, Tán Tu.
- Game title and combat classes **differ** from approved canonical design: Ta Tu Cái Gì Tiên; **2D top-down 8-direction**; **Pháp Tu / Thể Tu / Binh Tu**.
- Existing assets include high-resolution concept-art-derived sprites/background; a production tilemap and 8-direction animations remain to be made.
- Existing `README.md` documents offline single-player proof of concept. No claim of finished MMORPG.

## Approach
**Do not replace or break main.** Build data pipeline and new top-down architecture on `p00/topdown-data-foundation`, then verify with Godot on Windows before merging. The old save (`user://thanh_khe_demo.json`) must never be overwritten by the new save format.

## P00 acceptance criteria
1. Design snapshot contains 19 original content tabs with header metadata and row data.
2. Python standard-library validator reports unique canonical IDs and zone→map references.
3. Godot top-down sandbox opens and can move 8 directions; no dependency on the old side-scrolling scene.
4. Versioned local save with separate path, data errors handled; clean import/run verified on actual Godot.
5. Windows artifact build and smoke test on target machine, evidence recorded before P00 gate passes.

## Known data-debt requiring explicit review
- Some equipment `Công thức liên kết` uses aliases such as `CT-REN-Phàm` rather than actual `CT-001` style IDs. Do not silently interpret them as valid formula references.
- Design uses a template beginner village in each châu but the first prototype must use MAP-001 Thanh Vân Châu without overwriting ZONE-001 Thanh Khê Thành.
- Map-scale illustrations cannot substitute for proper tiles, collision, nav, sprites and runtime scene assets.

## Status
P00: **in progress**. Technical files on this branch are scaffolding; runtime/Godot Windows verification remains outstanding.
