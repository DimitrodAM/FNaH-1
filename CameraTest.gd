extends Node2D

const Util = preload("res://Util.gd")

const cameras = {
	"hallway_the_office": {
		"texture": preload("res://rooms/hallway_the_office.jpg"),
	},
	
	"hallway_storage_room": {
		"texture": preload("res://rooms/hallway_storage_room.jpg"),
	},
}


export(String) var default_camera

signal fullscreen
signal close


var _current_camera
var _inside_lower = false
var ignore_fullscreen = false
var ignore_lower = false


# Initialization.
func _ready():
	$Camera/Static.playing = true
	$Camera/Static.visible = true
	
	var l_cameras = $UI/Cameras.get_children()
	for camera in l_cameras:
		camera.connect("pressed", self, "_change_camera", [ camera ])
	_current_camera = $UI/Cameras.get_node(Util.snake_to_pascal_case(default_camera))
	_change_camera(_current_camera)

func _change_camera(camera):
	_current_camera.pressed = false
	camera.pressed = true
	$Camera.texture = cameras[Util.pascal_to_snake_case(camera.name)]["texture"]
	_current_camera = camera
	$Camera/StaticFadeoutTween.stop_all()
	$Camera/Static.modulate = Color(1, 1, 1, 1)
	yield(get_tree().create_timer(0.25), "timeout")
	
	$Camera/StaticFadeoutTween.interpolate_property($Camera/Static, "modulate",
			Color(1, 1, 1, 1), Color(1, 1, 1, 0), .25,
			Tween.TRANS_LINEAR)
	$Camera/StaticFadeoutTween.start()


func _on_FullscreenMonitor_pressed():
	if ignore_fullscreen:
		return
	if $UI/LowerMonitor.get_rect().has_point(get_viewport().get_mouse_position()):
		_inside_lower = true
	$UI/FullscreenMonitor.visible = false
	$UI/LowerMonitor.visible = true
	emit_signal("fullscreen")
func fullscreened():
	pass

func _on_LowerMonitor_mouse_exited():
	_inside_lower = false
func _on_LowerMonitor_mouse_entered():
	if ignore_lower or _inside_lower:
		return
	$UI/LowerMonitor.visible = false
	$UI/FullscreenMonitor.visible = true
	emit_signal("close")
func closed():
	pass
