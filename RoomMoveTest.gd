extends Node2D

const rooms = {
	"the_office": {
		"texture": preload("res://rooms/the_office.jpg"),
		"transitions": {
			"Door": "corridor_the_office",
		},
	},
	
	"corridor_the_office": {
		"texture": preload("res://rooms/corridor_the_office.jpg"),
		"transitions": {
			"DoorTheOffice": "the_office",
			"CorridorStorageRoom": "corridor_storage_room",
		},
	},
	
	"corridor_storage_room": {
		"texture": preload("res://rooms/corridor_storage_room.jpg"),
		"transitions": {
			"BackCorridorTheOffice": "corridor_the_office"
		},
	},
}


# [start] Timer [end] (Comment)
# 1. [in_transition = true] LeaveTween [_change_room()] (Fade-out)
# 2. MoveTimer (Black screen)
# 3. EnterTween [in_transition = false] (Fade-in)


export(String) var default_room


var old_room
var new_room
var in_transition


# Initialization.
func _ready():
	var l_rooms = $Rooms.get_children()
	for room in l_rooms:
		var transitions = room.get_node("Transitions")
		if transitions == null:
			continue
		var room_name = _pascal_to_snake_case(room.get_name())
		var transition_nodes = []
		for transition in transitions.get_children():
			transition_nodes.append(transition)
			transition.connect("input_event", self, "_transition_click", [ rooms[room_name]["transitions"][transition.get_name()] ])
			transition.connect("mouse_entered", self, "_transition_mouse_entered")
			transition.connect("mouse_exited", self, "_transition_mouse_exited")
		rooms[room_name]["transition_nodes"] = transition_nodes
	
	var default_room_dict = rooms[default_room]
	old_room = default_room_dict
	_change_room(default_room_dict)

# Change room (no transition included).
func _change_room(room):
	$Room.texture = room["texture"]
	_change_transitions_disabled(old_room, true)
	_change_transitions_disabled(room, false)
	old_room = room


# Enable or disable the transitions of a room.
func _change_transitions_disabled(room, disabled):
	for transition in room.get("transition_nodes", []):
		for collision_shape in transition.get_children():
			collision_shape.set_deferred("disabled", disabled)

func _transition_click(_viewport, event, _shape_idx, room):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT \
			and !in_transition:
		new_room = rooms[room]
		$Room/LeaveTween.interpolate_property($Room, "modulate",
			Color(1, 1, 1, 1), Color(1, 1, 1, 0), .25,
			Tween.TRANS_LINEAR)
		$Room/LeaveTween.start()

func _transition_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _transition_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_LeaveTween_tween_started(_object, _key):
	in_transition = true

func _on_LeaveTween_tween_completed(_object, _key):
	_change_room(new_room)
	$Room/MoveTimer.start()

func _on_MoveTimer_timeout():
	$Room/EnterTween.interpolate_property($Room, "modulate",
		Color(1, 1, 1, 0), Color(1, 1, 1, 1), .25,
		Tween.TRANS_LINEAR)
	$Room/EnterTween.start()

func _on_EnterTween_tween_completed(_object, _key):
	in_transition = false


func _pascal_to_snake_case(string):
	var result = PoolStringArray()
	for ch in string:
		if ch == ch.to_lower():
			result.append(ch)
		else:
			result.append('_' + ch.to_lower())
	result[0] = result[0][1]
	return result.join('')
