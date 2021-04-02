extends Node2D

const Util = preload("res://Util.gd")

const rooms = {
	"the_office_inner": {
		"texture": preload("res://rooms/the_office_inner.jpg"),
		"transitions": {
			"Outer": "the_office",
			# "Monitor": {"type": "signal", "signal": "monitor"},
		},
		"subscenes": {
			"Monitor": {
				"scene": preload("res://CameraTest.tscn"),
				"connections": {
					"fullscreen": "_on_monitor_fullscreen",
					"close": "_on_monitor_close",
				},
			},
		},
	},
	
	"the_office": {
		"texture": preload("res://rooms/the_office.jpg"),
		"transitions": {
			"Inner": "the_office_inner",
			"Door": "hallway_the_office",
		},
	},
	
	"hallway_the_office": {
		"texture": preload("res://rooms/hallway_the_office.jpg"),
		"transitions": {
			"DoorTheOffice": "the_office",
			"HallwayStorageRoom": "hallway_storage_room",
		},
	},
	
	"hallway_storage_room": {
		"texture": preload("res://rooms/hallway_storage_room.jpg"),
		"transitions": {
			"BackHallwayTheOffice": "hallway_the_office"
		},
	},
}


# OBSOLETE
# [start] Timer [end] (Comment)
# 1. [_in_transition = true] LeaveTween [_change_room()] (Fade-out)
# 2. MoveTimer (Black screen)
# 3. EnterTween [_in_transition = false] (Fade-in)


export(String) var default_room

# # warning-ignore:unused_signal
# signal monitor


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
				transition.connect("input_event", self, "_transition_click", [ rooms[room_name]["transitions"][transition.get_name()] ])
				transition.connect("mouse_entered", self, "_transition_mouse_entered")
				transition.connect("mouse_exited", self, "_transition_mouse_exited")
			rooms[room_name]["transition_nodes"] = transition_nodes
		
		var subscenes = room.get_node_or_null("Subscenes")
		if subscenes != null:
			for subscene in subscenes.get_children():
				var subscene_name = subscene.get_name()
				var subscene_obj = rooms[room_name]["subscenes"][subscene_name]
				var instance = subscene_obj["scene"].instance()
				var collision_shape = subscene.get_child(0)
				Util.add_node_position(instance, Vector2(
					collision_shape.position.x - collision_shape.shape.extents.x,
					collision_shape.position.y - collision_shape.shape.extents.y))
				Util.set_node_scale(instance, Vector2(
					(collision_shape.shape.extents.x * 2) / get_viewport().size.x,
					(collision_shape.shape.extents.y * 2) / get_viewport().size.y))
				for sig in subscene_obj.get("connections", {}):
					instance.connect(sig, self, subscene_obj["connections"][sig], [instance])
				add_child_below_node($Room, instance)
				yield(get_tree().root, "ready")
				var original = Util.set_node_visible(instance, false)
				if !"subscene_visibilities" in rooms[room_name]:
					rooms[room_name]["subscene_visibilities"] = {}
				rooms[room_name]["subscene_visibilities"][subscene_name] = original
				if !"subscene_instances" in rooms[room_name]:
					rooms[room_name]["subscene_instances"] = {}
				rooms[room_name]["subscene_instances"][subscene_name] = instance
	
	var default_room_dict = rooms[default_room]
	# _old_room = default_room_dict
	_change_room(default_room_dict)

# Change room (no transition included).
func _change_room(room):
	$Room.texture = room["texture"]
	if _old_room != null:
		_change_transitions_disabled(_old_room, true)
		_change_subscenes_disabled(_old_room, true)
	_change_transitions_disabled(room, false)
	_change_subscenes_disabled(room, false)
	_old_room = room


# Enable or disable the transitions of a room.
func _change_transitions_disabled(room, disabled):
	for transition in room.get("transition_nodes", []):
		for collision_shape in transition.get_children():
			collision_shape.set_deferred("disabled", disabled)

# Enable or disable the subscenes of a room.
func _change_subscenes_disabled(room, disabled):
	for subscene_name in room.get("subscenes", {}):
		var subscene = room["subscene_instances"][subscene_name]
		if disabled:
			var original = Util.set_node_visible(subscene, !disabled)
			room["subscene_visibilities"][subscene_name] = original
		else:
			Util.restore_node_visibility(subscene, room["subscene_visibilities"][subscene_name])
		# Util.set_node_mouse_filter(subscene, Control.MOUSE_FILTER_IGNORE if disabled else Control.MOUSE_FILTER_PASS)

func _transition_click(_viewport, event, _shape_idx, transition):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT \
			and !_in_transition:
		match transition:
			{"type": "signal", "signal": var sig, ..}:
				emit_signal(sig)
			var room:
				_new_room = rooms[room]
				$UI/LeaveTween.interpolate_property($UI/BlackScreen, "modulate",
					Color(1, 1, 1, 0), Color(1, 1, 1, 1), .25,
					Tween.TRANS_LINEAR)
				$UI/LeaveTween.start()

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
	$UI/EnterTween.interpolate_property($UI/BlackScreen, "modulate",
		Color(1, 1, 1, 1), Color(1, 1, 1, 0), .25,
		Tween.TRANS_LINEAR)
	$UI/EnterTween.start()

func _on_EnterTween_tween_completed(_object, _key):
	_in_transition = false


func _on_monitor_fullscreen(monitor):
	monitor.ignore_lower = true
	var collision_shape = $Rooms/TheOfficeInner/Subscenes/Monitor/CollisionShape2D
	$Camera/Tween.stop_all()
	$Camera/Tween.interpolate_property($Camera, "position",
		$Camera.position, collision_shape.position,
		.5, Tween.TRANS_SINE)
	$Camera/Tween.interpolate_property($Camera, "zoom",
		$Camera.zoom, Vector2(
			(collision_shape.shape.extents.x * 2) / 1920,
			(collision_shape.shape.extents.y * 2) / 1080),
		.5, Tween.TRANS_SINE)
	$Camera/Tween.start()
	yield(get_tree().create_timer(.1), "timeout")
	monitor.ignore_lower = false
	yield($Camera/Tween, "tween_all_completed")
	monitor.fullscreened()

func _on_monitor_close(monitor):
	monitor.ignore_fullscreen = true
	$Camera/Tween.stop_all()
	$Camera/Tween.interpolate_property($Camera, "position",
		$Camera.position, Vector2(1920 / 2, 1080 / 2),
		.5, Tween.TRANS_SINE)
	$Camera/Tween.interpolate_property($Camera, "zoom",
		$Camera.zoom, Vector2(1, 1),
		.5, Tween.TRANS_SINE)
	$Camera/Tween.start()
	yield(get_tree().create_timer(.001), "timeout")
	monitor.ignore_fullscreen = false
	yield($Camera/Tween, "tween_all_completed")
	monitor.closed()
