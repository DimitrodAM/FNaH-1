extends Node2D

const scenes = {
	"RoomMoveTest": {
		"scene": preload("res://RoomMoveTest.tscn"),
		"instance_on": "start",
		"connections": {
			#"monitor": "_on_monitor_opened"
		},
	},
	#"CameraTest": {
	#	"scene": preload("res://CameraTest.tscn"),
	#	"instance_on": "change",
	#	"connections": {
	#		"close": "_on_monitor_closed",
	#	},
	#},
}


export(String) var default_scene


var _scene_instances = {}
var _current_scene
var _new_scene


func _instance_scene(scene_name):
	_scene_instances[scene_name] = scenes[scene_name]["scene"].instance()
	
	var scene = scenes[scene_name]
	for sig in scene.get("connections", {}):
		_scene_instances[scene_name].connect(sig, self, scene["connections"][sig])

# Initialization.
func _ready():
	randomize()
	
	for scene_name in scenes:
		if scenes[scene_name]["instance_on"] == "start":
			_instance_scene(scene_name)
	
	if !_scene_instances.has(default_scene):
		_instance_scene(default_scene)
	_current_scene = default_scene
	add_child(_scene_instances[_current_scene])

func _change_scene(scene_name):
	_new_scene = scene_name
	
	$UI/BlackScreen.mouse_filter = Control.MOUSE_FILTER_STOP
	$UI/Tween.interpolate_property($UI/BlackScreen, "modulate",
		Color(1, 1, 1, 0), Color(1, 1, 1, 1), .25,
		Tween.TRANS_LINEAR)
	$UI/Tween.start()
	yield($UI/Tween, "tween_completed")
	
	yield(get_tree(), "idle_frame")
	if scenes[_current_scene]["instance_on"] != "start":
		_scene_instances[_current_scene].queue_free()
	else:
		remove_child(_scene_instances[_current_scene])
	
	if scenes[_new_scene]["instance_on"] == "change":
		_instance_scene(_new_scene)
	_current_scene = _new_scene
	add_child(_scene_instances[_current_scene])
	
	yield(get_tree().create_timer(0.125), "timeout")
	
	$UI/Tween.interpolate_property($UI/BlackScreen, "modulate",
		Color(1, 1, 1, 1), Color(1, 1, 1, 0), .25,
		Tween.TRANS_LINEAR)
	$UI/Tween.start()
	yield($UI/Tween, "tween_completed")
	
	$UI/BlackScreen.mouse_filter = Control.MOUSE_FILTER_IGNORE


#func _on_monitor_opened():
#	_change_scene("CameraTest")

func _on_monitor_closed():
	_change_scene("RoomMoveTest")
