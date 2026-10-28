extends Node2D

const WIDTH := 1280
const HEIGHT := 720
const LAND_END := 3520.0
const FLOOR_Y := 573.0
const SAVE_PATH := "user://thanh_khe_demo.json"
const GOLD := Color("ecd49b")
const INK := Color("1e2732")
const CREAM := Color("fff1d2")
const BG_ART: Texture2D = preload("res://assets/thanh_khe_panorama.jpg")
const HERO_ART: Texture2D = preload("res://assets/player.png")
const GIRL_ART: Texture2D = preload("res://assets/female.png")
const SCHOLAR_ART: Texture2D = preload("res://assets/white_male.png")
const VILLAGER_ART: Texture2D = preload("res://assets/white_female.png")
const SMITH_ART: Texture2D = preload("res://assets/purple_male.png")
const TRAINER_ART: Texture2D = preload("res://assets/purple_female.png")
const HERO_PORTRAIT: Texture2D = preload("res://assets/portrait.jpg")
const GOLD_LIGHT := Color("f4d9a5")


var px := 390.0
var py := FLOOR_Y
var vy := 0.0
var face := 1
var scroll_x := 0.0
var walk_phase := 0.0
var world_time := 0.0
var attack_timer := 0.0
var attack_anim := 0.0
var hurt_timer := 0.0
var hp := 220
var max_hp := 220
var mp := 120
var exp_points := 0
var money := 120
var stage := 0
var faction := "Chưa chọn"
var collected := 0
var defeated := 0
var meditation := 0.0
var page := ""
var dialog := ""
var dialog_timer := 0.0
var intro := true
var hint := ""
var sparkles: Array = []
var herbs := [{"x": 1050.0, "taken": false}, {"x": 1740.0, "taken": false}, {"x": 2080.0, "taken": false}]
var monsters := [{"x": 2520.0, "hp": 85, "alive": true, "cool": 0.0}, {"x": 2770.0, "hp": 85, "alive": true, "cool": 0.0}, {"x": 3050.0, "hp": 85, "alive": true, "cool": 0.0}]
var npcs := [{"x": 490.0, "name": "Tống tiên sinh", "role": "Thư quán", "color": Color("e1e3df")}, {"x": 870.0, "name": "Thôn trưởng", "role": "Nhiệm vụ", "color": Color("d5bba4")}, {"x": 1210.0, "name": "A Ninh", "role": "Dân làng", "color": Color("eea5af")}, {"x": 1920.0, "name": "Thợ rèn", "role": "Cửa hàng", "color": Color("b2b7c7")}, {"x": 2300.0, "name": "Võ sư", "role": "Tập luyện", "color": Color("b4a4cd")}]

func _ready() -> void:
	get_window().title = "Thiên Đạo Viết Lại | Thôn Thanh Khê — DEMO"
	load_game()
	set_process(true)

func notify(message: String, seconds: float = 5.5) -> void:
	dialog = message
	dialog_timer = seconds

func earn_xp(value: int) -> void:
	exp_points += value

func save_game() -> void:
	var data := {"x": px, "stage": stage, "collected": collected, "defeated": defeated, "faction": faction, "exp": exp_points, "money": money, "herbs": [herbs[0]["taken"], herbs[1]["taken"], herbs[2]["taken"]], "monsters": [monsters[0]["alive"], monsters[1]["alive"], monsters[2]["alive"]]}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return
	px = float(data.get("x", px))
	stage = int(data.get("stage", stage))
	collected = int(data.get("collected", 0))
	defeated = int(data.get("defeated", 0))
	faction = str(data.get("faction", faction))
	exp_points = int(data.get("exp", 0))
	money = int(data.get("money", money))
	var saved_herbs = data.get("herbs", [])
	for i in range(min(3, saved_herbs.size())):
		herbs[i]["taken"] = saved_herbs[i]
	var saved_monsters = data.get("monsters", [])
	for i in range(min(3, saved_monsters.size())):
		monsters[i]["alive"] = saved_monsters[i]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER:
			if intro:
				intro = false
			elif dialog_timer > 0.0:
				dialog_timer = 0.0
		if intro:
			return
		match event.keycode:
			KEY_E: interact()
			KEY_J: attack()
			KEY_H: page = "" if page == "help" else "help"
			KEY_I: page = "" if page == "character" else "character"
			KEY_ESCAPE: page = ""
			KEY_1, KEY_2, KEY_3, KEY_4:
				if stage == 4 and abs(px - 870.0) < 160.0:
					var paths := ["Thái Hư Kiếm Tông", "Vạn Pháp Cung", "Thiên Đạo Viện", "Tán tu"]
					faction = paths[event.keycode - KEY_1]
					stage = 5
					earn_xp(70)
					money += 200
					notify("Đã chọn: %s. Bạn hoàn thành tuyến tân thủ Thanh Khê! +70 EXP, +200 linh thạch.\nĐây là giới hạn nội dung demo 0.1; hành trình kế tiếp sẽ mở rộng theo thiết kế." % faction, 12.0)
					save_game()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not intro:
		attack()

func _process(delta: float) -> void:
	world_time += delta
	dialog_timer = maxf(0.0, dialog_timer - delta)
	attack_timer = maxf(0.0, attack_timer - delta)
	attack_anim = maxf(0.0, attack_anim - delta)
	hurt_timer = maxf(0.0, hurt_timer - delta)
	if not intro and page == "":
		var axis := 0.0
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): axis -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): axis += 1.0
		var pace := 310.0 if Input.is_key_pressed(KEY_SHIFT) else 205.0
		if axis != 0.0:
			face = -1 if axis < 0 else 1
			px = clampf(px + axis * pace * delta, 55.0, LAND_END - 55.0)
			walk_phase += delta * pace / 27.0
		if py >= FLOOR_Y and (Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)):
			vy = -520.0
		vy += 1180.0 * delta
		py = minf(FLOOR_Y, py + vy * delta)
		if py >= FLOOR_Y: vy = 0.0
		if stage == 3 and abs(px - 1430.0) < 155.0 and Input.is_key_pressed(KEY_R):
			meditation += delta
			if meditation >= 4.0:
				stage = 4
				earn_xp(40)
				money += 80
				notify("Linh Thụ đáp lại hơi thở của bạn. +40 EXP, +80 linh thạch.\nTrở về gặp Thôn trưởng (phía Tây) và chọn con đường tu luyện!", 8.0)
				save_game()
		for mob in monsters:
			if mob["alive"] and stage >= 2:
				mob["cool"] = maxf(0.0, float(mob["cool"]) - delta)
				if abs(float(mob["x"]) - px) < 59.0 and abs(py - FLOOR_Y) < 35.0 and float(mob["cool"]) <= 0.0:
					hp -= 13
					hurt_timer = 0.3
					mob["cool"] = 1.7
					if hp <= 0:
						hp = max_hp
						px = 670.0
						notify("Bạn kiệt sức và được dân làng cứu về khu an toàn. Không mất tiến độ.")
	for i in range(sparkles.size() - 1, -1, -1):
		sparkles[i]["t"] -= delta
		if sparkles[i]["t"] <= 0.0: sparkles.remove_at(i)
	scroll_x = clampf(px - 540.0, 0.0, LAND_END - WIDTH)
	queue_redraw()

func interact() -> void:
	for npc in npcs:
		if abs(px - float(npc["x"])) < 100.0:
			match npc["name"]:
				"Tống tiên sinh":
					if stage == 0:
						stage = 1
						earn_xp(20)
						notify("Tống tiên sinh: 'Muốn bước vào tiên lộ, trước hết hãy hiểu từng nhành cỏ.'\nNhiệm vụ: Thu thập 3 linh thảo ở con đường phía Đông. +20 EXP.", 9.0)
						save_game()
					else: notify("Tống tiên sinh: 'Chữ viết có thể che giấu vận mệnh. Hãy kiên trì tu luyện.'")
				"Thôn trưởng":
					if stage == 4:
						notify("Thôn trưởng: 'Con đã đủ tư cách chọn đạo lộ.'\nNhấn [1] Thái Hư Kiếm Tông  [2] Vạn Pháp Cung\n[3] Thiên Đạo Viện   [4] Tán tu — tự do tìm bí kíp.", 18.0)
					else: notify("Thôn trưởng: 'Thôn Thanh Khê luôn chào đón người tu hành. Hãy hoàn thành thử thách tân thủ.'")
				"A Ninh": notify("A Ninh: 'Dọc bờ suối phía Đông có linh thảo. Cẩn thận linh thú gần bãi tập!'", 7.0)
				"Thợ rèn": notify("Thợ rèn: 'Ta chưa mở tính năng rèn khí trong bản demo. Kiếm của ngươi vẫn đủ để luyện tập.'")
				"Võ sư": notify("Võ sư: 'Ấn J để đánh, Shift để chạy, Space để nhảy. Quái linh ở bãi tập phía Đông.'", 7.0)
			return
	if stage == 1:
		for herb in herbs:
			if not herb["taken"] and abs(px - float(herb["x"])) < 82.0:
				herb["taken"] = true
				collected += 1
				earn_xp(10)
				spawn_fx(float(herb["x"]), FLOOR_Y - 18.0, Color("a1ffd1"), 12)
				if collected >= 3:
					stage = 2
					notify("Đã thu đủ 3/3 linh thảo! +10 EXP.\nNhiệm vụ mới: Đánh bại 3 linh thú ở bãi tập phía Đông.", 9.0)
				else: notify("Đã hái linh thảo (%d/3). +10 EXP." % collected)
				save_game()
				return
	notify("Không có gì để tương tác ở đây. Hãy tới gần NPC hoặc bụi linh thảo.", 2.3)

func attack() -> void:
	if attack_timer > 0.0 or page != "": return
	attack_timer = 0.35
	attack_anim = 0.23
	spawn_fx(px + face * 62.0, py - 55.0, Color("bcf4ff"), 6)
	if stage < 2: return
	for mob in monsters:
		if mob["alive"] and (float(mob["x"]) - px) * face > -12.0 and (float(mob["x"]) - px) * face < 115.0 and abs(py - FLOOR_Y) < 60.0:
			mob["hp"] -= 48
			spawn_fx(float(mob["x"]), FLOOR_Y - 38.0, Color("fee2a6"), 15)
			if mob["hp"] <= 0:
				mob["alive"] = false
				defeated += 1
				earn_xp(18)
				money += 15
				if defeated >= 3 and stage == 2:
					stage = 3
					notify("Đã đánh bại 3/3 linh thú!\nĐến Linh Thụ (cây phát sáng ở giữa làng), giữ [R] trong 4 giây để thiền định.", 10.0)
				else: notify("Linh thú tan thành linh khí. %d/3 · +18 EXP · +15 linh thạch" % defeated, 4.0)
				save_game()
			break

func spawn_fx(x: float, y: float, color: Color, count: int) -> void:
	for i in range(count):
		var a := float(i) * TAU / float(count)
		sparkles.append({"x": x + cos(a) * 17.0, "y": y + sin(a) * 17.0, "t": 0.35 + float(i % 4) * 0.10, "color": color})

func txt(x: float, y: float, s: String, size: int = 17, color: Color = CREAM, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, width: float = -1.0) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(x,y), s, align, width, size, color)

func polygon(points: Array, c: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), c)

func circle(x: float, y: float, radius: float, c: Color) -> void:
	draw_circle(Vector2(x,y), radius, c)

func line(x1: float, y1: float, x2: float, y2: float, c: Color, w: float = 2.0) -> void:
	draw_line(Vector2(x1,y1),Vector2(x2,y2),c,w,true)

func panel(r: Rect2, fill: Color = Color(0.07,0.12,0.14,0.80)) -> void:
	draw_rect(r,fill)
	draw_rect(r,Color("8f7352"),false,1.6)
	line(r.position.x + 6,r.position.y + 5,r.position.x + 47,r.position.y + 5,Color("f4d6a1"),1.8)
	line(r.end.x - 48,r.end.y - 5,r.end.x - 6,r.end.y - 5,Color("f4d6a1"),1.8)

func _draw() -> void:
	# Authentic concept-art panorama: real hand-painted assets replace vector placeholder scenery.
	draw_texture_rect_region(BG_ART, Rect2(0, 0, WIDTH, HEIGHT), Rect2(scroll_x, 0, WIDTH, HEIGHT))
	draw_art_atmosphere()
	draw_set_transform(Vector2(-scroll_x, 0))
	for herb in herbs:
		if not herb["taken"]:
			draw_herb(float(herb["x"]))
	for i in range(npcs.size()):
		var npc: Dictionary = npcs[i]
		var tex: Texture2D = [SCHOLAR_ART, SCHOLAR_ART, GIRL_ART, SMITH_ART, TRAINER_ART][i]
		draw_concept_character(float(npc["x"]), FLOOR_Y, tex, false, str(npc["name"]))
	if stage >= 2:
		for mob in monsters:
			if mob["alive"]:
				draw_mob(float(mob["x"]), FLOOR_Y)
	draw_concept_character(px, py, HERO_ART, true, "Thiên Hành")
	for spark in sparkles:
		var sx: float = float(spark["x"])
		var sy: float = float(spark["y"]) - (1.0 - float(spark["t"])) * 36.0
		circle(sx, sy, 3.0 + float(spark["t"]) * 4.0, spark["color"])
	draw_set_transform(Vector2.ZERO)
	draw_hud()
	if intro:
		draw_intro()
	if page != "":
		draw_overlay()

func draw_art_atmosphere() -> void:
	# Soft vertical glow, drifting blossom particles, light haze across the scene.
	for i in range(11):
		var rx := fposmod(float(i * 149) + world_time * (9.0 + float(i%3)*6.0), 1370.0) - 45.0
		var ry := 130.0 + float((i * 67) % 510) + sin(world_time*0.6+float(i)) * 13.0
		draw_circle(Vector2(rx, ry), 2.5 + float(i%3), Color(1, 0.82, 0.83, 0.45))
	# The art shows a natural path; do not cover it with solid polygons.
	draw_rect(Rect2(0, 688, WIDTH, 32), Color(0.05,0.13,0.13,0.15))

func draw_concept_character(x: float, foot: float, art: Texture2D, is_player: bool, title: String) -> void:
	var bob: float = absf(sin(walk_phase))*3.0 if is_player and py >= FLOOR_Y else 0.0
	var y: float = foot - bob
	draw_ellipse_shadow(x, foot + 1, 29, 8)
	var width := 87.0 if is_player else 77.0
	var height := 177.0 if is_player else 153.0
	draw_texture_rect(art, Rect2(x-width*.5, y-height, width, height), false)
	if is_player:
		# Motion cue and a luminous sword stroke retain the existing combat feedback.
		if attack_anim > 0.0:
			var fx := float(face)
			draw_arc(Vector2(x+fx*18.0,y-86.0), 62, -PI/2 if face==1 else PI/2, PI/2 if face==1 else 3.0*PI/2, 24, Color("bffcff"),6)
			line(x+fx*22.0,y-72.0,x+fx*97.0,y-104.0, Color("ffffff"),4.0)
		draw_rect(Rect2(x-28,y-height-17,56,5),Color("23383c"))
		draw_rect(Rect2(x-28,y-height-17,56.0*float(hp)/float(max_hp),5),Color("82eac2"))
	else:
		draw_circle(Vector2(x,y-height-22), 11, Color("f8c572"))
		txt(x-4,y-height-16,"!",14,Color("4b3020"))
	txt(x-91,y-height-30,title,15,GOLD_LIGHT,HORIZONTAL_ALIGNMENT_CENTER,182)

func draw_ellipse_shadow(x: float, y: float, rad_x: float, rad_y: float) -> void:
	draw_set_transform(Vector2(-scroll_x+x,y),0.0,Vector2(rad_x,rad_y))
	draw_circle(Vector2.ZERO,1.0,Color(0.045,0.105,0.10,0.40))
	draw_set_transform(Vector2(-scroll_x,0.0))

func draw_sky() -> void:
	for y in range(0,HEIGHT,7):
		var t := float(y) / 720.0
		var c := Color("b0dcdf").lerp(Color("eaf0d2"), minf(1.0,t * 1.45))
		draw_rect(Rect2(0,y,WIDTH,7),c)
	for r in range(11,0,-1): circle(1035,119,float(r)*18.0, Color(1.0,0.95,0.74,0.010))
	circle(1035,119,46,Color("fff3d5"))
	for i in range(21):
		var x := float((i*197+82)%1390)
		var y := float(75+(i*67)%160)
		for j in range(3): circle(x+j*23.0,y+sin(float(j)*2.0)*9.0,28.0,Color(1,1,1,0.12))

func draw_far_hills() -> void:
	for i in range(12):
		var x := -220.0 + float(i)*330.0
		var peak := 175.0 + float((i*47)%98)
		polygon([Vector2(x-220,460), Vector2(x+40,peak), Vector2(x+390,460)],Color("a1b8ad").lerp(Color("bbd1c5"),float(i%4)*0.12))
		polygon([Vector2(x+7,peak+40),Vector2(x+40,peak),Vector2(x+88,peak+63),Vector2(x+52,peak+54)],Color(0.97,0.96,0.89,0.37))
	for i in range(10):
		var x := float(i*470+225)
		polygon([Vector2(x,453),Vector2(x+18,310),Vector2(x+35,320),Vector2(x+32,453)],Color(0.92,0.98,0.99,0.12))

func draw_mid_hills() -> void:
	for i in range(18):
		var x := -120.0 + float(i)*250.0
		var peak := 315.0 + float((i*61)%80)
		polygon([Vector2(x-230,515),Vector2(x,peak),Vector2(x+220,515)],Color("658f7a"))
		polygon([Vector2(x-120,515),Vector2(x,peak+47),Vector2(x+135,515)],Color("739884"))
		for j in range(7):
			circle(x + float(j*43-110), 444.0-float((j*13)%60), float(29+(j%3)*7),Color("648c70"))
	for i in range(12):
		var x := float(i*360+100)
		line(x,460,x+80,460,Color(0.92,0.96,0.89,0.25),3.0)

func draw_village() -> void:
	polygon([Vector2(-500,465),Vector2(4100,456),Vector2(4100,720),Vector2(-500,720)],Color("91a97b"))
	for i in range(80):
		var x := float(i*47 + (i*31)%25)
		var y := 494.0 + float((i*17)%65)
		circle(x,y,19.0+float(i%4)*6.0,Color("547e59"))
	# Sunlit traversable earthen road.
	polygon([Vector2(-200,551),Vector2(4100,530),Vector2(4100,700),Vector2(-200,677)],Color("cdb790"))
	polygon([Vector2(-200,562),Vector2(4100,542),Vector2(4100,631),Vector2(-200,652)],Color("e2cda4"))
	for i in range(130):
		var x := float(i*37)
		var y := 560.0+float((i*23)%84)
		line(x,y,x+float(5+i%4*3),y-2.0,Color(0.52,0.42,0.31,0.18),1.2)
	# Water reaches the edge of village, with bridge at east end.
	polygon([Vector2(1690,647),Vector2(2320,634),Vector2(2360,720),Vector2(1660,720)],Color("4e9aa2"))
	for i in range(38):
		var x := float(1705+i*17)
		line(x,669.0 + sin(world_time*1.7+float(i))*9.0,x+15,671.0+sin(world_time*1.7+float(i))*9.0,Color(0.73,0.96,0.93,0.47),1.7)
	for x in [220.0,740.0,1820.0,3200.0]: draw_house(x, x==220.0)
	for x in [120.0,640.0,1030.0,2010.0,2420.0,2950.0,3310.0]: draw_tree(x, 513.0, x!=1030.0)
	# Spirit tree is the visual landmark of the starter village.
	draw_spirit_tree(1430.0,519.0)
	# Bright lantern poles and carved training stakes.
	for x in [350.0,995.0,1610.0,2215.0,2390.0,3180.0]:
		line(x,559,x,468,Color("5d4b3e"),5)
		line(x-22,477,x+22,477,Color("63483d"),5)
		draw_rect(Rect2(x-12,487,24,31),Color("ce7153"))
		draw_rect(Rect2(x-8,491,16,23),Color("ffdb9a"))
		circle(x,500,16,Color(1,0.77,0.36,0.14))
	for x in [2360.0,2440.0,2490.0]:
		line(x,568,x,505,Color("694c35"),8)
		line(x-22,528,x+22,528,Color("74573c"),6)
	# Fences and grasses closer to the viewer.
	for i in range(110):
		var x := float(i*39)
		var y := 620.0+float((i*19)%60)
		for n in range(3): line(x,y,x+float(n*4-4),y-8.0-float((i+n)%7),Color("5e8b51"),1.6)
	for x in [60.0,165.0,350.0,560.0,1310.0,2010.0,3160.0]:
		for k in range(8): circle(x+float((k*19)%87),638.0+float((k*17)%28),3.2,Color("f2d6be"))

func draw_house(x: float, library: bool) -> void:
	var y := 490.0
	var w := 290.0 if library else 230.0
	var h := 113.0 if library else 100.0
	draw_rect(Rect2(x-w/2,y-h/2,w,h),Color("d8c49e"))
	for i in range(8):
		var bx := x-w/2+float(i)*(w/7.0)
		line(bx,y-h/2,bx,y+h/2,Color("735343"),4)
		line(bx+9,y-h/2+9,bx+9,y+h/2-2,Color("bda37d"),1)
	draw_rect(Rect2(x-33,y+4,66,57),Color("4d3c32"))
	draw_rect(Rect2(x-28,y+8,56,48),Color("a2795a"))
	line(x,y+8,x,y+56,Color("4b362e"),3)
	for wx in [-94.0,70.0]:
		draw_rect(Rect2(x+wx,y-12,43,41),Color("423b32"))
		for j in range(3): line(x+wx+float(j*13+4),y-8,x+wx+float(j*13+4),y+25,Color("d8b386"),2)
	# Curved double eaves, ceramic tiles and trim.
	polygon([Vector2(x-w/2-35,y-h/2+4),Vector2(x,y-h/2-73),Vector2(x+w/2+35,y-h/2+4),Vector2(x+w/2+15,y-h/2+18),Vector2(x,y-h/2-56),Vector2(x-w/2-15,y-h/2+18)],Color("554843"))
	polygon([Vector2(x-w/2-28,y-h/2+4),Vector2(x,y-h/2-64),Vector2(x+w/2+28,y-h/2+4),Vector2(x,y-h/2-52)],Color("796855"))
	for i in range(15):
		var xx := x-w/2+float(i)*(w/14.0)
		line(xx,y-h/2-2,xx+float(i-7)*2.7,y-h/2-55.0+abs(float(i-7))*2.5,Color("aa9470"),1.0)
	line(x-w/2-35,y-h/2+5,x+w/2+35,y-h/2+5,Color("d3b17a"),5)
	if library:
		draw_rect(Rect2(x-70,y-h/2+24,140,28),Color("2d4241"))
		txt(x-58,y-h/2+45,"THƯ QUÁN THANH KHÊ",13,GOLD)
	else:
		draw_rect(Rect2(x-43,y-h/2+15,86,23),Color("304443"))
		txt(x-28,y-h/2+33,"DÂN CƯ",12,GOLD)

func draw_tree(x: float, y: float, blossom: bool) -> void:
	var seed := int(x)
	line(x,y,x-8,y-143,Color("644c3c"),13)
	line(x-8,y-105,x-71,y-172,Color("634c3d"),7)
	line(x-8,y-125,x+66,y-202,Color("634c3d"),8)
	for i in range(43):
		var xx := x-93.0 + float((i*41+seed)%180)
		var yy := y-225.0 + float((i*29+seed)%90)
		var rad := 20.0 + float((i*13)%17)
		var c := Color("dcaab8") if blossom else Color("4f896a")
		if i%3==0: c = Color("f4c5c1") if blossom else Color("71a78a")
		if i%5==0: c = Color("e2d2bc") if blossom else Color("8bad79")
		circle(xx,yy,rad,c)
	for j in range(23):
		var xx := x-78.0+float((j*43+seed)%159)
		var yy := y-225.0+float((j*31+seed)%95)
		circle(xx,yy,3.0,Color("fff0e5") if blossom else Color("cadcb2"))

func draw_spirit_tree(x: float, y: float) -> void:
	for i in range(12,0,-1): circle(x,y-157.0,float(i)*21.0,Color(0.35,0.95,0.91,0.012))
	line(x,y,x-9,y-161,Color("584f51"),26)
	for i in range(5):
		var a := float(i)*TAU/5.0
		line(x-9,y-156,x+cos(a)*160,y-242+sin(a)*53,Color("5b5055"),12)
	for i in range(80):
		var xx := x - 170.0 + float((i*71)%344)
		var yy := y - 287.0 + float((i*47)%156)
		circle(xx,yy,20.0+float((i*11)%24),Color("74a69b") if i%3 else Color("99c4a9"))
	for i in range(57):
		var xx := x-167.0+float((i*53)%335)
		var yy := y-278.0+float((i*27)%137)
		circle(xx,yy,4.0+float(i%4),Color(0.74,1.0,0.95,0.65))
	for i in range(8):
		var a := world_time*0.56+float(i)*TAU/8.0
		circle(x+cos(a)*75.0,y-151.0+sin(a)*56.0,6.0,Color("86fff4"))
	polygon([Vector2(x,y-123),Vector2(x+18,y-96),Vector2(x,y-68),Vector2(x-18,y-96)],Color("63f7f8"))
	circle(x,y-96,13,Color("ecffff"))
	txt(x-96,y-323,"✦  L I N H   T H Ụ  ✦",18,Color("ebfcdb"))
	if stage == 3 and abs(px-x)<155.0:
		txt(x-134,y-336,"Giữ [R] để thiền định: %d%%" % int(meditation/4.0*100),15,GOLD)

func draw_herb(x: float) -> void:
	for i in range(3):
		line(x,FLOOR_Y-3,x+float(i-1)*10,FLOOR_Y-29-float(i%2)*15,Color("387f5a"),3)
		circle(x+float(i-1)*10,FLOOR_Y-31.0-float(i%2)*15.0,9.0,Color("94d8a4"))
	circle(x,FLOOR_Y-43,4.0,Color("d7fff3"))
	txt(x-58,FLOOR_Y-56,"Linh thảo  [E]",14,Color("e4f8ca"))

func draw_mob(x: float, floor_y: float) -> void:
	var bounce := sin(world_time*3.0 + x*0.01)*5.0
	circle(x,floor_y-5.0,30,Color(0.1,0.2,0.17,0.25))
	polygon([Vector2(x-28,floor_y-30+bounce),Vector2(x-51,floor_y-78+bounce),Vector2(x-9,floor_y-64+bounce)],Color("a4e4d2"))
	polygon([Vector2(x+28,floor_y-30+bounce),Vector2(x+51,floor_y-78+bounce),Vector2(x+9,floor_y-64+bounce)],Color("a4e4d2"))
	circle(x,floor_y-39+bounce,37,Color("5e9d91"))
	circle(x-12,floor_y-44+bounce,5,Color("f4f5db"))
	circle(x+12,floor_y-44+bounce,5,Color("f4f5db"))
	circle(x-12,floor_y-44+bounce,2,Color("192b32"))
	circle(x+12,floor_y-44+bounce,2,Color("192b32"))
	txt(x-60,floor_y-94+bounce,"Linh thú hoang",14,CREAM)

func draw_person(x: float, foot: float, robe: Color, player: bool, name: String) -> void:
	var bob := 0.0
	if player and py >= FLOOR_Y: bob = abs(sin(walk_phase))*2.5
	var y := foot-bob
	circle(x,foot+2.0,24,Color(0.22,0.20,0.12,0.18))
	var left := sin(walk_phase)*9.0 if player else 0.0
	line(x-8,y-31,x-10+left,y-1,Color("3b4c5b"),6)
	line(x+8,y-31,x+10-left,y-1,Color("3b4c5b"),6)
	polygon([Vector2(x-11,y-65),Vector2(x+12,y-65),Vector2(x+25,y-21),Vector2(x-26,y-21)],robe)
	polygon([Vector2(x-11,y-61),Vector2(x+2,y-50),Vector2(x-6,y-21),Vector2(x-18,y-20)],Color("7999aa") if player else robe.darkened(0.18))
	line(x-16,y-49,x-26,y-30,Color("e8d0b8"),6)
	line(x+16,y-49,x+28,y-35,Color("e8d0b8"),6)
	line(x-19,y-42,x+18,y-42,Color("7c604f"),3)
	circle(x,y-78,15.5,Color("e5cab5"))
	polygon([Vector2(x-15,y-76),Vector2(x-13,y-94),Vector2(x,y-103),Vector2(x+14,y-91),Vector2(x+16,y-76),Vector2(x+6,y-90)],Color("242b36"))
	line(x+3,y-98,x+16,y-112,Color("242b36"),7)
	if player:
		line(x+6,y-96,x+18,y-33,Color("293342"),5)
		if attack_anim>0.0:
			var fx := float(face)
			draw_arc(Vector2(x+fx*20.0,y-70.0),62.0,-PI/2.0 if face==1 else PI/2.0, PI/2.0 if face==1 else 3.0*PI/2.0,24,Color("a1faff"),7)
			line(x+fx*22.0,y-51.0,x+fx*91.0,y-98.0,Color("d3ffff"),5)
		else:
			line(x+16,y-60,x+37,y-99,Color("d9e9e7"),4)
	if player:
		draw_rect(Rect2(x-29,y-123,58,5),Color("234a45"))
		draw_rect(Rect2(x-29,y-123,58*float(hp)/float(max_hp),5),Color("77df9a"))
	else:
		circle(x,y-126,11,Color("e6bc73"))
		txt(x-3,y-120,"!",15,Color("342924"))
	txt(x-91,y-137,name,16,GOLD,HORIZONTAL_ALIGNMENT_CENTER,182)

func draw_hud() -> void:
	# Jade, ink and warm-gold fantasy UI; less obstruction than the first prototype.
	panel(Rect2(16,14,295,98),Color(0.035,0.075,0.085,0.80))
	draw_texture_rect(HERO_PORTRAIT,Rect2(25,23,66,72),false)
	draw_rect(Rect2(23,21,70,77),Color("dbb77c"),false,1.8)
	txt(103,39,"THIÊN HÀNH",19,GOLD_LIGHT)
	txt(103,59,"Luyện Khí · Tầng 1",13,Color("e5e9da"))
	draw_rect(Rect2(103,69,189,9),Color("493a44"))
	draw_rect(Rect2(103,69,189.0*float(hp)/float(max_hp),9),Color("d45f65"))
	draw_rect(Rect2(103,83,189,7),Color("263c50"))
	draw_rect(Rect2(103,83,189.0*float(mp)/120.0,7),Color("69c5e9"))
	txt(234,76,"%d/%d" % [hp,max_hp],10,CREAM)
	# Quest panel shrunk from 376x184 to 320x134 and kept translucent.
	panel(Rect2(16,123,320,150),Color(0.035,0.075,0.080,0.72))
	txt(31,148,"NHIỆM VỤ TÂN THỦ",17,GOLD_LIGHT)
	var quest := ""
	match stage:
		0: quest = "Đến Thư Quán gặp Tống tiên sinh.\nĐứng gần và nhấn [E]."
		1: quest = "Hái linh thảo bên đường: %d/3\nĐến gần bụi cây, nhấn [E]." % collected
		2: quest = "Đánh bại linh thú: %d/3\nBãi tập phía Đông · nhấn [J]." % defeated
		3: quest = "Thiền định bên Linh Thụ giữa làng.\nGiữ [R] trong 4 giây: %d%%." % int(meditation/4.0*100.0)
		4: quest = "Về gặp Thôn trưởng.\n[1] Thái Hư  [2] Vạn Pháp\n[3] Thiên Đạo [4] Tán tu"
		_: quest = "Đã hoàn thành Thanh Khê!\nĐạo lộ: %s" % faction
	var quest_lines := quest.split("\n")
	for i in range(quest_lines.size()):
		txt(32,175+float(i)*24.0,quest_lines[i],14,Color("f9f0d9"))
	panel(Rect2(1033,14,232,91),Color(0.035,0.07,0.082,0.77))
	txt(1050,40,"THÔN THANH KHÊ",17,GOLD_LIGHT)
	txt(1050,59,"Nhân Giới · Vùng tân thủ",12,CREAM)
	draw_rect(Rect2(1051,66,196,25),Color(0.12,0.27,0.24,0.88))
	for i in range(7):
		draw_circle(Vector2(1061.0+float(i)*29.0,78.0+sin(float(i)*1.6)*5.0),4.0,Color("6cc9a1"))
	draw_circle(Vector2(1061.0+clampf(px/LAND_END,0.0,1.0)*178.0,78),6,Color("ffd58f"))
	var destination := 490.0
	match stage:
		1: destination = 1050.0 if not herbs[0]["taken"] else 1740.0 if not herbs[1]["taken"] else 2080.0
		2: destination = 2770.0
		3: destination = 1430.0
		4: destination = 870.0
		5: destination = px
	if destination-scroll_x>1240.0:
		txt(1035,139,"MỤC TIÊU  →",13,GOLD_LIGHT)
	elif destination-scroll_x<40.0:
		txt(33,296,"←  MỤC TIÊU",13,GOLD_LIGHT)
	if dialog_timer>0.0:
		panel(Rect2(318,591,690,87),Color(0.035,0.066,0.072,0.90))
		var ls:=dialog.split("\n")
		for i in range(min(2,ls.size())):
			txt(335,624+float(i)*24,ls[i],14,Color("fff4df"))
	panel(Rect2(16,643,246,62),Color(0.032,0.077,0.084,0.81))
	txt(31,666,"Linh thạch: %d" % money,14,GOLD_LIGHT)
	txt(31,689,"EXP: %d / 250     SM: 100" % exp_points,13,CREAM)
	panel(Rect2(952,647,313,58),Color(0.035,0.073,0.078,0.79))
	txt(965,671,"A/D: Đi  ·  Space: Nhảy  ·  Shift: Chạy",12,CREAM)
	txt(965,690,"E: NPC  ·  J: Kiếm  ·  I: Hồ sơ",12,CREAM)
	if dialog_timer==0.0:
		for npc in npcs:
			if abs(float(npc["x"])-px)<100.0:
				txt(500,456,"[E] Trò chuyện: %s" % npc["name"],17,Color("fff1bf"))
				break

func draw_intro() -> void:
	draw_rect(Rect2(0,0,WIDTH,HEIGHT),Color(0.04,0.1,0.14,0.50))
	panel(Rect2(290,158,700,392),Color(0.035,0.10,0.125,0.91))
	txt(349,229,"THIÊN ĐẠO VIẾT LẠI",45,GOLD)
	txt(465,269,"THANH KHÊ · CHƯƠNG MỞ ĐẦU",19,Color("d9ece0"))
	line(372,291,907,291,Color("967c5f"),1.5)
	txt(355,335,"Một thư quán cổ. Một thôn làng bình dị. Một con đường nghịch thiên.",17,CREAM)
	txt(365,378,"Khám phá Thanh Khê, nhận nhiệm vụ, chiến đấu và bắt đầu tu luyện.",16,Color("cadbd3"))
	txt(468,454,"[ ENTER ]  BẮT ĐẦU KHÁM PHÁ",24,Color("b5f6dc"))
	txt(511,506,"Demo 0.3  •  Mỹ thuật tiên hiệp  •  Lưu tự động",14,Color("b5b5a7"))

func draw_overlay() -> void:
	panel(Rect2(290,172,700,380),Color(0.05,0.12,0.13,0.94))
	if page == "help":
		txt(330,224,"HƯỚNG DẪN",28,GOLD)
		var help := ["A/D hoặc ←/→  :  Di chuyển", "Shift  :  Chạy nhanh       Space/W/↑  :  Nhảy", "E  :  Trò chuyện / hái linh thảo", "J hoặc chuột trái  :  Chém kiếm", "Giữ R cạnh Linh Thụ  :  Thiền định", "1–4 cạnh Thôn trưởng  :  Chọn đạo lộ", "I  :  Hồ sơ nhân vật      Esc  :  Đóng bảng"]
		for i in range(help.size()): txt(330,271+float(i)*37.0,help[i],18,CREAM)
	else:
		txt(330,224,"HỒ SƠ TU LUYỆN",28,GOLD)
		var entries := ["Tên: Thiên Hành", "Cảnh giới hiện tại: Luyện Khí Tầng 1 (thử nghiệm)", "Thế lực: %s" % faction, "Tu vi: 40         Trang bị: 25", "Bí kíp: 20         Sủng thú: 0", "Thể chất / Huyết mạch: 15", "SỨC MẠNH TỔNG: 100", "EXP hiện có: %d" % exp_points]
		for i in range(entries.size()): txt(330,266+float(i)*31.0,entries[i],17,CREAM)
	txt(808,531,"[ ESC ] Đóng",15,Color("cbddce"))