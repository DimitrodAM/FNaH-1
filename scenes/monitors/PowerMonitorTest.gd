extends Node2D

const Util = preload("res://Util.gd")

export(PackedScene) var consumer_scene
export(bool) var fullscreen_monitor_node = true


func _ready():
	get_fullscreen_monitor_node().visible = fullscreen_monitor_node
	
	on_consumers_changed(PowerVars.consumers)


func on_consumers_changed(consumers):
	for child in $UI/Consumers.get_children():
		child.queue_free()
	for consumer_name in consumers:
		var consumer = consumers[consumer_name]
		var instance = consumer_scene.instance()
		instance.consumer_name = consumer_name
		instance.label = consumer["label"]
		instance.power_usage = consumer["power_usage"]
		instance.power_state = consumer["power_state"]
		instance.name = consumer_name
		$UI/Consumers.add_child(instance)
	_update_total()

func on_consumer_changed(consumer_name, consumer):
	var instance = $UI/Consumers.get_node(consumer_name)
	instance.label = consumer["label"]
	instance.power_usage = consumer["power_usage"]
	instance.power_state = consumer["power_state"]
	_update_total()

func _update_total():
	$UI/Total/Total.text = "%s/%sW" % [
		Util.float_to_string_no_trailing(PowerVars.get_total_usage()),
		Util.float_to_string_no_trailing(PowerVars.MAX_POWER),
	]


func get_fullscreen_monitor_node():
	return $UI/FullscreenMonitor
