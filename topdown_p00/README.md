# Ta Tu Cai Gi Tien — top-down P00 sandbox

This is a separate Godot 4.x project **inside the existing repository**. The original demo in the repository root remains unchanged.

1. Open `topdown_p00/project.godot` in Godot 4.x.
2. Press F6/F5 to launch main scene.
3. Arrow keys: move in 8 directions; Shift: run; F5: save; F9: load.
4. This is deliberately geometric P00 tech preview, **not** production art or a finished game.

`data/p00_reference.json` is a compact runtime fixture derived from the canonical Google Sheet. Full design snapshot is at `../design_data/sheet_snapshot.json`.

**Current gaps:** no character collision with buildings (world bounds only), no NPC scripts, no animation, no skill combat; Godot runtime execution and Windows export remain to be verified. This does **not** satisfy the P00 completion gate.
