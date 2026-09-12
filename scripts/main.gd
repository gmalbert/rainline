extends Node3D

const EVENT := preload("res://data/events/rainline_run.tres")
const CAR_SCRIPT := preload("res://scripts/vehicle/arcade_car.gd")
const CHECKPOINT_SCRIPT := preload("res://scripts/race/checkpoint.gd")
const RECORDER_SCRIPT := preload("res://scripts/race/ghost_recorder.gd")
const GHOST_SCRIPT := preload("res://scripts/race/ghost_player.gd")
const HUD_SCRIPT := preload("res://scripts/ui/race_hud.gd")
const STREETFRONT_SCENE := preload("res://assets/meshes/rainline_streetfront_v1.glb")
const MARKET_BLOCK_SCENE := preload("res://assets/meshes/rainline_market_block_v1.glb")
const CULTURAL_PAVILION_SCENE := preload("res://assets/meshes/rainline_cultural_pavilion_v1.glb")
const WATERFRONT_CIVIC_SCENE := preload("res://assets/meshes/rainline_waterfront_civic_v1.glb")
const VEHICLES := [
	{"name": "APEX S", "path": "res://assets/meshes/rainline_apex_s_v3.glb", "preview": "res://assets/ui/garage_card_apex_v1.png", "description": "Crimson mid-engine sports coupe. Low, wide, and purpose-built for wet city runs.", "stats": "ACCEL  9   SPEED  8   GRIP  9", "tuning": {"acceleration": 37.0, "max_speed": 168.0, "boosted_max_speed": 205.0, "steering_rate": 2.18, "normal_grip": 9.5, "drift_grip": 2.15, "boost_capacity": 90.0}},
	{"name": "COASTLINE GT", "path": "res://assets/meshes/rainline_coastline_gt_v3.glb", "preview": "res://assets/ui/garage_card_coastline_v1.png", "description": "Midnight-blue grand tourer. Smooth fastback lines for the long waterfront sprint.", "stats": "ACCEL  7   SPEED  10  GRIP  7", "tuning": {"acceleration": 32.0, "max_speed": 185.0, "boosted_max_speed": 222.0, "steering_rate": 1.82, "normal_grip": 8.35, "drift_grip": 2.5, "boost_capacity": 105.0}},
	{"name": "IRONTRAIL X", "path": "res://assets/meshes/rainline_irontrail_x_v4.glb", "preview": "res://assets/ui/garage_card_irontrail_v1.png", "description": "Storm-gray performance truck. Tall stance, broad shoulders, and a full cargo bed.", "stats": "ACCEL  6   SPEED  7   GRIP  10", "tuning": {"acceleration": 29.0, "max_speed": 155.0, "boosted_max_speed": 190.0, "steering_rate": 1.58, "normal_grip": 10.6, "drift_grip": 3.4, "boost_capacity": 135.0}},
]

var car: ArcadeCar
var race: RaceManager
var recorder: GhostRecorder
var hud: RaceHUD
var chase_camera: Camera3D
var chase_camera_rig: Node3D
var first_person_camera: Camera3D
var rain_rig: Node3D
var rain_drops: Array[MeshInstance3D] = []
var checkpoints: Array[RaceCheckpoint] = []
var boost_camera_kick := false
var profile: Dictionary
var reference_best_ms := 0
var started := false
var paused := false
var comfort_camera := false
var road_arrow_texture: Texture2D
var weather_environment: Environment
var reduced_effects := false
var first_person_mode := false
var tail_light_materials: Array[StandardMaterial3D] = []
var boost_flames: Array[MeshInstance3D] = []
var wheel_rigs: Array[Node3D] = []
var wheel_rest_positions: Array[Vector3] = []
var road_spray: Array[MeshInstance3D] = []
var road_spray_materials: Array[StandardMaterial3D] = []
var finish_lights: Array[OmniLight3D] = []
var tunnel_start := Vector3.ZERO
var tunnel_end := Vector3.ZERO
var wet_asphalt_texture: Texture2D
var wet_streetscape_texture: Texture2D
var building_facade_texture: Texture2D
var historic_restaurant_facade_texture: Texture2D
var mixed_use_facade_textures: Array[Texture2D] = []
var building_facade_textures: Array[Texture2D] = []
var landmark_art_textures: Array[Texture2D] = []
var streetlife_facade_textures: Array[Texture2D] = []
var building_window_shader: Shader
var hero_car_visual: Node3D
var selected_vehicle_index := 0
var garage_open := false
var last_sector_split_ms := 0
var sector_number := 1
var off_route_seconds := 0.0
var active_omni_light_count := 0
var performance_sample_seconds := 0.0

# Compact descending route: Crown Hill S-curve, tunnel, Harborfront, Blackwater Docks.
var route := [Vector3(0, 0, 66), Vector3(-42, -0.8, -115), Vector3(-76, -1.5, -235), Vector3(-20, -2.1, -360), Vector3(68, -2.8, -505), Vector3(140, -4, -820), Vector3(100, -5, -1050), Vector3(-150, -6, -1200), Vector3(-100, -7, -1450), Vector3(-80, -8, -1660), Vector3(40, -9, -1860), Vector3(180, -10, -2050), Vector3(260, -11, -2250), Vector3(200, -11, -2450), Vector3(80, -12, -2650), Vector3(-20, -13, -2810), Vector3(-125, -13.7, -2970), Vector3(-45, -14.3, -3130), Vector3(72, -14.8, -3290), Vector3(160, -15, -3600), Vector3(90, -16, -3800), Vector3(-60, -16, -4000), Vector3(0, -16, -4200)]
var checkpoint_route_indices: Array[int] = [4, 6, 8, 10, 12, 14, 16, 18, 20, 22]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	road_arrow_texture = load("res://assets/ui/road_turn_arrow.svg") as Texture2D
	wet_asphalt_texture = load("res://assets/textures/wet_asphalt_v1.png") as Texture2D
	building_facade_texture = load("res://assets/textures/rainline_building_facade_v1.png") as Texture2D
	historic_restaurant_facade_texture = load("res://assets/textures/rainline_historic_restaurant_facade_v1.png") as Texture2D
	mixed_use_facade_textures = [
		historic_restaurant_facade_texture,
		load("res://assets/textures/rainline_art_deco_hotel_facade_v1.png") as Texture2D,
		load("res://assets/textures/rainline_food_hall_facade_v1.png") as Texture2D,
		load("res://assets/textures/rainline_bookstore_facade_v1.png") as Texture2D,
		load("res://assets/textures/rainline_record_venue_facade_v1.png") as Texture2D,
		load("res://assets/textures/rainline_brewery_facade_v1.png") as Texture2D,
		load("res://assets/textures/rainline_cinema_facade_v1.png") as Texture2D,
		load("res://assets/textures/rainline_market_hall_facade_v1.png") as Texture2D,
		load("res://assets/textures/rainline_seafood_facade_v1.png") as Texture2D,
		load("res://assets/textures/rainline_noodle_house_facade_v1.png") as Texture2D,
		load("res://assets/textures/rainline_coworking_loft_facade_v1.png") as Texture2D,
		load("res://assets/textures/rainline_florist_facade_v1.png") as Texture2D,
		load("res://assets/textures/rainline_bakery_facade_v1.png") as Texture2D,
		load("res://assets/textures/rainline_bike_outdoor_facade_v1.png") as Texture2D,
		load("res://assets/textures/rainline_jazz_lounge_facade_v1.png") as Texture2D,
	]
	building_facade_textures = [
		load("res://assets/textures/building_curtainwall_v1.png") as Texture2D,
		load("res://assets/textures/building_historic_brick_v1.png") as Texture2D,
		load("res://assets/textures/building_industrial_v1.png") as Texture2D,
		building_facade_texture,
	]
	landmark_art_textures = [
		load("res://assets/textures/landmark_observation_tower_v1.png") as Texture2D,
		load("res://assets/textures/landmark_market_hall_v1.png") as Texture2D,
		load("res://assets/textures/landmark_glass_museum_v1.png") as Texture2D,
		load("res://assets/textures/landmark_cultural_district_v1.png") as Texture2D,
		load("res://assets/textures/landmark_waterfront_civic_v1.png") as Texture2D,
	]
	wet_streetscape_texture = load("res://assets/textures/wet_streetscape_surface_v2.png") as Texture2D
	streetlife_facade_textures = [
		load("res://assets/textures/facade_night_restaurant_v1.png") as Texture2D,
		load("res://assets/textures/facade_mixed_retail_v1.png") as Texture2D,
		load("res://assets/textures/facade_storefront_district_v1.png") as Texture2D,
	]
	profile = SaveService.load_profile()
	reduced_effects = str(profile.get("settings", {}).get("graphics", "showcase")) == "performance"
	first_person_mode = bool(profile.get("settings", {}).get("first_person_camera", false))
	comfort_camera = bool(profile.get("settings", {}).get("comfort_camera", false))
	selected_vehicle_index = clampi(int(profile.get("settings", {}).get("selected_vehicle", 0)), 0, VEHICLES.size() - 1)
	reference_best_ms = int(profile.get("best_times_ms", {}).get(str(EVENT.event_id), 0))
	_build_environment()
	_apply_graphics_preset()
	_build_race()
	_build_route()
	_build_car()
	car.recovery_floor_y = route[-1].y - 40.0
	_finish_race_setup()
	_build_hud()
	hud.show_title()
	hud.set_audio_note(AudioService.muted)

func _process(delta: float) -> void:
	_update_cameras(delta)
	_update_rain_volume(delta)
	_update_vehicle_fx(delta)
	_update_finish_spectacle()
	_recover_if_off_route(delta)
	_update_audio_context()
	_update_performance_overlay(delta)
	if Input.is_action_just_pressed("pause") and started:
		paused = not paused
		get_tree().paused = paused
		if paused: AudioService.release_engine()
		hud.show_pause(paused)
		hud.set_prompt("")
		return
	if paused and Input.is_action_just_pressed("reset_car"):
		# Main continues while paused, so recovery remains available even though the car is paused.
		car.reset_to_safe_position()
		paused = false
		get_tree().paused = false
		hud.show_pause(false)
		hud.set_status("RECOVERED AT LAST GATE")
		return
	if Input.is_action_just_pressed("mute_audio"):
		AudioService.toggle_mute()
		hud.set_audio_note(AudioService.muted)
		hud.set_status("AUDIO %s" % ("MUTED" if AudioService.muted else "ON"))
	if Input.is_action_just_pressed("comfort_camera"):
		comfort_camera = not comfort_camera
		_save_setting("comfort_camera", comfort_camera)
		hud.set_status("COMFORT CAMERA %s" % ("ON" if comfort_camera else "OFF"))
	if Input.is_action_just_pressed("toggle_camera"):
		_toggle_camera()
	if Input.is_action_just_pressed("graphics_preset"):
		reduced_effects = not reduced_effects
		_apply_graphics_preset()
		_save_setting("graphics", "performance" if reduced_effects else "showcase")
		hud.set_status("GRAPHICS: %s" % ("PERFORMANCE" if reduced_effects else "SHOWCASE"))
	if started and race != null and race.state == RaceManager.State.FINISHED and Input.is_action_just_pressed("reset_car"):
		get_tree().reload_current_scene()
		return
	if started and race != null and race.state == RaceManager.State.FINISHED and (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("throttle")):
		get_tree().reload_current_scene()
		return
	if not started:
		if garage_open:
			if Input.is_action_just_pressed("steer_left"):
				_select_vehicle(-1)
				return
			if Input.is_action_just_pressed("steer_right"):
				_select_vehicle(1)
				return
			if Input.is_action_just_pressed("pause"):
				_close_garage()
				return
			if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("throttle"):
				_start_run()
				return
		elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("throttle"):
			_open_garage()
			return
	if race != null and race.state == RaceManager.State.RACING:
		hud.time.text = _format_time(race.elapsed_ms())
		hud.checkpoint.text = "CHECKPOINT %d / %d" % [race.current_checkpoint + 1, race.checkpoint_count]
		hud.update_minimap(car.global_position, race.current_checkpoint)
		_update_best_comparison()
		_update_route_guidance()

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("06101e")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("344765")
	environment.ambient_light_energy = 0.95
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = true
	environment.glow_intensity = 0.85
	environment.fog_enabled = true
	environment.fog_light_color = Color("203b59")
	environment.fog_density = 0.0025
	weather_environment = environment
	var world := WorldEnvironment.new(); world.environment = environment; add_child(world)
	var moon := DirectionalLight3D.new(); moon.light_color = Color("a6c9ef"); moon.light_energy = 1.15; moon.rotation_degrees = Vector3(-55, -30, 0); add_child(moon)
	_add_lamp(Vector3(0, 8, 8), Color("ff4f98"), 18.0)
	_add_rain()

func _build_route() -> void:
	for i in range(route.size() - 1):
		_add_road_segment(route[i], route[i + 1], i)
		if i < route.size() - 1: _dress_district(i, route[i])
	for i in range(1, route.size() - 1):
		_add_junction_pad(route[i])
		_add_ground_turn_arrow(i)
	_add_tunnel(route[12], route[13])
	_add_boost_strip(10, 0.55, 32.0, "HARBOR SURGE")
	_add_boost_strip(19, 0.48, 38.0, "DOCKYARD SURGE")
	_add_seattle_skyline_landmarks()
	_add_route_set_pieces()
	_add_hero_street_blocks()
	_add_finish_spectacle()
	for i in range(checkpoint_route_indices.size()): _add_checkpoint(route[checkpoint_route_indices[i]], i)
	if not checkpoints.is_empty(): checkpoints[0].set_active(true)

func _add_road_segment(a: Vector3, b: Vector3, index: int) -> void:
	var segment := StaticBody3D.new(); segment.name = "WetRoad"
	var delta := b - a; var length := delta.length(); segment.position = (a + b) * 0.5 - Vector3(0, 0.5, 0)
	# Align local -Z to the next route point so every road slab follows the descent.
	segment.look_at_from_position(segment.position, b, Vector3.UP)
	var mesh := MeshInstance3D.new(); var box := BoxMesh.new(); box.size = Vector3(18, 1, length + 2); mesh.mesh = box; mesh.material_override = _wet_road_material(Vector3(2.0, maxf(2.0, length / 24.0), 1.0)); segment.add_child(mesh)
	# Decorative road meshes overlap slightly to hide seams.  The physical slabs
	# must not: overlapping slopes at the first few bends make CharacterBody3D
	# alternate floors and produce a visibly vibrating chase camera.
	var collision := CollisionShape3D.new(); var shape := BoxShape3D.new(); shape.size = Vector3(18, 1, length + 0.08); collision.shape = shape; segment.add_child(collision); add_child(segment)
	for distance in range(10, int(length), 18):
		var lane_dash := MeshInstance3D.new(); var dash_mesh := BoxMesh.new(); dash_mesh.size = Vector3(0.28, 0.04, 7.0); lane_dash.mesh = dash_mesh; lane_dash.material_override = _lane_material(); lane_dash.position = Vector3(0, 0.53, -length * 0.5 + distance); segment.add_child(lane_dash)
	if index % 2 == 0:
		for puddle_fraction in [0.32, 0.71]:
			var puddle := MeshInstance3D.new(); puddle.name = "WetPuddle"
			var puddle_mesh := PlaneMesh.new(); puddle_mesh.size = Vector2(5.5, 10.0); puddle.mesh = puddle_mesh; puddle.position = Vector3(-3.4 if puddle_fraction < 0.5 else 3.4, 0.535, -length * 0.5 + length * puddle_fraction)
			var puddle_material := _material(Color(0.08, 0.38, 0.58, 0.42), 0.05, 0.9, true); puddle_material.clearcoat_enabled = true; puddle_material.clearcoat_roughness = 0.08; puddle.material_override = puddle_material; segment.add_child(puddle)
	var sidewalk_material := _material(Color("40505d"), 0.58, 0.20)
	# Route supports should read as dark concrete infrastructure, never as huge
	# blue building boxes with a stretched facade texture.
	var retaining_material := _material(Color("1a2026"), 0.76, 0.22)
	# Keep street furniture clear of junctions.  At a sharp change in direction,
	# a full-length sidewalk or retaining wall can otherwise cut across the next
	# slab even though it belongs to the previous segment.
	var edge_length := maxf(2.0, length - 18.0)
	for side in [-1, 1]:
		# Sidewalks and walls turn the route from isolated slabs into a supported city street.
		var sidewalk := MeshInstance3D.new(); sidewalk.name = "WetSidewalk"; var sidewalk_mesh := BoxMesh.new(); sidewalk_mesh.size = Vector3(3.1, 0.22, edge_length); sidewalk.mesh = sidewalk_mesh; sidewalk.material_override = sidewalk_material; sidewalk.position = Vector3(side * 10.7, 0.40, 0); segment.add_child(sidewalk)
		var sidewalk_collision := CollisionShape3D.new(); var sidewalk_shape := BoxShape3D.new(); sidewalk_shape.size = Vector3(3.1, 0.22, edge_length); sidewalk_collision.shape = sidewalk_shape; sidewalk_collision.position = sidewalk.position; segment.add_child(sidewalk_collision)
		var curb := MeshInstance3D.new(); curb.name = "RoadCurb"; var curb_mesh := BoxMesh.new(); curb_mesh.size = Vector3(0.22, 0.38, edge_length); curb.mesh = curb_mesh; curb.material_override = _material(Color("d3b268"), 0.42, 0.24); curb.position = Vector3(side * 9.28, 0.45, 0); segment.add_child(curb)
		var wall := MeshInstance3D.new(); wall.name = "RoadRetainingWall"; var wall_mesh := BoxMesh.new(); wall_mesh.size = Vector3(0.7, 9.0, edge_length); wall.mesh = wall_mesh; wall.material_override = retaining_material; wall.position = Vector3(side * 12.42, -4.15, 0); segment.add_child(wall)
		var wall_collision := CollisionShape3D.new(); var wall_shape := BoxShape3D.new(); wall_shape.size = Vector3(0.7, 9.0, edge_length); wall_collision.shape = wall_shape; wall_collision.position = wall.position; segment.add_child(wall_collision)
		var rail := MeshInstance3D.new(); var rail_mesh := BoxMesh.new(); rail_mesh.size = Vector3(0.35, 0.8, edge_length); rail.mesh = rail_mesh; rail.material_override = _material(Color("f0b45c"), 0.55, 0.35); rail.position.x = side * 9.1; segment.add_child(rail)
		var drain_material := _material(Color("07131d"), 0.40, 0.82)
		for distance in range(-int(edge_length * 0.5) + 5, int(edge_length * 0.5), 15):
			var drain := MeshInstance3D.new(); drain.name = "CurbDrain"; var drain_mesh := BoxMesh.new(); drain_mesh.size = Vector3(0.72, 0.025, 1.25); drain.mesh = drain_mesh; drain.material_override = drain_material; drain.position = Vector3(side * 8.88, 0.535, distance); segment.add_child(drain)
		for distance in range(14, int(length - 10.0), 24):
			var chevron := MeshInstance3D.new(); var chevron_mesh := BoxMesh.new(); chevron_mesh.size = Vector3(0.18, 1.25, 2.2); chevron.mesh = chevron_mesh; chevron.material_override = _route_material(); chevron.position = Vector3(side * 8.75, 1.25, -length * 0.5 + distance); chevron.rotation.y = deg_to_rad(35.0 * -side); segment.add_child(chevron)

func _dress_district(index: int, anchor: Vector3) -> void:
	var colors := [Color("1c2830"), Color("34333a"), Color("3b302e"), Color("243b3a"), Color("40312b"), Color("292b35")]
	var road_direction: Vector3 = route[index + 1] - anchor
	road_direction.y = 0.0
	road_direction = road_direction.normalized()
	var side_direction: Vector3 = Vector3(-road_direction.z, 0, road_direction.x)
	var segment_length: float = anchor.distance_to(route[index + 1])
	var landmark_plazas := {1: [-1, 0.72], 3: [1, 0.50], 4: [-1, 0.30], 5: [1, 0.46], 7: [-1, 0.42], 8: [1, 0.58], 10: [-1, 0.48], 12: [1, 0.62], 14: [-1, 0.44], 18: [1, 0.52]}
	# Dense street walls read as a city; varied, smaller footprints prevent a row
	# of identical office blocks.
	# Three-times denser than the prior street wall: compact footprints create a
	# continuous downtown rather than isolated towers.
	# Restore the compact downtown street wall, while reserving the costly
	# rooftop/storefront modeling for alternate buildings.  Every added mass
	# still has its full facade shader and collision, so the city reads dense
	# without restoring the old micro-mesh draw-call spike.
	var building_count: int = clampi(roundi(segment_length / 58.0) * 3, 12, 20)
	for side in [-1, 1]:
		for n in range(building_count):
			var footprint := 6.5 + float((index * 7 + n * 5) % 9)
			var tower_size := Vector3(footprint, 9.0 + float((index * 11 + n * 7) % 31), 7.5 + float((index * 3 + n * 4) % 10))
			var distance_along: float = lerpf(7.0, segment_length - 7.0, float(n) / maxf(1.0, float(building_count - 1)))
			var along: Vector3 = road_direction * distance_along
			var plaza: Array = landmark_plazas.get(index, [])
			var is_landmark_plaza: bool = plaza.size() == 2 and side == int(plaza[0]) and absf(float(n) / maxf(1.0, float(building_count - 1)) - float(plaza[1])) < 0.14
			if is_landmark_plaza:
				continue
			var offset: Vector3 = side_direction * side * (12.35 + tower_size.x * 0.5)
			# Historic restaurants and market buildings break the repeated tower
			# rhythm with a genuinely low-rise, occupied street frontage.
			var historic_mixed_use := posmod(index * 5 + n * 3 + side, 4) == 0
			if historic_mixed_use:
				tower_size.y = clampf(tower_size.y, 15.0, 20.0)
			var building_position := anchor + along + offset + Vector3.UP * tower_size.y * 0.5
			var detailed_building := n % 2 == 0
			if historic_mixed_use:
				_add_historic_mixed_use(building_position, tower_size, index + n)
			else:
				_add_city_building(building_position, tower_size, colors[index % colors.size()], index + n + (0 if side < 0 else 3), detailed_building)
			# Do not use the generated facade images as freestanding signs. The
			# modeled building frontage below reads as architecture at speed; a flat
			# panel in front of the mass reads as a picture on a stand.
			# Spread a handful of real lights across the entire course instead of
			# spending the whole Forward+ light budget in the opening blocks.
			# Window grids and route beacons provide the remaining visible light.
			if index % 3 == 0 and n == building_count / 2 and side == 1:
				_add_lamp(anchor + along + side_direction * side * 7.5 + Vector3.UP * 5.0, Color("ffc66e") if index < 3 else Color("48ccff"), 8.0)
			if detailed_building and n % 3 == 0: _add_sidewalk_life(anchor + along, road_direction, side_direction, side, index + n)
	if index == 16:
		for n in range(5):
			# Keep the dock dressing well outside the 18 m driving lane.
			_add_solid_block("DockContainer", anchor + road_direction * (18 + n * 8) + side_direction * 28 + Vector3.UP * 1.5, Vector3(5, 3, 12), _material(Color("b64d3f") if n % 2 == 0 else Color("4b4d51"), 0.5, 0.45))
	var district_names := {1: "CROWN HILL", 9: "RAINLINE TUNNEL", 14: "HARBORFRONT", 18: "BLACKWATER DOCKS"}
	if district_names.has(index):
		_add_district_marker(str(district_names[index]), anchor + road_direction * minf(42.0, segment_length * 0.35) + side_direction * 14.0 + Vector3.UP * 8.0, Color("6befff") if index < 14 else Color("ffb152"))

func _add_district_marker(label_text: String, position: Vector3, color: Color) -> void:
	var marker := Label3D.new(); marker.name = "DistrictMarker_" + label_text; marker.text = label_text; marker.position = position; marker.font_size = 72; marker.outline_size = 8; marker.modulate = color; marker.pixel_size = 0.012; marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED; marker.no_depth_test = false; add_child(marker)

func _add_seattle_skyline_landmarks() -> void:
	# Put landmarks beside their associated route sections. They remain
	# non-colliding, but are no longer buried behind a generic street wall.
	# Each landmark has a reserved sidewalk plaza. Its centre is beyond the
	# roadway plus the landmark's own half-width, preventing visual road overlap.
	_add_space_needle(_route_side_position(1, 0.72, -1, 23.0))
	_add_experience_music_project(_route_side_position(3, 0.50, 1, 28.0))
	_add_chihuly_glass_museum(_route_side_position(4, 0.30, -1, 25.0))
	_add_pike_place_market(_route_side_position(5, 0.46, 1, 28.0))
	_add_seattle_central_library(_route_side_position(7, 0.42, -1, 26.0))
	_add_smith_tower(_route_side_position(8, 0.58, 1, 22.0))
	_add_seattle_spheres(_route_side_position(10, 0.48, -1, 25.0))
	_add_seattle_great_wheel(_route_side_position(12, 0.62, 1, 27.0))
	_add_columbia_center(_route_side_position(14, 0.44, -1, 25.0))
	_add_lumen_field(_route_side_position(18, 0.52, 1, 34.0))

func _route_side_position(segment_index: int, fraction: float, side: int, offset: float) -> Vector3:
	var start: Vector3 = route[segment_index]
	var end: Vector3 = route[segment_index + 1]
	var direction: Vector3 = end - start
	direction.y = 0.0
	direction = direction.normalized()
	var side_direction := Vector3(-direction.z, 0, direction.x)
	return start.lerp(end, fraction) + side_direction * float(side) * offset

func _add_space_needle(position: Vector3) -> void:
	var landmark := Node3D.new(); landmark.name = "SeattleSpaceNeedle"; landmark.position = position; landmark.scale = Vector3.ONE * 0.65; add_child(landmark)
	var steel := _material(Color("778da5"), 0.24, 0.82)
	var glass := _material(Color("132d48"), 0.12, 0.6); glass.emission_enabled = true; glass.emission = Color("4fceff"); glass.emission_energy_multiplier = 1.2
	_add_landmark_cylinder(landmark, "NeedleSpire", Vector3(0, 48, 0), 1.0, 1.8, 90.0, steel)
	_add_landmark_cylinder(landmark, "NeedleObservationDeck", Vector3(0, 75, 0), 10.0, 7.5, 3.5, glass)
	_add_landmark_cylinder(landmark, "NeedleRoof", Vector3(0, 78.2, 0), 6.4, 8.4, 2.4, steel)
	for angle in [0.0, 120.0, 240.0]:
		var leg := MeshInstance3D.new(); var leg_mesh := CylinderMesh.new(); leg_mesh.top_radius = 0.44; leg_mesh.bottom_radius = 0.72; leg_mesh.height = 33.0; leg.mesh = leg_mesh; leg.material_override = steel; leg.position = Vector3(sin(deg_to_rad(angle)) * 8.0, 16.5, cos(deg_to_rad(angle)) * 8.0); leg.rotation_degrees.z = 16.0 * cos(deg_to_rad(angle)); landmark.add_child(leg)
	_add_landmark_art(landmark, 0, Vector3(0, 22, 0), Vector2(19, 11), Color("4fceff"))
	_add_landmark_label("SPACE NEEDLE", position + Vector3(0, 81, 0), Color("72dcff"))

func _add_smith_tower(position: Vector3) -> void:
	var landmark := Node3D.new(); landmark.name = "SeattleSmithTower"; landmark.position = position; landmark.scale = Vector3.ONE * 0.65; add_child(landmark)
	var stone := _material(Color("344453"), 0.65, 0.38)
	var crown := _material(Color("c29b5e"), 0.35, 0.65); crown.emission_enabled = true; crown.emission = Color("eab66e"); crown.emission_energy_multiplier = 1.0
	_add_landmark_box(landmark, "SmithTowerBase", Vector3(0, 22, 0), Vector3(18, 44, 18), stone)
	_add_landmark_box(landmark, "SmithTowerCrown", Vector3(0, 47, 0), Vector3(12, 8, 12), crown)
	var roof := MeshInstance3D.new(); var roof_mesh := PrismMesh.new(); roof_mesh.left_to_right = 0.5; roof_mesh.size = Vector3(13, 10, 13); roof.mesh = roof_mesh; roof.material_override = crown; roof.position = Vector3(0, 56, 0); landmark.add_child(roof)
	_add_landmark_art(landmark, 4, Vector3(0, 20, -9.1), Vector2(17, 22), Color("ffb96b"), false)
	_add_landmark_label("SMITH TOWER", position + Vector3(0, 62, 0), Color("ffc675"))

func _add_columbia_center(position: Vector3) -> void:
	var landmark := Node3D.new(); landmark.name = "SeattleColumbiaCenter"; landmark.position = position; landmark.scale = Vector3.ONE * 0.65; add_child(landmark)
	var facade := _building_facade_material(Color("172d47"), Vector3(24, 80, 20))
	var crown := _material(Color("0d1f36"), 0.28, 0.72)
	_add_landmark_box(landmark, "ColumbiaCenterMain", Vector3(0, 42, 0), Vector3(24, 84, 20), facade)
	_add_landmark_box(landmark, "ColumbiaCenterSetback", Vector3(0, 82, 0), Vector3(17, 12, 15), crown)
	_add_landmark_box(landmark, "ColumbiaCenterRoof", Vector3(0, 91, 0), Vector3(11, 7, 11), crown)
	_add_landmark_art(landmark, 4, Vector3(0, 38, -10.1), Vector2(22, 28), Color("70d8ff"), false)
	_add_landmark_label("COLUMBIA CENTER", position + Vector3(0, 98, 0), Color("79cfff"))

func _add_experience_music_project(position: Vector3) -> void:
	var landmark := Node3D.new(); landmark.name = "ExperienceMusicProject"; landmark.position = position; landmark.scale = Vector3.ONE * 0.65; add_child(landmark)
	var base := _material(Color("1a2130"), 0.42, 0.72)
	var steel_blue := _material(Color("225a85"), 0.20, 0.88)
	var copper := _material(Color("b65b30"), 0.24, 0.84)
	var violet := _material(Color("6c2f88"), 0.22, 0.82)
	_add_landmark_box(landmark, "EMPPlinth", Vector3(0, 3, 0), Vector3(30, 6, 22), base)
	_add_landmark_sphere(landmark, "EMPBlueShell", Vector3(-7, 9, 0), Vector3(13, 10, 16), steel_blue)
	_add_landmark_sphere(landmark, "EMPCopperShell", Vector3(3, 10, -2), Vector3(15, 12, 14), copper)
	_add_landmark_sphere(landmark, "EMPVioletShell", Vector3(9, 8, 4), Vector3(10, 8, 12), violet)
	_add_landmark_art(landmark, 3, Vector3(0, 10, -11.1), Vector2(28, 15), Color("8beaff"), false)
	_add_landmark_mesh(landmark, CULTURAL_PAVILION_SCENE, Vector3(0, 0, -7.0))
	_add_landmark_label("EXPERIENCE MUSIC PROJECT", position + Vector3(0, 18, 0), Color("94dfff"))

func _add_pike_place_market(position: Vector3) -> void:
	var landmark := Node3D.new(); landmark.name = "PikePlaceMarket"; landmark.position = position; landmark.scale = Vector3.ONE * 0.65; add_child(landmark)
	var brick := _material(Color("4f3032"), 0.72, 0.18)
	var roof := _material(Color("0e1c28"), 0.42, 0.7)
	var sign := _material(Color("d42c2c"), 0.18, 0.48); sign.emission_enabled = true; sign.emission = Color("ff3c32"); sign.emission_energy_multiplier = 2.0
	_add_landmark_box(landmark, "PikePlaceHall", Vector3(0, 7, 0), Vector3(24, 14, 11), brick)
	_add_landmark_box(landmark, "PikePlaceAwning", Vector3(0, 13, -1.5), Vector3(27, 1.2, 5), roof)
	_add_landmark_box(landmark, "PikePlaceMarquee", Vector3(0, 15.5, -5.8), Vector3(20, 4, 0.4), sign)
	_add_landmark_art(landmark, 1, Vector3(0, 7.2, -5.65), Vector2(22, 12), Color("ff9b5c"), false)
	_add_landmark_mesh(landmark, MARKET_BLOCK_SCENE, Vector3(0, 0, -7.0))
	_add_landmark_label("PIKE PLACE MARKET", position + Vector3(0, 15.5, -6.2), Color("ffd0aa"))

func _add_chihuly_glass_museum(position: Vector3) -> void:
	var landmark := Node3D.new(); landmark.name = "ChihulyGlassMuseum"; landmark.position = position; landmark.scale = Vector3.ONE * 0.65; add_child(landmark)
	var gallery := _material(Color("13202c"), 0.36, 0.72)
	var cyan_glass := _material(Color("1bcaf0"), 0.06, 0.25); cyan_glass.emission_enabled = true; cyan_glass.emission = Color("28dcff"); cyan_glass.emission_energy_multiplier = 2.5
	var amber_glass := _material(Color("ff8738"), 0.08, 0.22); amber_glass.emission_enabled = true; amber_glass.emission = Color("ff9a42"); amber_glass.emission_energy_multiplier = 2.6
	_add_landmark_box(landmark, "ChihulyGallery", Vector3(0, 4, 0), Vector3(25, 8, 16), gallery)
	for index in range(7):
		var x := -8.0 + float(index) * 2.7
		var glass := MeshInstance3D.new(); glass.name = "ChihulyGlassForm"; var mesh := TorusMesh.new(); mesh.inner_radius = 0.38; mesh.outer_radius = 1.0; glass.mesh = mesh; glass.material_override = cyan_glass if index % 2 == 0 else amber_glass; glass.position = Vector3(x, 10.0 + float(index % 3) * 1.5, -1.8 + float(index % 2) * 2.0); glass.rotation_degrees = Vector3(index * 19.0, index * 37.0, index * 24.0); landmark.add_child(glass)
	_add_landmark_art(landmark, 2, Vector3(0, 7.6, -8.1), Vector2(23, 13), Color("48dfc2"), false)
	_add_landmark_label("CHIHULY GLASS MUSEUM", position + Vector3(0, 15, 0), Color("ffbf71"))

func _add_seattle_central_library(position: Vector3) -> void:
	var landmark := Node3D.new(); landmark.name = "SeattleCentralLibrary"; landmark.position = position; landmark.scale = Vector3.ONE * 0.65; add_child(landmark)
	var glass := _material(Color("4a8497"), 0.10, 0.72); glass.emission_enabled = true; glass.emission = Color("3fa7c3"); glass.emission_energy_multiplier = 0.75
	var steel := _material(Color("243845"), 0.34, 0.84)
	for layer in range(4):
		var level := MeshInstance3D.new(); level.name = "LibraryGlassStack"; var mesh := BoxMesh.new(); mesh.size = Vector3(27.0 - layer * 3.0, 8.0, 21.0 - layer * 2.0); level.mesh = mesh; level.material_override = glass if layer % 2 == 0 else steel; level.position = Vector3(float(layer - 1) * 2.5, 4.0 + layer * 7.6, 0); level.rotation_degrees.z = -8.0 if layer % 2 == 0 else 6.0; landmark.add_child(level)
	_add_landmark_art(landmark, 3, Vector3(0, 14, -10.6), Vector2(25, 19), Color("76e4ff"), false)
	_add_landmark_label("SEATTLE CENTRAL LIBRARY", position + Vector3(0, 36, 0), Color("83e6ff"))

func _add_seattle_spheres(position: Vector3) -> void:
	var landmark := Node3D.new(); landmark.name = "SeattleSpheres"; landmark.position = position; landmark.scale = Vector3.ONE * 0.65; add_child(landmark)
	var glass := _material(Color("276e7c"), 0.05, 0.42); glass.emission_enabled = true; glass.emission = Color("43d7b2"); glass.emission_energy_multiplier = 1.15
	var base := _material(Color("17242c"), 0.42, 0.72)
	_add_landmark_box(landmark, "SpheresPlinth", Vector3(0, 2.0, 0), Vector3(27, 4, 18), base)
	_add_landmark_sphere(landmark, "SphereOne", Vector3(-7, 9, 0), Vector3(12, 12, 12), glass)
	_add_landmark_sphere(landmark, "SphereTwo", Vector3(4, 11, -2), Vector3(15, 15, 15), glass)
	_add_landmark_sphere(landmark, "SphereThree", Vector3(10, 7, 4), Vector3(9, 9, 9), glass)
	_add_landmark_art(landmark, 3, Vector3(0, 10, -9.1), Vector2(25, 15), Color("6fffd2"), false)
	_add_landmark_label("SEATTLE SPHERES", position + Vector3(0, 20, 0), Color("6fffd2"))

func _add_seattle_great_wheel(position: Vector3) -> void:
	var landmark := Node3D.new(); landmark.name = "SeattleGreatWheel"; landmark.position = position; landmark.scale = Vector3.ONE * 0.65; add_child(landmark)
	var wheel_material := _material(Color("57d5ff"), 0.12, 0.62); wheel_material.emission_enabled = true; wheel_material.emission = Color("62ddff"); wheel_material.emission_energy_multiplier = 2.1
	var support := _material(Color("2e4557"), 0.38, 0.76)
	var wheel := MeshInstance3D.new(); wheel.name = "GreatWheelRing"; var ring := TorusMesh.new(); ring.inner_radius = 10.5; ring.outer_radius = 11.2; wheel.mesh = ring; wheel.material_override = wheel_material; wheel.position = Vector3(0, 16, 0); wheel.rotation_degrees.x = 90.0; landmark.add_child(wheel)
	for x in [-9.0, 9.0]: _add_landmark_box(landmark, "GreatWheelSupport", Vector3(x, 7, 0), Vector3(0.8, 14, 0.8), support)
	_add_landmark_box(landmark, "GreatWheelPier", Vector3(0, 1.5, 0), Vector3(28, 3, 9), support)
	_add_landmark_art(landmark, 4, Vector3(0, 16, -0.4), Vector2(28, 19), Color("86e8ff"))
	_add_landmark_mesh(landmark, WATERFRONT_CIVIC_SCENE, Vector3(0, 0, -8.0))
	_add_landmark_label("SEATTLE GREAT WHEEL", position + Vector3(0, 30, 0), Color("86e8ff"))

func _add_lumen_field(position: Vector3) -> void:
	var landmark := Node3D.new(); landmark.name = "LumenField"; landmark.position = position; landmark.scale = Vector3.ONE * 0.65; add_child(landmark)
	var concrete := _material(Color("283846"), 0.64, 0.32)
	var lights := _material(Color("42c8ff"), 0.12, 0.54); lights.emission_enabled = true; lights.emission = Color("43d0ff"); lights.emission_energy_multiplier = 1.5
	_add_landmark_cylinder(landmark, "StadiumLowerBowl", Vector3(0, 6, 0), 19.0, 22.0, 12.0, concrete)
	_add_landmark_cylinder(landmark, "StadiumUpperBowl", Vector3(0, 13, 0), 16.0, 19.0, 5.0, lights)
	_add_landmark_box(landmark, "StadiumCanopy", Vector3(0, 18, 0), Vector3(42, 1.0, 31), concrete)
	_add_landmark_art(landmark, 4, Vector3(0, 11, -15.6), Vector2(38, 18), Color("72dbff"), false)
	_add_landmark_label("LUMEN FIELD", position + Vector3(0, 22, 0), Color("72dbff"))

func _add_landmark_box(parent: Node3D, label: String, local_position: Vector3, size: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new(); mesh_instance.name = label; var mesh := BoxMesh.new(); mesh.size = size; mesh_instance.mesh = mesh; mesh_instance.material_override = material; mesh_instance.position = local_position; parent.add_child(mesh_instance)

func _add_landmark_mesh(parent: Node3D, scene: PackedScene, local_position: Vector3) -> void:
	var landmark_mesh := scene.instantiate() as Node3D
	landmark_mesh.name = "BlenderLandmark"
	landmark_mesh.position = local_position
	parent.add_child(landmark_mesh)

func _add_landmark_cylinder(parent: Node3D, label: String, local_position: Vector3, top_radius: float, bottom_radius: float, height: float, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new(); mesh_instance.name = label; var mesh := CylinderMesh.new(); mesh.top_radius = top_radius; mesh.bottom_radius = bottom_radius; mesh.height = height; mesh_instance.mesh = mesh; mesh_instance.material_override = material; mesh_instance.position = local_position; parent.add_child(mesh_instance)

func _add_landmark_sphere(parent: Node3D, label: String, local_position: Vector3, size: Vector3, material: Material) -> void:
	var mesh_instance := MeshInstance3D.new(); mesh_instance.name = label; var mesh := SphereMesh.new(); mesh.radius = 0.5; mesh.height = 1.0; mesh_instance.mesh = mesh; mesh_instance.material_override = material; mesh_instance.position = local_position; mesh_instance.scale = size; parent.add_child(mesh_instance)

func _add_landmark_label(label_text: String, position: Vector3, color: Color) -> void:
	var marker := Label3D.new(); marker.name = "Skyline_" + label_text; marker.text = label_text; marker.position = position; marker.font_size = 52; marker.outline_size = 6; marker.modulate = color; marker.pixel_size = 0.010; marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED; marker.no_depth_test = false; add_child(marker)

func _add_landmark_art(parent: Node3D, texture_index: int, local_position: Vector3, dimensions: Vector2, glow: Color, billboard := true) -> void:
	if texture_index < 0 or texture_index >= landmark_art_textures.size(): return
	var texture := landmark_art_textures[texture_index]
	if texture == null: return
	# The generated concept is reference material only. Rendering it as a flat
	# card reads as a painting, so landmarks remain structural mesh silhouettes.
	return

func _add_streetlife_facade(building_position: Vector3, building_size: Vector3, side_direction: Vector3, side: int, texture: Texture2D) -> void:
	# These are distinct restaurants/shops/venues at the pedestrian layer.  They
	# face the route but remain decorative so a busy city never narrows the course.
	if texture == null: return
	var roadward := -side_direction * float(side)
	# The art must sit beyond the backing mass, toward the street—not halfway
	# inside it—otherwise the generic box hides the generated facade at speed.
	var panel_position := building_position + roadward * (maxf(building_size.x, building_size.z) * 0.64 + 0.25) + Vector3.UP * (-building_size.y * 0.14)
	var panel := Node3D.new(); panel.name = "StreetlifeFacade"; panel.position = panel_position; panel.look_at_from_position(panel_position, panel_position + roadward, Vector3.UP); add_child(panel)
	var width := clampf(building_size.x * 0.88, 10.0, 19.0)
	var height := clampf(building_size.y * 0.48, 7.0, 15.0)
	_add_scene_prop(panel, "StreetlifeFrame", Vector3(0, 0, 0.16), Vector3(width + 0.7, height + 0.7, 0.22), _material(Color("07121c"), 0.26, 0.76))
	_add_modular_storefront(panel, width, height, posmod(roundi(building_position.x + building_position.z), 3))

func _add_hero_street_blocks() -> void:
	# A few deliberately close, detailed blocks guarantee the player passes real
	# street life instead of only seeing generated frontage in the distant skyline.
	if streetlife_facade_textures.is_empty(): return
	_add_hero_street_block(0, 0.62, -1, streetlife_facade_textures[2], "NIGHT MARKET")
	_add_hero_street_block(3, 0.60, 1, streetlife_facade_textures[0], "RAINLINE ROW")
	_add_hero_street_block(9, 0.50, -1, streetlife_facade_textures[1], "HARBOR ARCADE")
	_add_hero_street_block(17, 0.46, 1, streetlife_facade_textures[2], "DOCKSIDE DISTRICT")

func _add_hero_street_block(segment_index: int, fraction: float, side: int, texture: Texture2D, district: String) -> void:
	var center := _route_point(segment_index, fraction)
	var direction: Vector3 = route[segment_index + 1] - route[segment_index]; direction.y = 0.0; direction = direction.normalized()
	var block := _make_set_piece("HeroStreetBlock_" + district, center, center + direction)
	var frontage := STREETFRONT_SCENE.instantiate() as Node3D
	frontage.name = "BlenderStreetfront"
	frontage.position = Vector3(float(side) * 13.1, 0, 0)
	frontage.rotation.y = -PI * 0.5 * float(side)
	block.add_child(frontage)
	_configure_visual_lod(frontage, 240.0)
	var collision_body := StaticBody3D.new(); collision_body.name = "StreetfrontCollision"; collision_body.position = Vector3(float(side) * 13.1, 6.5, 0)
	var collision := CollisionShape3D.new(); var shape := BoxShape3D.new(); shape.size = Vector3(2.6, 13.0, 25.0); collision.shape = shape; collision_body.add_child(collision); block.add_child(collision_body)
	_add_scene_label(block, district, Vector3(float(side) * 8.9, 14.3, -7.0), Color("9eeaff"), 34)

func _add_modular_storefront(parent: Node3D, width: float, height: float, seed: int) -> void:
	var frame := _material(Color("10191f"), 0.35, 0.78)
	var glass := _material(Color("112d38"), 0.12, 0.52); glass.emission_enabled = true; glass.emission = Color("2b8295"); glass.emission_energy_multiplier = 0.52
	var awning := _material(Color("c8753f") if seed % 2 == 0 else Color("3e9db8"), 0.20, 0.36); awning.emission_enabled = true; awning.emission = awning.albedo_color; awning.emission_energy_multiplier = 0.7
	var bays := clampi(roundi(width / 2.5), 4, 8)
	var bay_width := width / float(bays)
	for bay in range(bays):
		var x := -width * 0.5 + bay_width * (float(bay) + 0.5)
		_add_scene_prop(parent, "StoreWindow", Vector3(x, 1.0, 0.02), Vector3(bay_width * 0.78, height * 0.62, 0.10), glass)
		_add_scene_prop(parent, "StoreAwning", Vector3(x, height * 0.40, 0.20), Vector3(bay_width * 0.92, 0.22, 0.42), awning)
		_add_scene_prop(parent, "StoreMullion", Vector3(x - bay_width * 0.42, 1.0, 0.11), Vector3(0.12, height * 0.86, 0.16), frame)
	_add_scene_prop(parent, "StoreCornice", Vector3(0, height * 0.47, 0.15), Vector3(width, 0.22, 0.25), frame)

func _add_sidewalk_life(anchor: Vector3, road_direction: Vector3, side_direction: Vector3, side: int, seed: int) -> void:
	var position := anchor + side_direction * float(side) * 10.75 + Vector3.UP * 0.58
	var prop := Node3D.new(); prop.name = "SidewalkLife"; prop.position = position; prop.look_at_from_position(position, position + road_direction, Vector3.UP); add_child(prop)
	var steel := _material(Color("1b2b35"), 0.42, 0.72)
	var concrete := _material(Color("46525b"), 0.72, 0.20)
	var leaf := _material(Color("163d35"), 0.70, 0.06)
	var warm := _material(Color("ffbf70"), 0.12, 0.25); warm.emission_enabled = true; warm.emission = Color("ffb55c"); warm.emission_energy_multiplier = 1.35
	match posmod(seed, 4):
		0:
			_add_scene_prop(prop, "Planter", Vector3(0, 0.55, 0), Vector3(1.7, 1.1, 1.15), concrete)
			_add_scene_prop(prop, "PlanterGreenery", Vector3(0, 1.45, 0), Vector3(1.28, 0.78, 0.88), leaf)
		1:
			_add_scene_prop(prop, "BusShelterPost", Vector3(0, 1.4, 0), Vector3(0.14, 2.8, 0.14), steel)
			_add_scene_prop(prop, "BusShelterRoof", Vector3(0, 2.72, 0), Vector3(2.5, 0.14, 1.1), steel)
			_add_scene_prop(prop, "BusShelterLight", Vector3(0, 2.55, -0.43), Vector3(1.5, 0.08, 0.06), warm)
		2:
			_add_scene_prop(prop, "FoodKiosk", Vector3(0, 1.25, 0), Vector3(2.0, 2.5, 1.35), steel)
			_add_scene_prop(prop, "KioskAwning", Vector3(0, 2.55, -0.7), Vector3(2.45, 0.24, 0.48), warm)
		_:
			_add_scene_prop(prop, "StreetBench", Vector3(0, 0.58, 0), Vector3(2.25, 0.22, 0.64), steel)
			_add_scene_prop(prop, "StreetBenchBack", Vector3(0, 1.0, 0.25), Vector3(2.25, 0.65, 0.14), steel)

func _add_solid_block(label: String, position: Vector3, size: Vector3, material: Material) -> void:
	var block := StaticBody3D.new(); block.name = label; block.position = position
	var visual := MeshInstance3D.new(); var mesh := BoxMesh.new(); mesh.size = size; visual.mesh = mesh; visual.material_override = material; block.add_child(visual)
	var collision := CollisionShape3D.new(); var shape := BoxShape3D.new(); shape.size = size; collision.shape = shape; block.add_child(collision)
	add_child(block)

func _add_city_building(position: Vector3, size: Vector3, tint: Color, variant: int, detailed := true) -> void:
	# The inset core is solid, while shallow exterior details remain clear of the route.
	var building := Node3D.new(); building.name = "SeattleBuilding"; building.position = position
	# A whole building now uses one finely scaled facade draw, rather than four
	# separate window planes. The grid density follows the building's scale so it
	# reads as real mullioned glazing, not oversized luminous tiles.
	var facade_grid := Vector2(maxf(12.0, maxf(size.x, size.z) * 1.18), clampf(size.y * 0.92, 18.0, 42.0))
	var facade := _window_grid_material(tint, variant, facade_grid)
	var base_visual := _add_building_visual(building, "FacadeBase", Vector3.ZERO, size, facade)
	# Use a slightly inset structural core for collision. This makes buildings
	# solid without allowing decorative frontage to clip across a tight turn.
	var collision_body := StaticBody3D.new(); collision_body.name = "BuildingCollision"
	var collision := CollisionShape3D.new(); var shape := BoxShape3D.new(); shape.size = Vector3(size.x * 0.72, size.y, size.z * 0.72); collision.shape = shape; collision_body.add_child(collision); building.add_child(collision_body)
	if not detailed:
		# These are inexpensive one-mesh skyline shells, so establish them well
		# before the player arrives instead of letting whole blocks pop in.
		base_visual.visibility_range_end = 280.0
		base_visual.visibility_range_end_margin = 90.0
		add_child(building)
		return
	# Each detailed block has a distinct, modeled street use. These are shallow
	# geometry, not pasted images, and use the existing near-field detail LOD.
	match posmod(variant, 4):
		0: _add_street_level_frontage(building, size, tint, variant)
		1: _add_cafe_frontage(building, size, variant)
		2: _add_diner_frontage(building, size, variant)
		_: _add_gallery_frontage(building, size, variant)
	var accent := _material(Color("1d6e91") if variant % 2 == 0 else Color("a15a38"), 0.25, 0.7); accent.emission_enabled = true; accent.emission = accent.albedo_color; accent.emission_energy_multiplier = 1.15
	var dark_glass := _material(Color("071827"), 0.12, 0.58); dark_glass.emission_enabled = true; dark_glass.emission = Color("1e6184"); dark_glass.emission_energy_multiplier = 0.6
	match variant % 6:
		0:
			var crown_size := Vector3(size.x * 0.72, size.y * 0.27, size.z * 0.72)
			_add_building_visual(building, "SetbackCrown", Vector3(0, size.y * 0.62, 0), crown_size, _building_facade_material(tint.lightened(0.08), crown_size, variant))
			_add_building_visual(building, "RoofBeacon", Vector3(0, size.y * 0.79, 0), Vector3(0.42, size.y * 0.18, 0.42), accent)
		1:
			_add_building_visual(building, "GlassCorner", Vector3(size.x * 0.505, 0, -size.z * 0.12), Vector3(0.08, size.y * 0.93, size.z * 0.72), dark_glass)
			_add_building_visual(building, "VerticalLight", Vector3(-size.x * 0.51, 0, size.z * 0.22), Vector3(0.10, size.y * 0.82, 0.18), accent)
		2:
			var mid_size := Vector3(size.x * 0.86, size.y * 0.34, size.z * 0.86)
			_add_building_visual(building, "MidriseSetback", Vector3(0, size.y * 0.60, 0), mid_size, _building_facade_material(tint.darkened(0.08), mid_size, variant))
			_add_building_visual(building, "CrownBand", Vector3(0, size.y * 0.78, -size.z * 0.51), Vector3(size.x * 0.9, 0.22, 0.10), accent)
		3:
			_add_building_visual(building, "OffsetAnnex", Vector3(size.x * 0.38, -size.y * 0.22, size.z * 0.43), Vector3(size.x * 0.40, size.y * 0.56, size.z * 0.40), _building_facade_material(tint.lightened(0.04), Vector3(size.x * 0.40, size.y * 0.56, size.z * 0.40), variant))
			_add_building_visual(building, "RoofMechanical", Vector3(-size.x * 0.16, size.y * 0.57, 0), Vector3(size.x * 0.30, size.y * 0.14, size.z * 0.30), dark_glass)
		4:
			# One stepped residential crown and balcony band preserve the silhouette
			# without six separate meshes per building.
			var terrace_size := Vector3(size.x * 0.68, size.y * 0.38, size.z * 0.68)
			_add_building_visual(building, "TerraceCrown", Vector3(0, size.y * 0.42, 0), terrace_size, _building_facade_material(tint.lightened(0.08), terrace_size, variant))
			_add_building_visual(building, "BalconyBand", Vector3(0, size.y * 0.24, -terrace_size.z * 0.52), Vector3(terrace_size.x * 0.96, 0.16, 0.12), accent)
		5:
			# Low, broad commercial block with a recessed arcade and twin rooftop volumes.
			_add_building_visual(building, "CommercialCanopy", Vector3(0, -size.y * 0.28, -size.z * 0.53), Vector3(size.x * 1.08, 0.32, 0.70), accent)
			_add_building_visual(building, "RoofVolumeLeft", Vector3(-size.x * 0.22, size.y * 0.53, 0), Vector3(size.x * 0.34, size.y * 0.18, size.z * 0.52), dark_glass)
			_add_building_visual(building, "RoofVolumeRight", Vector3(size.x * 0.22, size.y * 0.53, 0), Vector3(size.x * 0.34, size.y * 0.18, size.z * 0.52), dark_glass)
	# The dense base skyline remains visible down the block. The more expensive
	# storefront, crown, and rooftop meshes are a near-field LOD only.
	_configure_visual_lod(building, 55.0)
	# Keep the complete facade silhouette visible through the next block. Only
	# the small rooftop/storefront pieces use the tighter near-field LOD.
	base_visual.visibility_range_end = 280.0
	base_visual.visibility_range_end_margin = 90.0
	add_child(building)

func _add_historic_mixed_use(position: Vector3, size: Vector3, variant: int) -> void:
	# A complete low-rise building using the generated facade as a material on a
	# real volume. It remains solid and collidable—never a flat image panel.
	var building := Node3D.new(); building.name = "HistoricMixedUse"; building.position = position
	var facade_texture: Texture2D = historic_restaurant_facade_texture
	if not mixed_use_facade_textures.is_empty():
		facade_texture = mixed_use_facade_textures[posmod(variant, mixed_use_facade_textures.size())]
	var facade := StandardMaterial3D.new(); facade.albedo_texture = facade_texture; facade.roughness = 0.56; facade.metallic = 0.12
	var base := _add_building_visual(building, "HistoricBrickFacade", Vector3.ZERO, size, facade)
	var collision_body := StaticBody3D.new(); collision_body.name = "BuildingCollision"
	var collision := CollisionShape3D.new(); var shape := BoxShape3D.new(); shape.size = Vector3(size.x * 0.76, size.y, size.z * 0.76); collision.shape = shape; collision_body.add_child(collision); building.add_child(collision_body)
	var roof := _material(Color("17232c"), 0.50, 0.68)
	_add_building_visual(building, "HistoricCornice", Vector3(0, size.y * 0.48, 0), Vector3(size.x * 1.05, 0.42, size.z * 1.05), roof)
	_add_building_visual(building, "HistoricRoofVent", Vector3(size.x * 0.20, size.y * 0.55, 0), Vector3(size.x * 0.22, 1.2, size.z * 0.22), roof)
	_add_business_sign(building, "MARKET ROW" if variant % 2 == 0 else "RAIN CITY KITCHEN", Vector3(0, -size.y * 0.33, -size.z * 0.52), Color("ffd39a"))
	_configure_visual_lod(building, 68.0)
	base.visibility_range_end = 280.0
	base.visibility_range_end_margin = 90.0
	add_child(building)

func _configure_visual_lod(root: Node, distance: float) -> void:
	# Distant small geometry is culled, keeping the opening turn responsive while
	# retaining the dense city once the player approaches each district.
	for child in root.get_children():
		if child is GeometryInstance3D:
			child.visibility_range_end = distance
			child.visibility_range_end_margin = 30.0
		_configure_visual_lod(child, distance)

func _add_building_visual(parent: Node3D, label: String, local_position: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var visual := MeshInstance3D.new(); visual.name = label; var mesh := BoxMesh.new(); mesh.size = size; visual.mesh = mesh; visual.material_override = material; visual.position = local_position; parent.add_child(visual); return visual

func _add_street_level_frontage(building: Node3D, size: Vector3, tint: Color, variant: int) -> void:
	# A shallow, low-emission lobby treatment gives the track-side building a real
	# ground floor instead of a single blown-out luminous rectangle.
	var frame := _material(tint.darkened(0.40), 0.38, 0.68)
	var lobby := _material(Color("0a2432"), 0.16, 0.48)
	lobby.emission_enabled = true; lobby.emission = Color("226b82") if variant % 2 == 0 else Color("70452c"); lobby.emission_energy_multiplier = 0.38
	var sign := _material(Color("79d9ed") if variant % 2 == 0 else Color("e8a35f"), 0.24, 0.42)
	sign.emission_enabled = true; sign.emission = sign.albedo_color; sign.emission_energy_multiplier = 0.55
	var lobby_height := minf(4.8, size.y * 0.27)
	for face in [0, 1]:
		var z := (-1.0 if face == 0 else 1.0) * (size.z * 0.506)
		_add_building_visual(building, "LobbyGlass", Vector3(0, -size.y * 0.5 + lobby_height * 0.55, z), Vector3(size.x * 0.76, lobby_height, 0.08), lobby)
		_add_building_visual(building, "LobbyCanopy", Vector3(0, -size.y * 0.5 + lobby_height * 1.15, z * 1.012), Vector3(size.x * 0.86, 0.20, 0.25), sign)
		for x in [-size.x * 0.42, 0.0, size.x * 0.42]:
			_add_building_visual(building, "LobbyMullion", Vector3(x, -size.y * 0.5 + lobby_height * 0.55, z * 1.015), Vector3(0.16, lobby_height * 1.08, 0.12), frame)

func _add_cafe_frontage(building: Node3D, size: Vector3, variant: int) -> void:
	var charcoal := _material(Color("101923"), 0.42, 0.62)
	var glass := _material(Color("16425a"), 0.08, 0.48); glass.emission_enabled = true; glass.emission = Color("287fa0"); glass.emission_energy_multiplier = 0.55
	var awning := _material(Color("cf633c") if variant % 2 == 0 else Color("c99b44"), 0.30, 0.52)
	for z_sign in [-1.0, 1.0]:
		var z: float = z_sign * size.z * 0.515
		_add_building_visual(building, "CafeGlass", Vector3(0, -size.y * 0.31, z), Vector3(size.x * 0.78, size.y * 0.30, 0.10), glass)
		_add_building_visual(building, "CafeAwning", Vector3(0, -size.y * 0.14, z * 1.01), Vector3(size.x * 0.94, 0.34, 0.82), awning)
		_add_building_visual(building, "CafeDoor", Vector3(0, -size.y * 0.34, z * 1.018), Vector3(1.25, size.y * 0.24, 0.14), charcoal)
	_add_business_sign(building, "NIGHT OWL CAFE", Vector3(0, -size.y * 0.06, -size.z * 0.535), Color("ffc675"))

func _add_diner_frontage(building: Node3D, size: Vector3, variant: int) -> void:
	var chrome := _material(Color("8ea7b4"), 0.16, 0.88)
	var neon := _material(Color("ff4d91") if variant % 2 == 0 else Color("4ae8ff"), 0.12, 0.54); neon.emission_enabled = true; neon.emission = neon.albedo_color; neon.emission_energy_multiplier = 1.8
	for z_sign in [-1.0, 1.0]:
		var z: float = z_sign * size.z * 0.515
		_add_building_visual(building, "DinerWindow", Vector3(0, -size.y * 0.30, z), Vector3(size.x * 0.82, size.y * 0.28, 0.09), chrome)
		_add_building_visual(building, "DinerNeonBand", Vector3(0, -size.y * 0.12, z * 1.01), Vector3(size.x * 0.92, 0.18, 0.13), neon)
	_add_business_sign(building, "RAINLINE DINER", Vector3(0, -size.y * 0.04, -size.z * 0.535), neon.albedo_color)

func _add_gallery_frontage(building: Node3D, size: Vector3, variant: int) -> void:
	var stone := _material(Color("33404a"), 0.66, 0.38)
	var lightbox := _material(Color("d9f4f2") if variant % 2 == 0 else Color("e7b368"), 0.20, 0.35); lightbox.emission_enabled = true; lightbox.emission = lightbox.albedo_color; lightbox.emission_energy_multiplier = 0.82
	for z_sign in [-1.0, 1.0]:
		var z: float = z_sign * size.z * 0.515
		_add_building_visual(building, "GalleryPlinth", Vector3(0, -size.y * 0.39, z), Vector3(size.x * 0.88, size.y * 0.18, 0.20), stone)
		_add_building_visual(building, "GalleryLightbox", Vector3(0, -size.y * 0.19, z * 1.01), Vector3(size.x * 0.66, size.y * 0.18, 0.12), lightbox)
	_add_business_sign(building, "AFTER DARK GALLERY", Vector3(0, -size.y * 0.06, -size.z * 0.535), lightbox.albedo_color)

func _add_business_sign(building: Node3D, text_value: String, local_position: Vector3, color: Color) -> void:
	var sign := Label3D.new(); sign.name = "BusinessSign"; sign.text = text_value; sign.position = local_position; sign.font_size = 34; sign.outline_size = 5; sign.pixel_size = 0.009; sign.modulate = color; sign.no_depth_test = false; building.add_child(sign)

func _add_window_facades(building: Node3D, size: Vector3, tint: Color, variant: int) -> void:
	# Four shallow facades add bright, repeating office depth to the otherwise simple collision mass.
	_add_window_facade(building, "NorthWindowGrid", Vector3(0, 0, -size.z * 0.506), Vector2(size.x * 0.90, size.y * 0.86), Vector3.ZERO, tint, variant)
	_add_window_facade(building, "SouthWindowGrid", Vector3(0, 0, size.z * 0.506), Vector2(size.x * 0.90, size.y * 0.86), Vector3(0, PI, 0), tint, variant + 13)
	_add_window_facade(building, "EastWindowGrid", Vector3(size.x * 0.506, 0, 0), Vector2(size.z * 0.90, size.y * 0.86), Vector3(0, PI * 0.5, 0), tint, variant + 29)
	_add_window_facade(building, "WestWindowGrid", Vector3(-size.x * 0.506, 0, 0), Vector2(size.z * 0.90, size.y * 0.86), Vector3(0, -PI * 0.5, 0), tint, variant + 47)

func _add_window_facade(parent: Node3D, label: String, local_position: Vector3, dimensions: Vector2, rotation: Vector3, tint: Color, seed: int) -> void:
	var facade := MeshInstance3D.new(); facade.name = label; var mesh := QuadMesh.new(); mesh.size = dimensions; facade.mesh = mesh; facade.material_override = _window_grid_material(tint, seed); facade.position = local_position; facade.rotation = rotation; parent.add_child(facade)

func _window_grid_material(tint: Color, seed: int, grid_scale := Vector2(12.0, 26.0)) -> ShaderMaterial:
	if building_window_shader == null:
		building_window_shader = Shader.new()
		building_window_shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled;
uniform vec4 wall_color : source_color;
uniform float seed;
uniform vec2 grid_scale;
float hash21(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7)) + seed * 17.13) * 43758.5453); }
void fragment() {
	vec2 cells = UV * grid_scale;
	vec2 cell = floor(cells);
	vec2 local = fract(cells);
	float inside = step(0.135, local.x) * step(local.x, 0.865) * step(0.115, local.y) * step(local.y, 0.885);
	float lit = step(0.73, hash21(cell));
	vec3 frame = wall_color.rgb * 0.28;
	vec3 window_dark = vec3(0.010, 0.042, 0.070);
	vec3 window_lit = mix(vec3(0.055, 0.37, 0.54), vec3(0.92, 0.37, 0.12), hash21(cell + 5.7));
	vec3 window = mix(window_dark, window_lit, lit);
	ALBEDO = mix(frame, window, inside);
	METALLIC = 0.40;
	ROUGHNESS = 0.32;
	EMISSION = window * inside * (0.08 + lit * 0.72);
}
"""
	var material := ShaderMaterial.new(); material.shader = building_window_shader; material.set_shader_parameter("wall_color", tint.lightened(0.20)); material.set_shader_parameter("seed", float(seed)); material.set_shader_parameter("grid_scale", grid_scale); return material

func _add_junction_pad(position: Vector3) -> void:
	# Flat pads overlap the ends of pitched slabs, preventing a collision lip at sharp turns.
	var pad := StaticBody3D.new(); pad.name = "RoadJunction"
	pad.position = position - Vector3.UP * 0.5
	var visual := MeshInstance3D.new(); var mesh := BoxMesh.new(); mesh.size = Vector3(19.5, 1.0, 19.5); visual.mesh = mesh; visual.material_override = _wet_road_material(Vector3(2.0, 2.0, 1.0)); pad.add_child(visual)
	var collision := CollisionShape3D.new(); var shape := BoxShape3D.new(); shape.size = Vector3(19.5, 1.0, 19.5); collision.shape = shape; pad.add_child(collision)
	add_child(pad)

func _add_tunnel(a: Vector3, b: Vector3) -> void:
	tunnel_start = a
	tunnel_end = b
	var tunnel := Node3D.new(); tunnel.name = "RainlineTransitTunnel"
	var length: float = a.distance_to(b); var center: Vector3 = (a + b) * 0.5
	tunnel.look_at_from_position(center, b, Vector3.UP); add_child(tunnel)
	var concrete := _material(Color("172433"), 0.7, 0.25)
	var tube_light := _route_material(); tube_light.emission = Color("37d8ff"); tube_light.emission_energy_multiplier = 3.0
	for z in range(-int(length * 0.5) + 10, int(length * 0.5), 20):
		for side in [-1, 1]:
			var wall := MeshInstance3D.new(); var wall_mesh := BoxMesh.new(); wall_mesh.size = Vector3(0.6, 10.0, 0.7); wall.mesh = wall_mesh; wall.material_override = concrete; wall.position = Vector3(side * 11.5, 5.0, z); tunnel.add_child(wall)
		var ceiling := MeshInstance3D.new(); var ceiling_mesh := BoxMesh.new(); ceiling_mesh.size = Vector3(24, 0.65, 0.7); ceiling.mesh = ceiling_mesh; ceiling.material_override = concrete; ceiling.position = Vector3(0, 10.0, z); tunnel.add_child(ceiling)
		var strip := MeshInstance3D.new(); var strip_mesh := BoxMesh.new(); strip_mesh.size = Vector3(0.4, 0.15, 8.0); strip.mesh = strip_mesh; strip.material_override = tube_light; strip.position = Vector3(0, 9.5, z); tunnel.add_child(strip)

func _lane_material() -> StandardMaterial3D:
	var material := _material(Color("d8e7e9"), 0.24, 0.1)
	material.emission_enabled = true
	material.emission = Color("8ac9d2")
	material.emission_energy_multiplier = 1.2
	return material

func _add_checkpoint(position: Vector3, index: int) -> void:
	var checkpoint: RaceCheckpoint = CHECKPOINT_SCRIPT.new(); checkpoint.name = "Checkpoint_%d" % index; checkpoint.position = position + Vector3(0, 2, 0); checkpoint.setup(index, race)
	var shape := CollisionShape3D.new(); var box := BoxShape3D.new(); box.size = Vector3(19, 8, 8); shape.shape = box; checkpoint.add_child(shape)
	var marker_material := _route_material()
	var left := MeshInstance3D.new(); var pylon := BoxMesh.new(); pylon.size = Vector3(0.5, 8, 0.5); left.mesh = pylon; left.material_override = marker_material; left.position = Vector3(-8.5, 0, 0); checkpoint.add_child(left)
	var right := left.duplicate(); right.position.x = 8.5; checkpoint.add_child(right)
	var gantry := MeshInstance3D.new(); var gantry_mesh := BoxMesh.new(); gantry_mesh.size = Vector3(17.5, 0.5, 0.5); gantry.mesh = gantry_mesh; gantry.material_override = marker_material; gantry.position.y = 3.7; checkpoint.add_child(gantry)
	var gate_light := OmniLight3D.new(); gate_light.light_color = Color("ffbd50"); gate_light.light_energy = 5.0; gate_light.omni_range = 14.0; gate_light.position = Vector3(0, 3, 0); checkpoint.add_child(gate_light)
	checkpoint.configure_visuals([left, right, gantry], gate_light)
	checkpoints.append(checkpoint)
	add_child(checkpoint)

func _add_ground_turn_arrow(index: int) -> void:
	var previous: Vector3 = route[index - 1]
	var incoming: Vector3 = route[index] - previous
	var outgoing: Vector3 = route[index + 1] - route[index]
	incoming.y = 0.0; outgoing.y = 0.0
	incoming = incoming.normalized(); outgoing = outgoing.normalized()
	# Every authored junction gets a pair. Fractional placement keeps cues distinct on short links.
	for approach_fraction in [0.62, 0.30]:
		var segment_progress: float = clampf(approach_fraction, 0.0, 1.0)
		var arrow_position: Vector3 = previous.lerp(route[index], segment_progress) + Vector3.UP * 0.12
		var arrow := MeshInstance3D.new(); arrow.name = "PaintedRoadTurnArrow"; arrow.position = arrow_position
		# PlaneMesh is a true XZ surface; this cannot form a collision lip or sink below the road.
		var plane := PlaneMesh.new(); plane.size = Vector2(9.0, 18.0); arrow.mesh = plane
		var material := StandardMaterial3D.new(); material.albedo_texture = road_arrow_texture; material.emission_enabled = true; material.emission_texture = road_arrow_texture; material.emission = Color("4eeaff"); material.emission_energy_multiplier = 3.2; material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; material.cull_mode = BaseMaterial3D.CULL_DISABLED
		arrow.material_override = material
		arrow.look_at_from_position(arrow_position, arrow_position + outgoing, Vector3.UP)
		add_child(arrow)

func _add_boost_strip(segment_index: int, fraction: float, power: float, label: String) -> void:
	var start: Vector3 = route[segment_index]; var end: Vector3 = route[segment_index + 1]
	var center: Vector3 = start.lerp(end, fraction) + Vector3.UP * 0.13
	var strip := Area3D.new(); strip.name = label; strip.position = center; strip.look_at_from_position(center, end, Vector3.UP); add_child(strip)
	var collision := CollisionShape3D.new(); var shape := BoxShape3D.new(); shape.size = Vector3(8.0, 2.0, 26.0); collision.shape = shape; strip.add_child(collision)
	var pad_material := _material(Color("26d7ff"), 0.08, 0.45); pad_material.emission_enabled = true; pad_material.emission = Color("29dfff"); pad_material.emission_energy_multiplier = 3.6
	for lane in [-2.4, 0.0, 2.4]:
		var pad := MeshInstance3D.new(); pad.name = "BoostStripLight"; var mesh := BoxMesh.new(); mesh.size = Vector3(1.05, 0.05, 22.0); pad.mesh = mesh; pad.material_override = pad_material; pad.position = Vector3(lane, 0.08, 0); strip.add_child(pad)
	var label_node := Label3D.new(); label_node.text = "BOOST"; label_node.position = Vector3(0, 0.18, -6.0); label_node.font_size = 42; label_node.outline_size = 5; label_node.pixel_size = 0.009; label_node.modulate = Color("8af5ff"); label_node.billboard = BaseMaterial3D.BILLBOARD_DISABLED; label_node.rotation_degrees.x = -90.0; strip.add_child(label_node)
	strip.body_entered.connect(func(body: Node3D):
		if body is ArcadeCar:
			body.apply_track_boost(power)
			hud.set_status(label + "  +%d" % roundi(power))
			AudioService.play_vehicle(&"boost")
			strip.set_deferred("monitoring", false)
	)

func _route_point(segment_index: int, fraction: float) -> Vector3:
	return route[segment_index].lerp(route[segment_index + 1], fraction)

func _make_set_piece(name: String, position: Vector3, look_target: Vector3) -> Node3D:
	var piece := Node3D.new(); piece.name = name; piece.position = position
	piece.look_at_from_position(position, look_target, Vector3.UP)
	add_child(piece)
	return piece

func _add_route_set_pieces() -> void:
	# Three readable districts break the long route into memorable beats. All are
	# visual-only so their appeal never comes at the cost of another snag point.
	_add_market_descent_set_piece()
	_add_waterfront_sweeper_set_piece()
	_add_dockyard_chicane_set_piece()
	_add_city_overpasses()

func _add_market_descent_set_piece() -> void:
	var center := _route_point(4, 0.46)
	var piece := _make_set_piece("PikeMarketDescent", center, route[5])
	var brick := _material(Color("522d2c"), 0.70, 0.18)
	var canopy := _material(Color("d24b35"), 0.30, 0.42); canopy.emission_enabled = true; canopy.emission = Color("e8553e"); canopy.emission_energy_multiplier = 0.65
	for side in [-1, 1]:
		_add_scene_prop(piece, "MarketStall", Vector3(side * 13.0, 2.5, 0), Vector3(7.0, 5.0, 10.0), brick)
		_add_scene_prop(piece, "MarketAwning", Vector3(side * 11.0, 5.3, 0), Vector3(8.0, 0.35, 11.0), canopy)
	_add_scene_label(piece, "PIKE MARKET DESCENT", Vector3(0, 7.5, -8.0), Color("ffc46c"), 44)
	_add_route_beacons(piece, 0.0, Color("ff9c48"))

func _add_waterfront_sweeper_set_piece() -> void:
	var center := _route_point(10, 0.72)
	var piece := _make_set_piece("HarborfrontSweeper", center, route[11])
	var water := _material(Color(0.04, 0.23, 0.36, 0.72), 0.04, 0.62, true); water.emission_enabled = true; water.emission = Color("155e7c"); water.emission_energy_multiplier = 0.5
	var pier := _material(Color("23323b"), 0.72, 0.38)
	_add_scene_prop(piece, "HarborWater", Vector3(22.0, -1.0, 8.0), Vector3(26.0, 0.18, 70.0), water)
	for z in [-22.0, 0.0, 22.0]:
		_add_scene_prop(piece, "PierFinger", Vector3(16.0, 0.4, z), Vector3(9.0, 0.55, 2.0), pier)
	_add_scene_label(piece, "HARBORFRONT SWEEPER", Vector3(11.0, 6.0, -14.0), Color("69dcff"), 42)
	_add_route_beacons(piece, 1.0, Color("4eeaff"))

func _add_dockyard_chicane_set_piece() -> void:
	var center := _route_point(18, 0.56)
	var piece := _make_set_piece("BlackwaterDockyardChicane", center, route[19])
	var steel := _material(Color("354550"), 0.55, 0.64)
	var stripe := _material(Color("f0a62d"), 0.22, 0.52); stripe.emission_enabled = true; stripe.emission = Color("ff9d1c"); stripe.emission_energy_multiplier = 1.3
	# Offset outside the 18 m road surface: it reads as a chicane/pinch without
	# closing either lane or becoming a physical obstacle.
	for data in [[-10.8, -13.0], [10.8, 1.0], [-10.8, 15.0]]:
		_add_scene_prop(piece, "ConstructionIsland", Vector3(float(data[0]), 1.1, float(data[1])), Vector3(3.4, 2.2, 7.0), steel)
		_add_scene_prop(piece, "HazardPanel", Vector3(float(data[0]) * 0.92, 2.45, float(data[1])), Vector3(2.8, 0.7, 0.16), stripe)
	_add_scene_label(piece, "BLACKWATER CHICANE", Vector3(0, 6.0, -19.0), Color("ffbc53"), 42)
	_add_route_beacons(piece, -1.0, Color("ffb34a"))

func _add_city_overpasses() -> void:
	for segment_index in [7, 15]:
		var center := _route_point(segment_index, 0.50)
		var piece := _make_set_piece("CityOverpass", center, route[segment_index + 1])
		var concrete := _material(Color("273746"), 0.64, 0.35)
		var strip := _material(Color("3ad1ed"), 0.15, 0.48); strip.emission_enabled = true; strip.emission = Color("44dfff"); strip.emission_energy_multiplier = 1.1
		_add_scene_prop(piece, "OverpassDeck", Vector3(0, 9.0, 0), Vector3(30.0, 1.1, 6.0), concrete)
		for side in [-1, 1]: _add_scene_prop(piece, "OverpassColumn", Vector3(side * 12.0, 4.2, 0), Vector3(1.4, 8.4, 2.6), concrete)
		_add_scene_prop(piece, "OverpassLight", Vector3(0, 8.28, -2.2), Vector3(18.0, 0.12, 0.18), strip)

func _add_route_beacons(piece: Node3D, side: float, color: Color) -> void:
	var beacon_material := _material(color, 0.12, 0.35); beacon_material.emission_enabled = true; beacon_material.emission = color; beacon_material.emission_energy_multiplier = 2.8
	for z in [-22.0, -11.0, 0.0, 11.0, 22.0]:
		var x := 8.55 if side <= 0.0 else -8.55
		_add_scene_prop(piece, "RouteBeacon", Vector3(x, 1.05, z), Vector3(0.32, 1.4, 0.32), beacon_material)

func _add_scene_prop(parent: Node3D, label: String, local_position: Vector3, size: Vector3, material: Material) -> void:
	var visual := MeshInstance3D.new(); visual.name = label
	var mesh := BoxMesh.new(); mesh.size = size; visual.mesh = mesh; visual.material_override = material; visual.position = local_position; parent.add_child(visual)

func _add_scene_label(parent: Node3D, text_value: String, local_position: Vector3, color: Color, font_size: int) -> void:
	var label := Label3D.new(); label.name = "RouteSign_" + text_value; label.text = text_value; label.position = local_position; label.font_size = font_size; label.outline_size = 5; label.pixel_size = 0.009; label.modulate = color; label.billboard = BaseMaterial3D.BILLBOARD_ENABLED; parent.add_child(label)

func _add_finish_spectacle() -> void:
	var finish := _make_set_piece("RainlineFinish", route[-1] + Vector3.UP * 0.1, route[-1] + (route[-1] - route[-2]))
	var chrome := _material(Color("375364"), 0.22, 0.78)
	var cyan := _material(Color("39dbff"), 0.10, 0.38); cyan.emission_enabled = true; cyan.emission = Color("40e5ff"); cyan.emission_energy_multiplier = 3.2
	# Carry the final straight past the stripe into a real dockside turnout. The
	# player crosses a clear finish, sees the result, and never faces open space.
	var runoff := MeshInstance3D.new(); runoff.name = "FinishRunoff"; var runoff_mesh := BoxMesh.new(); runoff_mesh.size = Vector3(18.0, 1.0, 72.0); runoff.mesh = runoff_mesh; runoff.material_override = _wet_road_material(Vector3(2.0, 5.0, 1.0)); runoff.position = Vector3(0, -0.5, -36.0); finish.add_child(runoff)
	var white := _material(Color("f3f5ef"), 0.34, 0.12)
	var black := _material(Color("10151a"), 0.48, 0.42)
	for column in range(12):
		for row in range(2):
			var tile := MeshInstance3D.new(); tile.name = "FinishCheck"; var tile_mesh := BoxMesh.new(); tile_mesh.size = Vector3(1.45, 0.035, 1.45); tile.mesh = tile_mesh; tile.material_override = white if (column + row) % 2 == 0 else black; tile.position = Vector3(-7.95 + float(column) * 1.45, 0.035, -0.4 + float(row) * 1.45); finish.add_child(tile)
	var terminal := _building_facade_material(Color("2a2928"), Vector3(42.0, 24.0, 2.0), 2)
	_add_scene_prop(finish, "FinishTerminalFacade", Vector3(0, 12.0, -70.0), Vector3(42.0, 24.0, 2.0), terminal)
	for side in [-1, 1]: _add_scene_prop(finish, "FinishWarehouse", Vector3(side * 22.0, 8.0, -58.0), Vector3(12.0, 16.0, 24.0), _building_facade_material(Color("312d2a"), Vector3(12.0, 16.0, 24.0), side + 3))
	for side in [-1, 1]:
		_add_scene_prop(finish, "FinishPylon", Vector3(side * 8.3, 4.0, 0), Vector3(0.7, 8.0, 0.7), chrome)
		var light := OmniLight3D.new(); light.position = Vector3(side * 7.5, 5.0, 0); light.light_color = Color("48eaff"); light.light_energy = 3.5; light.omni_range = 14.0; finish.add_child(light); finish_lights.append(light)
	_add_scene_prop(finish, "FinishHeader", Vector3(0, 7.7, 0), Vector3(17.0, 0.7, 0.8), cyan)
	_add_scene_label(finish, "RAINLINE // FINISH", Vector3(0, 7.8, -0.46), Color("f0fdff"), 58)

func _build_car() -> void:
	# Start on the road rather than dropping into it during the countdown.
	car = CAR_SCRIPT.new(); car.name = "North"; car.position = route[0] + Vector3(0, 0.82, 0); add_child(car)
	car.look_at_from_position(car.global_position, route[1], Vector3.UP)
	var shape := CollisionShape3D.new(); var collider := BoxShape3D.new(); collider.size = Vector3(1.9, 0.85, 4.4); shape.shape = collider; car.add_child(shape)
	if not _spawn_selected_vehicle():
		# Keep a legible fallback if a fresh checkout has not imported the Blender asset yet.
		var body := MeshInstance3D.new(); var body_mesh := BoxMesh.new(); body_mesh.size = Vector3(1.9, 0.7, 4.2); body.mesh = body_mesh; body.material_override = _material(Color("d11945"), 0.28, 0.7); body.position.y = 0.1; car.add_child(body)
		var cabin := MeshInstance3D.new(); var cabin_mesh := BoxMesh.new(); cabin_mesh.size = Vector3(1.5, 0.55, 1.9); cabin.mesh = cabin_mesh; cabin.material_override = _material(Color("101b2e"), 0.08, 0.35); cabin.position = Vector3(0, 0.65, 0.15); car.add_child(cabin)
	_add_vehicle_fx()
	_apply_selected_vehicle_tuning()
	# The cockpit is stable because it inherits the car transform. Use that same
	# relationship for chase view rather than chasing a physics body from a
	# separately smoothed world-space camera.
	chase_camera_rig = Node3D.new(); chase_camera_rig.name = "ChaseCameraRig"; chase_camera_rig.position = Vector3(0, 0.55, 0); car.add_child(chase_camera_rig)
	chase_camera = Camera3D.new(); chase_camera.name = "ChaseCamera"; chase_camera.current = not first_person_mode; chase_camera.near = 0.05; chase_camera.position = Vector3(0, 3.85, 9.4); chase_camera.rotation_degrees = Vector3(-15.0, 0, 0); chase_camera_rig.add_child(chase_camera)
	# This camera lives in the car's local space, so changing views is immediate and does not disturb handling.
	first_person_camera = Camera3D.new(); first_person_camera.name = "DriverCamera"; first_person_camera.position = Vector3(0, 0.88, -0.72); first_person_camera.fov = 76.0; first_person_camera.near = 0.05; first_person_camera.current = first_person_mode; car.add_child(first_person_camera)
	if hero_car_visual != null: hero_car_visual.visible = not first_person_mode

func _spawn_selected_vehicle() -> bool:
	if car == null: return false
	var hero_scene := load(str(VEHICLES[selected_vehicle_index]["path"])) as PackedScene
	if hero_scene == null: return false
	var hero_car := hero_scene.instantiate() as Node3D
	if hero_car == null: return false
	hero_car.name = "SelectedVehicle"
	hero_car.visible = not first_person_mode
	car.add_child(hero_car)
	hero_car_visual = hero_car
	return true

func _select_vehicle(direction: int) -> void:
	selected_vehicle_index = posmod(selected_vehicle_index + direction, VEHICLES.size())
	_save_setting("selected_vehicle", selected_vehicle_index)
	if hero_car_visual != null:
		hero_car_visual.queue_free()
		hero_car_visual = null
	_spawn_selected_vehicle()
	_apply_selected_vehicle_tuning()
	if garage_open: _update_garage_preview()

func _open_garage() -> void:
	garage_open = true
	hud.show_garage()
	_update_garage_preview()

func _close_garage() -> void:
	garage_open = false
	AudioService.release_engine()
	hud.show_title()

func _update_garage_preview() -> void:
	var vehicle: Dictionary = VEHICLES[selected_vehicle_index]
	var preview := load(str(vehicle["preview"])) as Texture2D
	hud.set_garage_vehicle(str(vehicle["name"]), selected_vehicle_index, VEHICLES.size(), str(vehicle["description"]), str(vehicle["stats"]), preview)

func _apply_selected_vehicle_tuning() -> void:
	if car == null: return
	var tuning: Dictionary = VEHICLES[selected_vehicle_index]["tuning"]
	car.acceleration = float(tuning["acceleration"])
	car.max_speed = float(tuning["max_speed"])
	car.boosted_max_speed = float(tuning["boosted_max_speed"])
	car.steering_rate = float(tuning["steering_rate"])
	car.normal_lateral_grip = float(tuning["normal_grip"])
	car.drift_lateral_grip = float(tuning["drift_grip"])
	car.boost_capacity = float(tuning["boost_capacity"])
	car.boost_amount = minf(car.boost_amount, car.boost_capacity)

func _add_cockpit_detail() -> void:
	# A compact dashboard gives the alternate view a clear in-car frame without adding physics.
	var dash := MeshInstance3D.new(); dash.name = "CockpitDashboard"
	var dash_mesh := BoxMesh.new(); dash_mesh.size = Vector3(1.72, 0.26, 0.52); dash.mesh = dash_mesh; dash.position = Vector3(0, 0.56, -1.02); dash.material_override = _material(Color("071019"), 0.35, 0.55); car.add_child(dash)
	var instruments := MeshInstance3D.new(); instruments.name = "CockpitInstruments"
	var instrument_mesh := BoxMesh.new(); instrument_mesh.size = Vector3(0.82, 0.025, 0.24); instruments.mesh = instrument_mesh; instruments.position = Vector3(0, 0.704, -1.06)
	var instrument_material := _material(Color("4eeaff"), 0.1, 0.2); instrument_material.emission_enabled = true; instrument_material.emission = Color("4eeaff"); instrument_material.emission_energy_multiplier = 2.4; instruments.material_override = instrument_material; car.add_child(instruments)

func _add_driver_view_detail() -> void:
	# The imported exterior has opaque glass. Render a restrained dashboard in camera space instead
	# of exposing its interior faces, keeping the first-person road view completely clear.
	var dash := MeshInstance3D.new(); dash.name = "DriverViewDashboard"
	var dash_mesh := BoxMesh.new(); dash_mesh.size = Vector3(1.9, 0.22, 0.72); dash.mesh = dash_mesh; dash.position = Vector3(0, -0.54, -1.15); dash.material_override = _material(Color("071019"), 0.28, 0.55); first_person_camera.add_child(dash)
	var display := MeshInstance3D.new(); display.name = "DriverViewDisplay"
	var display_mesh := BoxMesh.new(); display_mesh.size = Vector3(0.64, 0.025, 0.18); display.mesh = display_mesh; display.position = Vector3(0, -0.405, -1.22)
	var display_material := _material(Color("12384a"), 0.35, 0.2); display.material_override = display_material; first_person_camera.add_child(display)

func _add_vehicle_fx() -> void:
	# Lightweight motion hardware layers over the authored vehicle shell so each
	# selected model reads as planted and alive on the wet road.
	var tire := _material(Color("071018"), 0.88, 0.05)
	var rim := _material(Color("7ba7bb"), 0.18, 0.82)
	for z in [-1.42, 1.42]:
		for side in [-1, 1]:
			var rig := Node3D.new(); rig.name = "WheelRig"; rig.position = Vector3(side * 0.96, -0.12, z); car.add_child(rig)
			var wheel := MeshInstance3D.new(); wheel.name = "SpinningWheel"; var wheel_mesh := CylinderMesh.new(); wheel_mesh.top_radius = 0.37; wheel_mesh.bottom_radius = 0.37; wheel_mesh.height = 0.24; wheel.mesh = wheel_mesh; wheel.material_override = tire; wheel.rotation_degrees.z = 90.0; rig.add_child(wheel)
			var hub := MeshInstance3D.new(); hub.name = "WheelHub"; var hub_mesh := CylinderMesh.new(); hub_mesh.top_radius = 0.18; hub_mesh.bottom_radius = 0.18; hub_mesh.height = 0.255; hub.mesh = hub_mesh; hub.material_override = rim; hub.rotation_degrees.z = 90.0; rig.add_child(hub)
			wheel_rigs.append(rig); wheel_rest_positions.append(rig.position)
			var spray := MeshInstance3D.new(); spray.name = "RoadSpray"; var spray_mesh := BoxMesh.new(); spray_mesh.size = Vector3(0.62, 0.52, 1.55); spray.mesh = spray_mesh; spray.position = Vector3(side * 0.78, 0.16, z + 0.48); spray.rotation_degrees.x = -14.0
			var spray_material := _material(Color(0.42, 0.82, 1.0, 0.0), 0.08, 0.08, true); spray_material.emission_enabled = true; spray_material.emission = Color("378daf"); spray_material.emission_energy_multiplier = 0.18; spray.material_override = spray_material; spray.visible = false; car.add_child(spray); road_spray.append(spray); road_spray_materials.append(spray_material)
	for side in [-1, 1]:
		var tail := MeshInstance3D.new(); tail.name = "TailLight"
		var tail_mesh := BoxMesh.new(); tail_mesh.size = Vector3(0.38, 0.20, 0.12); tail.mesh = tail_mesh; tail.position = Vector3(side * 0.63, 0.18, 2.14)
		var tail_material := _material(Color("d41b35"), 0.1, 0.2); tail_material.emission_enabled = true; tail_material.emission = Color("ff3049"); tail_material.emission_energy_multiplier = 2.0; tail.material_override = tail_material; car.add_child(tail); tail_light_materials.append(tail_material)
		var flame := MeshInstance3D.new(); flame.name = "BoostFlame"
		var flame_mesh := BoxMesh.new(); flame_mesh.size = Vector3(0.26, 0.18, 1.35); flame.mesh = flame_mesh; flame.position = Vector3(side * 0.52, 0.12, 2.78)
		var flame_material := _material(Color(0.25, 0.92, 1.0, 0.72), 0.1, 0.1, true); flame_material.emission_enabled = true; flame_material.emission = Color("40dcff"); flame_material.emission_energy_multiplier = 5.0; flame.material_override = flame_material; flame.visible = false; car.add_child(flame); boost_flames.append(flame)

func _update_vehicle_fx(delta: float) -> void:
	if car == null: return
	var braking := car.can_drive and Input.is_action_pressed("brake")
	var speed_ratio := clampf(car.current_speed_mps() / 70.0, 0.0, 1.0)
	var spin := car.current_speed_mps() * 2.8 * delta
	for index in wheel_rigs.size():
		var wheel := wheel_rigs[index]
		wheel.rotate_y(spin)
		var bob := sin(Time.get_ticks_msec() * 0.016 + float(index) * 1.7) * 0.025 * speed_ratio
		wheel.position = wheel_rest_positions[index] + Vector3.UP * bob
	var spray_visible := car.can_drive and car.current_speed_mps() > 8.0
	var spray_alpha := (0.12 + speed_ratio * 0.28) * (1.55 if car.is_drifting else 1.0)
	for index in road_spray.size():
		road_spray[index].visible = spray_visible
		road_spray_materials[index].albedo_color.a = spray_alpha
		road_spray[index].scale.z = 0.65 + speed_ratio * 0.75
	for material in tail_light_materials:
		material.emission_energy_multiplier = 7.0 if braking else 2.0
	for flame in boost_flames:
		flame.visible = car.is_boosting
		if flame.visible: flame.scale.z = 0.76 + sin(Time.get_ticks_msec() * 0.028) * 0.22

func _build_race() -> void:
	race = RaceManager.new(); add_child(race); race.configure(checkpoint_route_indices.size(), EVENT)
	race.race_finished.connect(_on_finished)

func _finish_race_setup() -> void:
	race.race_started.connect(func(): car.can_drive = true; last_sector_split_ms = 0; sector_number = 1; hud.set_sector("SECTOR 1  •  LIVE"); hud.set_prompt(""); recorder.start_recording(); var ghost_time := _spawn_ghost(); hud.set_ghost_note("GHOST  %s" % _format_time(ghost_time) if ghost_time > 0 else "NO GHOST — SET A PB"); AudioService.play_ui(&"go"))
	race.checkpoint_reached.connect(_set_checkpoint_recovery)
	race.checkpoint_reached.connect(_on_checkpoint_feedback)
	race.checkpoint_reached.connect(_update_active_checkpoint)
	race.checkpoint_reached.connect(func(index: int, _split: int): car.award_boost(24.0); hud.set_checkpoint_progress(index + 1, race.checkpoint_count))
	race.checkpoint_reached.connect(func(_index: int, _split: int): AudioService.play_ui(&"checkpoint"))
	race.wrong_checkpoint.connect(func(_index: int, _expected: int): hud.set_status("WRONG GATE — FOLLOW THE CYAN ROUTE"); AudioService.play_ui(&"countdown"))
	race.race_finished.connect(func(_time: int, _medal: String): AudioService.play_ui(&"finish"))
	recorder = RECORDER_SCRIPT.new(); recorder.target = car; add_child(recorder)

func _set_checkpoint_recovery(index: int, _split_ms: int) -> void:
	var checkpoint_position: Vector3 = route[checkpoint_route_indices[index]] + Vector3.UP * 2.0
	car.set_recovery_transform(Transform3D(car.global_transform.basis, checkpoint_position))

func _on_checkpoint_feedback(index: int, split_ms: int) -> void:
	if index in [2, 5, 7]:
		var sector_ms := split_ms - last_sector_split_ms
		hud.set_sector("SECTOR %d  •  %s" % [sector_number, _format_time(sector_ms)])
		hud.set_status("SECTOR %d COMPLETE" % sector_number)
		sector_number += 1
		last_sector_split_ms = split_ms
	else:
		hud.set_status("CHECKPOINT %d  •  %s" % [index + 1, _format_time(split_ms)])

func _update_active_checkpoint(index: int, _split_ms: int) -> void:
	if index < checkpoints.size(): checkpoints[index].set_active(false)
	if index + 1 < checkpoints.size(): checkpoints[index + 1].set_active(true)

func _build_hud() -> void:
	hud = HUD_SCRIPT.new(); add_child(hud); hud.title.text = "SEATTLE AFTER DARK  //  RAINLINE RUN"; hud.speed.text = "000 mph"; hud.time.text = "00:00.000"; hud.checkpoint.text = "TIME ATTACK"; hud.best.text = "BEST  %s" % (_format_time(reference_best_ms) if reference_best_ms > 0 else "--:--.---"); hud.set_prompt(""); hud.set_checkpoint_progress(0, race.checkpoint_count); hud.configure_minimap(route, checkpoint_route_indices)
	car.speed_changed.connect(func(kph: float): hud.speed.text = "%03d mph" % round(kph * 0.621371))
	car.speed_changed.connect(func(kph: float): AudioService.set_engine_speed(kph))
	car.boost_changed.connect(func(value: float, maximum: float): hud.boost.max_value = maximum; hud.boost.value = value)
	car.collision_feedback.connect(func(impact: float): AudioService.play_vehicle(&"impact", impact / 30.0))
	car.boost_started.connect(func(): boost_camera_kick = true; AudioService.play_vehicle(&"boost"))
	car.boost_ended.connect(func(): boost_camera_kick = false)
	car.drift_started.connect(func(): AudioService.play_vehicle(&"drift", 0.7))
	car.drift_ended.connect(_on_drift_link)
	car.track_boosted.connect(func(power: float): hud.set_sector("SURGE ACTIVE  •  +%d" % roundi(power)))
	car.recovered.connect(func(): hud.set_status("RECOVERED AT LAST GATE"); AudioService.play_vehicle(&"impact", 0.35))

func _on_drift_link(score: float) -> void:
	if score < 8.0: return
	var reward := clampf(score * 0.35, 4.0, 20.0)
	car.award_boost(reward)
	hud.set_status("DRIFT LINK  +%d BOOST" % roundi(reward))

func _start_run() -> void:
	AudioService.release_engine()
	started = true; garage_open = false; hud.show_race(); hud.set_prompt("GET READY")
	hud.set_status("PERSONAL BEST RUN" if reference_best_ms > 0 else "FIRST RECORDED RUN")
	race.countdown_changed.connect(func(value: int): hud.set_prompt("GO!" if value == 0 else str(value)); AudioService.play_ui(&"go" if value == 0 else &"countdown"))
	race.begin_countdown()

func _spawn_ghost() -> int:
	var ghost_data: Dictionary = profile.get("ghosts", {}).get(str(EVENT.event_id), {})
	if ghost_data.get("handling_version", "") != EVENT.handling_version: return 0
	var samples: Array = ghost_data.get("samples", [])
	if samples.size() < 2: return 0
	var ghost: GhostPlayer = GHOST_SCRIPT.new(); ghost.position = car.position; add_child(ghost)
	var visual := MeshInstance3D.new(); var mesh := BoxMesh.new(); mesh.size = Vector3(1.7, 0.65, 4.0); visual.mesh = mesh; visual.material_override = _material(Color(0.15, 0.85, 1.0, 0.38), 0.15, 0.8, true); ghost.add_child(visual); ghost.load_and_start(samples)
	return int(ghost_data.get("time_ms", 0))

func _on_finished(time_ms: int, medal: String) -> void:
	car.can_drive = false
	AudioService.release_engine()
	var bests: Dictionary = profile.get("best_times_ms", {})
	var key := str(EVENT.event_id); var previous := int(bests.get(key, 0)); var is_pb := previous == 0 or time_ms < previous
	if is_pb:
		bests[key] = time_ms; profile["best_times_ms"] = bests
		var ghosts: Dictionary = profile.get("ghosts", {}); ghosts[key] = {"handling_version": EVENT.handling_version, "time_ms": time_ms, "samples": recorder.stop_recording()}; profile["ghosts"] = ghosts; SaveService.save_profile(profile)
	else: recorder.stop_recording()
	hud.show_results(medal, _format_time(time_ms), is_pb, "TARGETS  G %s  •  S %s  •  B %s" % [_format_time(EVENT.gold_time_ms), _format_time(EVENT.silver_time_ms), _format_time(EVENT.bronze_time_ms)])
	hud.set_status("%s" % ("PERSONAL BEST SAVED" if is_pb else "KEEP CHASING THE GHOST"))

func _update_finish_spectacle() -> void:
	if finish_lights.is_empty(): return
	var active := race != null and race.state == RaceManager.State.FINISHED
	var pulse := 5.8 + sin(Time.get_ticks_msec() * 0.012) * 2.1 if active else 3.5
	for light in finish_lights: light.light_energy = pulse

func _add_lamp(position: Vector3, color: Color, energy: float) -> void:
	# Keep the live Forward+ light budget deliberately small. More lamps remain
	# visible through emissive route/window dressing without occupying light clusters.
	if active_omni_light_count >= 12: return
	var light := OmniLight3D.new(); light.position = position; light.light_color = color; light.light_energy = energy; light.omni_range = 16.0; add_child(light)
	active_omni_light_count += 1

func _add_rain() -> void:
	rain_rig = Node3D.new(); rain_rig.name = "RainVolume"; add_child(rain_rig)
	for x in range(-50, 51, 10):
		for z in range(-40, 31, 10):
			var drop := MeshInstance3D.new(); var mesh := CylinderMesh.new(); mesh.top_radius = 0.012; mesh.bottom_radius = 0.012; mesh.height = 3.0 + float(abs((x + z) % 4)); drop.mesh = mesh; drop.material_override = _material(Color(0.5, 0.75, 1.0, 0.32), 0.1, 0.3, true); drop.position = Vector3(x, 9 + float((x * z) % 7), z); rain_rig.add_child(drop); rain_drops.append(drop)

func _update_rain_volume(delta: float) -> void:
	if rain_rig == null or car == null: return
	rain_rig.global_position = Vector3(car.global_position.x, car.global_position.y, car.global_position.z)
	for drop in rain_drops:
		drop.position.y -= delta * 24.0
		if drop.position.y < -2.0: drop.position.y += 17.0

func _update_audio_context() -> void:
	if car == null: return
	if paused or race == null or race.state != RaceManager.State.RACING or not car.can_drive:
		AudioService.release_engine()
		return
	AudioService.set_engine_load(Input.get_action_strength("throttle"), car.is_boosting)
	var tunnel_vector := tunnel_end - tunnel_start
	var tunnel_length_sq := tunnel_vector.length_squared()
	var tunnel_amount := 0.0
	if tunnel_length_sq > 0.01:
		var projection := clampf((car.global_position - tunnel_start).dot(tunnel_vector) / tunnel_length_sq, 0.0, 1.0)
		var closest := tunnel_start + tunnel_vector * projection
		if car.global_position.distance_to(closest) < 10.5: tunnel_amount = 1.0
	AudioService.set_tunnel_amount(tunnel_amount)

func _update_performance_overlay(delta: float) -> void:
	if hud == null or not started: return
	performance_sample_seconds -= delta
	if performance_sample_seconds > 0.0: return
	performance_sample_seconds = 0.35
	var fps := roundi(Performance.get_monitor(Performance.TIME_FPS))
	var draw_calls := roundi(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	var objects := roundi(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME))
	hud.set_performance("PERF  %d FPS  •  %d DRAWS  •  %d OBJECTS" % [fps, draw_calls, objects])

func _recover_if_off_route(delta: float) -> void:
	if car == null or race == null or race.state != RaceManager.State.RACING or not car.can_drive: return
	var nearest_distance := INF
	for index in range(route.size() - 1):
		var closest := Geometry3D.get_closest_point_to_segment(car.global_position, route[index], route[index + 1])
		nearest_distance = minf(nearest_distance, car.global_position.distance_to(closest))
	# Beyond the driving lane, sidewalk, and guardrail there is only scenery/support
	# geometry. Recover automatically rather than leaving the player perched there.
	if nearest_distance > 13.5:
		off_route_seconds += delta
		if off_route_seconds > 0.8:
			car.reset_to_safe_position()
			hud.set_status("ROUTE RECOVERY")
			off_route_seconds = 0.0
	else:
		off_route_seconds = 0.0

func _apply_graphics_preset() -> void:
	if weather_environment != null:
		weather_environment.glow_enabled = not reduced_effects
		weather_environment.fog_density = 0.0018 if reduced_effects else 0.0025
	if rain_rig != null: rain_rig.visible = not reduced_effects

func _material(color: Color, roughness: float, metallic: float, transparent := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new(); material.albedo_color = color; material.roughness = roughness; material.metallic = metallic
	if transparent: material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material

func _building_facade_material(tint: Color, building_size: Vector3, style := 3) -> StandardMaterial3D:
	# Structural backing is deliberately neutral; detail lives in actual modular
	# windows/storefront geometry, not a stretched photographic surface.
	var material := _material(tint.darkened(0.18), 0.56, 0.48)
	material.emission_enabled = true
	material.emission = tint.darkened(0.65)
	material.emission_energy_multiplier = 0.08
	return material

func _wet_road_material(uv_scale: Vector3) -> StandardMaterial3D:
	var material := _material(Color(0.68, 0.80, 0.94, 1.0), 0.16, 0.88)
	material.albedo_texture = wet_streetscape_texture if wet_streetscape_texture != null else wet_asphalt_texture
	material.uv1_scale = uv_scale
	# 1 is the Godot 4 material repeat-enabled mode; use the value for 4.7 compatibility.
	material.texture_repeat = 1
	material.clearcoat_enabled = true
	material.clearcoat_roughness = 0.12
	return material

func _route_material() -> StandardMaterial3D:
	var material := _material(Color("ffb62f"), 0.15, 0.7)
	material.emission_enabled = true
	material.emission = Color("ff9d1c")
	material.emission_energy_multiplier = 4.0
	return material

func _update_cameras(delta: float) -> void:
	if chase_camera == null or car == null: return
	if first_person_mode:
		if first_person_camera != null:
			var cockpit_fov: float = 76.0 if comfort_camera else (82.0 if boost_camera_kick else 76.0)
			first_person_camera.fov = lerpf(first_person_camera.fov, cockpit_fov, clampf(delta * 8.0, 0.0, 1.0))
		return
	# Position and heading now inherit directly from the car. Only the optional
	# FOV change is frame-based, so there is no camera/body transform race.
	var target_fov: float = 70.0 if comfort_camera else (76.0 if boost_camera_kick else 70.0)
	chase_camera.fov = lerpf(chase_camera.fov, target_fov, clampf(delta * 7.0, 0.0, 1.0))

func _toggle_camera() -> void:
	if chase_camera == null or first_person_camera == null: return
	first_person_mode = not first_person_mode
	chase_camera.current = not first_person_mode
	first_person_camera.current = first_person_mode
	if hero_car_visual != null: hero_car_visual.visible = not first_person_mode
	_save_setting("first_person_camera", first_person_mode)
	hud.set_status("CAMERA: %s" % ("FIRST PERSON" if first_person_mode else "CHASE"))

func _save_setting(key: String, value: Variant) -> void:
	var settings: Dictionary = profile.get("settings", {})
	settings[key] = value
	profile["settings"] = settings
	SaveService.save_profile(profile)

func _format_time(ms: int) -> String:
	return "%02d:%02d.%03d" % [ms / 60000, (ms / 1000) % 60, ms % 1000]

func _update_best_comparison() -> void:
	if reference_best_ms <= 0:
		hud.best.text = "GHOST PB  --:--.---"
		return
	var difference := race.elapsed_ms() - reference_best_ms
	hud.best.text = "GHOST PB  %s   %s" % [_format_time(reference_best_ms), _format_delta(difference)]
	hud.set_ghost_note("GHOST %s  •  %s" % [_format_time(reference_best_ms), "AHEAD" if difference > 0 else "YOU'RE AHEAD"])

func _format_delta(ms: int) -> String:
	var sign := "+" if ms >= 0 else "−"
	return "%s%.3f" % [sign, absf(float(ms)) / 1000.0]

func _update_route_guidance() -> void:
	var target_index: int = checkpoint_route_indices[min(race.current_checkpoint, checkpoint_route_indices.size() - 1)]
	var target: Vector3 = route[target_index]
	var offset: Vector3 = target - car.global_position
	var distance: int = roundi(offset.length())
	hud.route_distance.text = "NEXT GATE  %dm" % distance
	hud.route_arrow.visible = false
