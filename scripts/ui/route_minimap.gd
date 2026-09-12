class_name RouteMinimap
extends Control

var route_points := PackedVector2Array()
var checkpoint_points := PackedVector2Array()
var player_point := Vector2.ZERO
var active_checkpoint := 0
var bounds := Rect2(Vector2.ZERO, Vector2.ONE)

func _ready() -> void:
	custom_minimum_size = Vector2(178, 150)
	size = Vector2(178, 150)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func configure(route_world: Array, checkpoint_indices: Array[int]) -> void:
	route_points.clear(); checkpoint_points.clear()
	for point in route_world:
		var world: Vector3 = point
		route_points.append(Vector2(world.x, -world.z))
	for index in checkpoint_indices:
		if index >= 0 and index < route_points.size(): checkpoint_points.append(route_points[index])
	if route_points.is_empty(): return
	var min_point := route_points[0]; var max_point := route_points[0]
	for point in route_points:
		min_point = min_point.min(point); max_point = max_point.max(point)
	bounds = Rect2(min_point, (max_point - min_point).max(Vector2(1.0, 1.0)))
	queue_redraw()

func set_player(world_position: Vector3) -> void:
	player_point = Vector2(world_position.x, -world_position.z)
	queue_redraw()

func set_active_checkpoint(index: int) -> void:
	active_checkpoint = index
	queue_redraw()

func _map(point: Vector2) -> Vector2:
	var padding := 13.0
	var available := size - Vector2(padding * 2.0, padding * 2.0)
	var scale_factor := minf(available.x / bounds.size.x, available.y / bounds.size.y)
	var offset := (available - bounds.size * scale_factor) * 0.5
	return Vector2(padding, padding) + offset + (point - bounds.position) * scale_factor

func _draw() -> void:
	var panel := Color(0.01, 0.035, 0.07, 0.77)
	draw_style_box(_panel_style(), Rect2(Vector2.ZERO, size))
	draw_string(ThemeDB.fallback_font, Vector2(13, 21), "ROUTE MAP", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color("8ce9ff"))
	if route_points.size() < 2: return
	var mapped := PackedVector2Array()
	for point in route_points: mapped.append(_map(point))
	draw_polyline(mapped, Color("2d6179"), 5.0, true)
	draw_polyline(mapped, Color("65dbef"), 1.6, true)
	for index in checkpoint_points.size():
		var color := Color("ffb85a")
		var radius := 3.0
		if index == active_checkpoint: color = Color("54f2ff"); radius = 5.5
		elif index < active_checkpoint: color = Color("426779")
		draw_circle(_map(checkpoint_points[index]), radius, color)
	var player := _map(player_point)
	var triangle := PackedVector2Array([player + Vector2(0, -7), player + Vector2(5, 5), player + Vector2(-5, 5)])
	draw_colored_polygon(triangle, Color.WHITE)

func _panel_style() -> StyleBoxFlat:
	var panel := StyleBoxFlat.new(); panel.bg_color = Color(0.01, 0.035, 0.07, 0.77); panel.border_color = Color("22607c"); panel.set_border_width_all(1); panel.corner_radius_top_left = 8; panel.corner_radius_top_right = 8; panel.corner_radius_bottom_left = 8; panel.corner_radius_bottom_right = 8; return panel
