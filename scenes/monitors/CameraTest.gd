extends Node2D

const Util = preload("res://Util.gd")

const cameras = {
	"hallway_the_office": {
		"texture": preload("res://assets/rooms/hallway_the_office.jpg"),
	},
	
	"hallway_maintenance_room": {
		"texture": preload("res://assets/rooms/hallway_maintenance_room.jpg"),
	},
	
	"maintenance_room": {
		"texture": preload("res://assets/rooms/maintenance_room.jpg"),
	},
}


export(String) var consumer_name
export(String) var default_camera


var _current_camera


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


func on_consumers_changed(consumers):
	if consumer_name in consumers:
		on_consumer_changed(consumer_name, consumers[consumer_name])

func on_consumer_changed(changed_consumer_name, consumer):
	if changed_consumer_name != consumer_name:
		return
	$UI/TurnedOff.visible = !consumer["power_state"]


func get_fullscreen_monitor_node():
	return $UI/FullscreenMonitor
