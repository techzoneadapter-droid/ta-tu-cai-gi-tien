# Source of Mana — imported upstream source

This branch preserves the existing Thanh Khê offline demo and places the **complete Source of Mana working tree** under `source-of-mana/`.

- Upstream: https://github.com/sourceofmana/sourceofmana
- Original upstream branch: `master`
- Imported by: `.github/workflows/import-source-of-mana.yml`
- The import records the exact upstream commit in `source-of-mana/UPSTREAM_COMMIT.txt`.
- `.git` history is not copied inside the folder; source files, resources, configuration, client and server project files are copied.
- Original upstream `LICENSE.md`, `CC BY-SA 4.0`, and other notices stay intact.

## On Windows

1. Open the `import/source-of-mana` branch or merge it when verified.
2. Clone the repository with GitHub Desktop or `git clone -b import/source-of-mana https://github.com/techzoneadapter-droid/ta-tu-cai-gi-tien.git`.
3. Open `source-of-mana/project.godot` from Godot (match the version in `source-of-mana/versions.cfg`).
4. Edit characters, game mechanics, quests and assets inside `source-of-mana/`. This remains an independent Godot project; the Thanh Khê demo in the repository root remains untouched.

This import does **not** mean Source of Mana's game mechanics or network server were tested on Windows, nor that its graphics may be relicensed. The code uses MIT and upstream art/design includes CC BY-SA 4.0; check original third-party asset credits before redistribution.
