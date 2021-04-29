extends Node2D

const Util = preload("res://Util.gd")

var BASE_WIDTH = ProjectSettings.get_setting("display/window/size/width")
var BASE_HEIGHT = ProjectSettings.get_setting("display/window/size/height")

export(String) var default_room


var _old_room
var _new_room
var _in_transition


# Initialization.
func _ready():
	var l_rooms = $Rooms.get_children()
	for room in l_rooms:
		var room_name = Util.pascal_to_snake_case(room.get_name())
		
		var transitions = room.get_node_or_null("Transitions")
		if transitions != null:
			var transition_nodes = []
			for transition in transitions.get_children():
				transition_nodes.append(transition)
				transition.connect("input_event", self, "_transition_click", [ RoomVars.rooms[room_name]["transitions"][transition.get_name()] ])
				transition.connect("mouse_entered", self, "_transition_mouse_entered")
				transition.connect("mouse_exited", self, "_transition_mouse_exited")
			RoomVars.rooms[room_name]["transition_nodes"] = transition_nodes
		
		var subscenes = room.get_node_or_null("Subscenes")
		if subscenes != null:
			for subscene in subscenes.get_children():
				var subscene_name = subscene.get_name()
				var subscene_obj = RoomVars.rooms[room_name]["subscenes"][subscene_name]
				var instance = subscene_obj["scene"].instance()
				var collision_shape = subscene.get_child(0)
				Util.set_node_visible(instance, false)
				Util.add_node_position(instance, Vector2(
					collision_shape.position.x - collision_shape.shape.extents.x,
					collision_shape.position.y - collision_shape.shape.extents.y))
				Util.set_node_scale(instance, Vector2(
					(collision_shape.shape.extents.x * 2) / BASE_WIDTH,
					(collision_shape.shape.extents.y * 2) / BASE_HEIGHT))
				for sig in subscene_obj.get("connections", {}):
					instance.connect(sig, self, subscene_obj["connections"][sig], [instance])
				instance.connect("ready", self, "_on_subscene_ready", [room_name, subscene, instance])
				add_child_below_node($Room, instance)
				
	
	var default_room_dict = RoomVars.rooms[default_room]
	# _old_room = default_room_dict
	_change_room(default_room_dict)
func _on_subscene_ready(room_name, subscene, instance):
	var subscene_name = subscene.get_name()
	if instance.has_method("get_fullscreen_monitor_node"):
		var node = instance.get_fullscreen_monitor_node()
		node.connect("fullscreen", self, "_on_monitor_fullscreen", [subscene, instance, node])
		node.connect("close", self, "_on_monitor_close", [subscene, instance, node])
	# var original = Util.set_node_visible(instance, false)
	# if !"subscene_visibilities" in rooms[room_name]:
	# 	rooms[room_name]["subscene_visibilities"] = {}
	# rooms[room_name]["subscene_visibilities"][subscene_name] = original
	if !"subscene_instances" in RoomVars.rooms[room_name]:
		RoomVars.rooms[room_name]["subscene_instances"] = {}
	RoomVars.rooms[room_name]["subscene_instances"][subscene_name] = instance

# Change room (no transition included).
func _change_room(room):
	$Room.texture = room["texture"]
	if _old_room != null:
		_change_transitions_disabled(_old_room, true)
		_change_subscenes_disabled(_old_room, true)
	_change_transitions_disabled(room, false)
	_change_subscenes_disabled(room, false)
	RoomVars.current_room = room
	var old_room = _old_room
	_old_room = room
	get_tree().call_group("notify_room", "on_room_changed", old_room if old_room != null else "null", room)


# Enable or disable the transitions of a room.
func _change_transitions_disabled(room, disabled):
	for transition in room.get("transition_nodes", []):
		for collision_shape in transition.get_children():
			collision_shape.set_deferred("disabled", disabled)

# Enable or disable the subscenes of a room.
func _change_subscenes_disabled(room, disabled):
	for subscene_name in room.get("subscenes", {}):
		var subscene = room["subscene_instances"][subscene_name]
		Util.set_node_visible(subscene, !disabled)
		# if disabled:
		# 	var original = Util.set_node_visible(subscene, !disabled)
		# 	room["subscene_visibilities"][subscene_name] = original
		# else:
		# 	Util.restore_node_visibility(subscene, room["subscene_visibilities"][subscene_name])
		# Util.set_node_mouse_filter(subscene, Control.MOUSE_FILTER_IGNORE if disabled else Control.MOUSE_FILTER_PASS)

func _transition_click(_viewport, event, _shape_idx, transition):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT \
			and !_in_transition:
		_new_room = RoomVars.rooms[transition]
		$UICanvas/LeaveTween.interpolate_property($UICanvas/BlackScreen, "modulate",
			Color(1, 1, 1, 0), Color(1, 1, 1, 1), .25,
			Tween.TRANS_LINEAR)
		$UICanvas/LeaveTween.start()

func _transition_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _transition_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_LeaveTween_tween_started(_object, _key):
	_in_transition = true

func _on_LeaveTween_tween_completed(_object, _key):
	_change_room(_new_room)
	$Room/MoveTimer.start()

func _on_MoveTimer_timeout():
	$UICanvas/EnterTween.interpolate_property($UICanvas/BlackScreen, "modulate",
		Color(1, 1, 1, 1), Color(1, 1, 1, 0), .25,
		Tween.TRANS_LINEAR)
	$UICanvas/EnterTween.start()

func _on_EnterTween_tween_completed(_object, _key):
	_in_transition = false


func _on_monitor_fullscreen(subscene, _instance, fullscreen_monitor_node):
	fullscreen_monitor_node.ignore_lower = true
	var collision_shape = subscene.get_child(0)
	$Camera/Tween.stop_all()
	$Camera/Tween.interpolate_property($Camera, "position",
		$Camera.position, collision_shape.position,
		.5, Tween.TRANS_SINE)
	$Camera/Tween.interpolate_property($Camera, "zoom",
		$Camera.zoom, Vector2(
			(collision_shape.shape.extents.x * 2) / BASE_WIDTH,
			(collision_shape.shape.extents.y * 2) / BASE_HEIGHT),
		.5, Tween.TRANS_SINE)
	$Camera/Tween.start()
	yield(get_tree().create_timer(.1), "timeout")
	fullscreen_monitor_node.ignore_lower = false
	yield($Camera/Tween, "tween_all_completed")
	fullscreen_monitor_node.fullscreened()

func _on_monitor_close(_subscene, _instance, fullscreen_monitor_node):
	fullscreen_monitor_node.ignore_fullscreen = true
	$Camera/Tween.stop_all()
	$Camera/Tween.interpolate_property($Camera, "position",
		$Camera.position, Vector2(BASE_WIDTH / 2, BASE_HEIGHT / 2),
		.5, Tween.TRANS_SINE)
	$Camera/Tween.interpolate_property($Camera, "zoom",
		$Camera.zoom, Vector2(1, 1),
		.5, Tween.TRANS_SINE)
	$Camera/Tween.start()
	yield(get_tree().create_timer(.001), "timeout")
	fullscreen_monitor_node.ignore_fullscreen = false
	yield($Camera/Tween, "tween_all_completed")
	fullscreen_monitor_node.closed()
