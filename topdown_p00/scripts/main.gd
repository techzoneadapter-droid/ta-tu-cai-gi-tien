extends Node2D
## P00 technical preview: independent from the existing Thanh Khe side-scroller.
## No production assets; intentionally simple geometry until P01 art approval.

const SAVE_PATH := "user://ta_tu_cai_gi_tien_p00_v1.json"
const SAVE_VERSION := 1
const SPEED := 235.0
const WORLD_SIZE := Vector2(1800, 1100)

var actor_position := Vector2(640, 450)
var camera: Camera2D
var labels: Dictionary = {}
var status_text := "P00 • 8 huong di chuyen | Shift: chay | F5: luu | F9: tai"
var class_names: Array = []
var map_names: Array = []

func _ready() -> void:
    get_window().title = "Ta Tu Cai Gi Tien - P00 TOP DOWN (technical)"
    camera = Camera2D.new()
    camera.enabled = true
    camera.limit_left = 0
    camera.limit_top = 0
    camera.limit_right = int(WORLD_SIZE.x)
    camera.limit_bottom = int(WORLD_SIZE.y)
    add_child(camera)
    camera.make_current()
    _load_reference_data()
    _load_game()
    set_process(true)

func _load_reference_data() -> void:
    if not FileAccess.file_exists("res://data/p00_reference.json"):
        status_text = "THIEU DU LIEU P00: data/p00_reference.json"
        return
    var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://data/p00_reference.json"))
    if typeof(parsed) != TYPE_DICTIONARY:
        status_text = "LOI DU LIEU P00: JSON khong hop le"
        return
    for entry in parsed.get("classes", []):
        class_names.append(str(entry.get("name", "")))
    for entry in parsed.get("maps", []):
        map_names.append(str(entry.get("name", "")))

func _process(delta: float) -> void:
    var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var speed := SPEED * (1.55 if Input.is_key_pressed(KEY_SHIFT) else 1.0)
    if direction.length_squared() > 0.0:
        actor_position += direction * speed * delta
    actor_position.x = clampf(actor_position.x, 36.0, WORLD_SIZE.x - 36.0)
    actor_position.y = clampf(actor_position.y, 36.0, WORLD_SIZE.y - 36.0)
    camera.position = actor_position
    queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
    if not event.pressed or event.echo:
        return
    if event.keycode == KEY_F5:
        _save_game()
    elif event.keycode == KEY_F9:
        _load_game()

func _save_game() -> void:
    var data := {
        "version": SAVE_VERSION,
        "map_id": "MAP-001",
        "player": {"x": actor_position.x, "y": actor_position.y, "class_id": ""},
        "quest_flags": {},
        "npc_flags": {}
    }
    var handle := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if handle == null:
        status_text = "Khong mo duoc file save"
        return
    handle.store_string(JSON.stringify(data))
    status_text = "Da luu vi tri P00"

func _load_game() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
    if typeof(parsed) != TYPE_DICTIONARY:
        status_text = "Save hong, giu vi tri mac dinh"
        return
    if int(parsed.get("version", -1)) != SAVE_VERSION:
        status_text = "Save sai version, khong tai"
        return
    var player = parsed.get("player", {})
    if typeof(player) != TYPE_DICTIONARY:
        return
    actor_position = Vector2(clampf(float(player.get("x", 640)), 36.0, WORLD_SIZE.x - 36.0), clampf(float(player.get("y", 450)), 36.0, WORLD_SIZE.y - 36.0))
    status_text = "Da tai save P00"

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("#294e41"), true)
    for x in range(0, int(WORLD_SIZE.x), 100):
        draw_line(Vector2(x, 0), Vector2(x, WORLD_SIZE.y), Color("#356052"), 1.0)
    for y in range(0, int(WORLD_SIZE.y), 100):
        draw_line(Vector2(0, y), Vector2(WORLD_SIZE.x, y), Color("#356052"), 1.0)
    draw_rect(Rect2(130, 400, 1510, 105), Color("#a49775"), true)
    draw_rect(Rect2(550, 120, 145, 680), Color("#a49775"), true)
    _building(Rect2(230, 235, 260, 125), "NHA TRUONG LAO")
    _building(Rect2(820, 190, 300, 155), "LO REN")
    _building(Rect2(1160, 570, 280, 170), "DUOC DIEN")
    _building(Rect2(330, 650, 250, 135), "BAI LUYEN")
    draw_circle(Vector2(920, 730), 72, Color("#4c8779"))
    draw_circle(Vector2(920, 730), 40, Color("#85c7bf"))
    draw_circle(actor_position + Vector2(0, 11), 17, Color(0, 0, 0, 0.32))
    draw_circle(actor_position, 17, Color("#e5f3f3"))
    draw_circle(actor_position + Vector2(0, -7), 8, Color("#61b9dc"))
    var text := ThemeDB.fallback_font
    draw_string(text, actor_position + Vector2(-45, -32), "NGUOI CHOI", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
    draw_string(text, actor_position + Vector2(-245, -100), status_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color.WHITE)
    draw_string(text, actor_position + Vector2(-245, -75), "He phai: " + ", ".join(class_names), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#e3eec5"))
    draw_string(text, actor_position + Vector2(-245, -53), "Map: " + (map_names[0] if map_names.size()>0 else "MAP-001"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#e3eec5"))

func _building(area: Rect2, name: String) -> void:
    draw_rect(area.grow(7), Color("#182e29"), true)
    draw_rect(area, Color("#82755f"), true)
    draw_rect(Rect2(area.position.x + 12, area.position.y + 14, area.size.x - 24, area.size.y - 28), Color("#a18d6e"), true)
    draw_string(ThemeDB.fallback_font, area.position + Vector2(20, 40), name, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#222f30"))
