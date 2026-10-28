# Thiên Đạo Viết Lại — Thanh Khê Demo

**Playable offline demo**, developed as an original 2D cultivation game vertical slice (Godot 4.6, GDScript). This is **not** yet an MMORPG. The current artwork is cut from the original concept illustrations created for this project and packaged into high-resolution painted backgrounds and character sprite transparencies. No source code or artwork from Ngọc Rồng Online or Ninja School is used.

## Windows download

Download **[ThanhKhe_Launcher.exe](https://github.com/techzoneadapter-droid/ta-tu-cai-gi-tien/releases/latest/download/ThanhKhe_Launcher.exe)** or the [ZIP launcher](https://github.com/techzoneadapter-droid/ta-tu-cai-gi-tien/releases/latest). The launcher checks GitHub Releases each time and updates the game automatically. Windows might show a SmartScreen warning for unsigned independent software.

## Controls

| Key | Action |
| --- | --- |
| A/D, arrows | Move |
| Shift | Run |
| Space/W/Up | Jump |
| J / left mouse | Attack |
| E | Talk to closest NPC / collect herb |
| Hold R | Meditate beside the Spirit Tree |
| 1 / 2 / 3 / 4 | Choose Thái Hư / Vạn Pháp / Thiên Đạo / Tán tu when invited |
| I | Toggle character panel |
| H | Help |
| Enter | Start / dismiss dialog |
| Escape | Close menu |

## First quest line

1. Find **Tống tiên sinh** at the village library and speak (`E`).
2. Pick **3 spirit herbs** (`E`) on the path toward the training meadow.
3. Defeat **3 spirit creatures** at the eastern training grounds (`J`).
4. Meditate beside the **Linh Thụ** (`R`, 4 seconds).
5. Return to **Thôn trưởng**, choose one of the three factions or become a **tán tu** (`1`–`4`).

EXP, cultivation, equipment, manuals, pet, body power and combat are prototypes for evaluating game feel, not final balancing. Auto-save is local to Godot's user data directory.

## Edit / Run from source

1. Install **Godot 4.6 standard** from https://godotengine.org/download/archive/4.6-stable/.
2. Extract `visual_assets.zip` in the project root (so `assets/` exists). Open this folder as a Godot project and press F5.
3. If changing Windows exports, use **Project → Export → Windows Desktop** and install Windows templates.

## Project status

- Fully playable **single-player**, single-map proof of concept.
- No servers, sign-up, networking, inventory persistence beyond the small local save, or full skeletal sprite animation yet.
- Source code is intentionally small and data-driven enough for the next iteration.
- Artwork v0.3 uses original Thanh Khê concept art as integrated panorama and hand-painted characters, but requires proper tilemap/animation passes for production.

## Visual assets (v0.3)

`visual_assets.zip` contains the stylized background and transparent character portraits extracted from project-owned concept art; CI extracts it before importing Godot. These are prototype production assets with a matching license to the game project; they are not copied from unrelated games. The gameplay/quests and local save path are unchanged.