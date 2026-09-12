class_name RaceHUD
extends CanvasLayer

const ROUTE_MINIMAP_SCRIPT := preload("res://scripts/ui/route_minimap.gd")

var title: Label
var speed: Label
var time: Label
var checkpoint: Label
var best: Label
var status: Label
var route_arrow: Label
var route_distance: Label
var boost: ProgressBar
var prompt: Label
var start_card: Panel
var start_art: TextureRect
var start_heading: Label
var start_copy: Label
var pause_card: Panel
var results_card: Panel
var results_heading: Label
var results_copy: Label
var audio_note: Label
var performance_note: Label
var ghost_note: Label
var checkpoint_pips: Array[ColorRect] = []
var progress_box: HBoxContainer
var garage_card: Panel
var garage_preview: TextureRect
var garage_name: Label
var garage_copy: Label
var garage_stats: Label
var garage_controls: Label
var sector: Label
var minimap
var status_tween: Tween

func _ready() -> void:
	var root := Control.new(); root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(root)
	_build_cards(root)
	title = _label(30, Color("8ce9ff")); title.position = Vector2(34, 26); root.add_child(title)
	speed = _label(42, Color.WHITE); speed.position = Vector2(34, 78); root.add_child(speed)
	time = _label(30, Color.WHITE); time.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT; time.set_anchors_preset(Control.PRESET_TOP_RIGHT); time.position = Vector2(-280, 28); time.size = Vector2(245, 42); root.add_child(time)
	checkpoint = _label(19, Color("d7e2f4")); checkpoint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT; checkpoint.set_anchors_preset(Control.PRESET_TOP_RIGHT); checkpoint.position = Vector2(-280, 72); checkpoint.size = Vector2(245, 30); root.add_child(checkpoint)
	best = _label(17, Color("8ce9ff")); best.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT; best.set_anchors_preset(Control.PRESET_TOP_RIGHT); best.position = Vector2(-280, 105); best.size = Vector2(245, 28); root.add_child(best)
	boost = ProgressBar.new(); boost.position = Vector2(35, 137); boost.size = Vector2(260, 18); boost.max_value = 100; boost.show_percentage = false; root.add_child(boost)
	boost.tooltip_text = "BOOST: drift to recharge, Shift / B to spend"
	ghost_note = _label(15, Color("8ce9ff")); ghost_note.position = Vector2(35, 160); ghost_note.size = Vector2(280, 24); root.add_child(ghost_note)
	sector = _label(16, Color("ffce7a")); sector.position = Vector2(35, 184); sector.size = Vector2(320, 24); root.add_child(sector)
	minimap = ROUTE_MINIMAP_SCRIPT.new(); minimap.set_anchors_preset(Control.PRESET_TOP_RIGHT); minimap.position = Vector2(-220, 150); minimap.size = Vector2(178, 150); root.add_child(minimap)
	status = _label(22, Color("ffbd50")); status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; status.set_anchors_preset(Control.PRESET_CENTER_TOP); status.position = Vector2(-220, 28); status.size = Vector2(440, 35); root.add_child(status)
	progress_box = HBoxContainer.new(); progress_box.set_anchors_preset(Control.PRESET_CENTER_TOP); progress_box.position = Vector2(-95, 67); progress_box.size = Vector2(190, 12); progress_box.add_theme_constant_override("separation", 5); root.add_child(progress_box)
	for _index in 10:
		var pip := ColorRect.new(); pip.color = Color("1a384b"); pip.custom_minimum_size = Vector2(14, 8); progress_box.add_child(pip); checkpoint_pips.append(pip)
	route_arrow = _label(104, Color(1.0, 1.0, 1.0, 0.38)); route_arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; route_arrow.set_anchors_preset(Control.PRESET_CENTER); route_arrow.position = Vector2(-110, -85); route_arrow.size = Vector2(220, 150); route_arrow.visible = false; root.add_child(route_arrow)
	route_distance = _label(24, Color("ffffff")); route_distance.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; route_distance.set_anchors_preset(Control.PRESET_CENTER_BOTTOM); route_distance.position = Vector2(-180, -72); route_distance.size = Vector2(360, 36); root.add_child(route_distance)
	prompt = _label(28, Color("ffffff")); prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; prompt.set_anchors_preset(Control.PRESET_CENTER); prompt.position = Vector2(-280, -70); prompt.size = Vector2(560, 140); root.add_child(prompt)
	audio_note = _label(15, Color("9ec7d7")); audio_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT; audio_note.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT); audio_note.position = Vector2(-230, -34); audio_note.size = Vector2(200, 24); root.add_child(audio_note)
	performance_note = _label(14, Color("a8cbd6")); performance_note.position = Vector2(34, 674); performance_note.size = Vector2(440, 22); root.add_child(performance_note)

func _build_cards(root: Control) -> void:
	start_card = _card(); start_card.set_anchors_preset(Control.PRESET_CENTER); start_card.position = Vector2(-285, -240); start_card.size = Vector2(570, 480); root.add_child(start_card)
	start_art = TextureRect.new(); start_art.texture = load("res://neon_rainline_cyberpunk_racing_logo.png"); start_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; start_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; start_art.position = Vector2(22, 20); start_art.size = Vector2(526, 230); start_card.add_child(start_art)
	start_heading = _label(27, Color("8ce9ff")); start_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; start_heading.position = Vector2(30, 258); start_heading.size = Vector2(510, 40); start_card.add_child(start_heading)
	start_copy = _label(17, Color("e3edf5")); start_copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; start_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; start_copy.position = Vector2(45, 310); start_copy.size = Vector2(480, 130); start_card.add_child(start_copy)
	garage_card = _card(); garage_card.set_anchors_preset(Control.PRESET_CENTER); garage_card.position = Vector2(-480, -260); garage_card.size = Vector2(960, 520); garage_card.visible = false; root.add_child(garage_card)
	garage_preview = TextureRect.new(); garage_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; garage_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; garage_preview.position = Vector2(28, 48); garage_preview.size = Vector2(500, 281); garage_card.add_child(garage_preview)
	garage_name = _label(34, Color("8ce9ff")); garage_name.position = Vector2(565, 67); garage_name.size = Vector2(360, 46); garage_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; garage_card.add_child(garage_name)
	garage_stats = _label(17, Color("ffcf79")); garage_stats.position = Vector2(565, 128); garage_stats.size = Vector2(360, 25); garage_card.add_child(garage_stats)
	garage_copy = _label(18, Color("e3edf5")); garage_copy.position = Vector2(565, 175); garage_copy.size = Vector2(350, 115); garage_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; garage_card.add_child(garage_copy)
	garage_controls = _label(16, Color("b9d9e6")); garage_controls.position = Vector2(565, 337); garage_controls.size = Vector2(350, 110); garage_controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; garage_card.add_child(garage_controls)
	var garage_title := _label(22, Color("ffbd50")); garage_title.text = "RAINLINE GARAGE"; garage_title.position = Vector2(28, 14); garage_title.size = Vector2(360, 26); garage_card.add_child(garage_title)
	pause_card = _card(); pause_card.set_anchors_preset(Control.PRESET_CENTER); pause_card.position = Vector2(-240, -145); pause_card.size = Vector2(480, 290); pause_card.visible = false; root.add_child(pause_card)
	var pause_title := _label(34, Color("8ce9ff")); pause_title.text = "PAUSED"; pause_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; pause_title.position = Vector2(20, 30); pause_title.size = Vector2(440, 45); pause_card.add_child(pause_title)
	var pause_copy := _label(18, Color("e3edf5")); pause_copy.text = "Esc / Menu  Resume\nC / X  Chase / first-person camera\nR / Y  Restart from the last gate\nM  Toggle audio • F  Comfort camera\nV  Showcase / performance graphics"; pause_copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; pause_copy.position = Vector2(30, 82); pause_copy.size = Vector2(420, 180); pause_card.add_child(pause_copy)
	results_card = _card(); results_card.set_anchors_preset(Control.PRESET_CENTER); results_card.position = Vector2(-260, -155); results_card.size = Vector2(520, 310); results_card.visible = false; root.add_child(results_card)
	results_heading = _label(32, Color("ffbd50")); results_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; results_heading.position = Vector2(20, 34); results_heading.size = Vector2(480, 45); results_card.add_child(results_heading)
	results_copy = _label(21, Color("e3edf5")); results_copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; results_copy.position = Vector2(25, 92); results_copy.size = Vector2(470, 165); results_card.add_child(results_copy)

func _card() -> Panel:
	var panel := Panel.new()
	var style := StyleBoxFlat.new(); style.bg_color = Color(0.012, 0.04, 0.08, 0.91); style.border_color = Color("3ccbea"); style.set_border_width_all(2); style.corner_radius_top_left = 12; style.corner_radius_top_right = 12; style.corner_radius_bottom_left = 12; style.corner_radius_bottom_right = 12; style.shadow_color = Color(0.0, 0.8, 1.0, 0.22); style.shadow_size = 20
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _label(font_size: int, color: Color) -> Label:
	var label := Label.new(); label.add_theme_font_size_override("font_size", font_size); label.add_theme_color_override("font_color", color); label.add_theme_color_override("font_shadow_color", Color.BLACK); label.add_theme_constant_override("shadow_offset_x", 2); label.add_theme_constant_override("shadow_offset_y", 2); return label

func set_prompt(value: String) -> void: prompt.text = value

func set_status(value: String, duration := 2.4) -> void:
	# Status is a toast, not persistent header copy. This keeps recovery and
	# checkpoint feedback from competing with the route title.
	if status_tween != null and status_tween.is_valid(): status_tween.kill()
	status.text = value
	status.visible = not value.is_empty()
	status.modulate = Color.WHITE
	if value.is_empty() or duration <= 0.0: return
	status_tween = create_tween()
	status_tween.tween_interval(maxf(0.15, duration - 0.35))
	status_tween.tween_property(status, "modulate:a", 0.0, 0.35)
	status_tween.tween_callback(func():
		status.text = ""
		status.visible = false
	)

func show_title() -> void:
	start_heading.text = "SEATTLE AFTER DARK  //  RAINLINE RUN"
	start_copy.text = "A wet-night time attack through the city.\n\nEnter / RT  Open garage\nWASD or controller  Drive • Space / A  Drift • Shift / B  Boost\nC / X  Chase / first-person • R / Y  Recover • Esc / Menu  Pause"
	start_card.visible = true; garage_card.visible = false; pause_card.visible = false; results_card.visible = false; prompt.visible = false; route_distance.visible = false
	title.visible = false; speed.visible = false; time.visible = false; checkpoint.visible = false; best.visible = false; boost.visible = false; ghost_note.visible = false; sector.visible = false; minimap.visible = false; progress_box.visible = false; status.visible = false; audio_note.visible = false; performance_note.visible = false

func show_race() -> void:
	start_card.visible = false; garage_card.visible = false; pause_card.visible = false; results_card.visible = false; prompt.visible = true; route_distance.visible = true
	title.visible = true; speed.visible = true; time.visible = true; checkpoint.visible = true; best.visible = true; boost.visible = true; ghost_note.visible = true; sector.visible = true; minimap.visible = true; progress_box.visible = true; status.visible = true; audio_note.visible = true; performance_note.visible = true

func show_pause(value: bool) -> void:
	pause_card.visible = value

func show_results(medal: String, time_text: String, is_pb: bool, targets: String) -> void:
	results_heading.text = "%s  %s" % [medal, time_text]
	results_copy.text = "%s\n%s\n\nR / Y  Run again\nEnter / RT  Return to title" % ["NEW PERSONAL BEST — GHOST SAVED" if is_pb else "GHOST REMAINS ON THE ROAD", targets]
	results_card.visible = true; prompt.visible = false; route_distance.visible = false

func set_audio_note(muted: bool) -> void:
	audio_note.text = "AUDIO: MUTED (M)" if muted else "M  AUDIO"

func set_performance(value: String) -> void:
	performance_note.text = value

func set_checkpoint_progress(completed: int, total: int) -> void:
	for index in checkpoint_pips.size():
		checkpoint_pips[index].color = Color("58eaff") if index < completed else Color("1a384b")
	progress_box.tooltip_text = "CHECKPOINTS  %d / %d" % [completed, total]

func set_ghost_note(value: String) -> void:
	ghost_note.text = value

func set_sector(value: String) -> void:
	sector.text = value

func configure_minimap(route: Array, checkpoint_indices: Array[int]) -> void:
	minimap.configure(route, checkpoint_indices)

func update_minimap(position: Vector3, checkpoint_index: int) -> void:
	minimap.set_player(position)
	minimap.set_active_checkpoint(checkpoint_index)

func show_garage() -> void:
	start_card.visible = false; garage_card.visible = true; pause_card.visible = false; results_card.visible = false; prompt.visible = false; route_distance.visible = false
	title.visible = false; speed.visible = false; time.visible = false; checkpoint.visible = false; best.visible = false; boost.visible = false; ghost_note.visible = false; sector.visible = false; minimap.visible = false; progress_box.visible = false; status.visible = false; audio_note.visible = false; performance_note.visible = false

func set_garage_vehicle(name: String, index: int, total: int, description: String, stats: String, preview: Texture2D) -> void:
	garage_preview.texture = preview
	garage_name.text = name
	garage_stats.text = "VEHICLE %d / %d   •   %s" % [index + 1, total, stats]
	garage_copy.text = description
	garage_controls.text = "A / D or left stick   Change vehicle\nEnter / RT   Begin Rainline Run\nEsc / Menu   Back"
