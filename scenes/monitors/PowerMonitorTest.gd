extends Node2D

const Util = preload("res://Util.gd")

export(PackedScene) var consumer_scene
export(bool) var fullscreen_monitor_node = true


var _previous_plugged_in = {}
var _items_plugged_in = 0


func _ready():
	get_fullscreen_monitor_node().visible = fullscreen_monitor_node
	
	on_consumers_changed(PowerVars.consumers)
	on_items_changed(ItemVars.items)


func on_consumers_changed(consumers):
	call_deferred("_on_consumers_changed_deferred", consumers)
func _on_consumers_changed_deferred(consumers):
	for child in $UI/Consumers/Consumers.get_children():
		child.free()
	for consumer_name in consumers:
		var consumer = consumers[consumer_name]
		var instance = consumer_scene.instance()
		instance.consumer_name = consumer_name
		instance.is_item = false
		_update_consumer(instance, consumer)
		instance.name = consumer_name
		$UI/Consumers/Consumers.add_child(instance)
	_update_total()

func on_consumer_changed(consumer_name, consumer):
	var instance = $UI/Consumers/Consumers.get_node(consumer_name)
	_update_consumer(instance, consumer)
	_update_total()

func _update_consumer(instance, consumer):
	instance.label = consumer["label"]
	instance.power_usage = consumer["power_usage"]
	instance.power_state = consumer["power_state"]
	
	instance.energy = null
	instance.energy_capacity = null


func on_items_changed(items):
	call_deferred("_on_items_changed_deferred", items)
func _on_items_changed_deferred(items):
	for child in $UI/Consumers/Items.get_children():
		child.free()
	_items_plugged_in = 0
	for item_name in items:
		var item = items[item_name]
		var instance = consumer_scene.instance()
		instance.consumer_name = item_name
		instance.is_item = true
		_update_item(instance, item_name, item)
		if item["charging"]:
			_items_plugged_in += 1
		instance.name = item_name
		$UI/Consumers/Items.add_child(instance)
	_update_items_plugged_in()
	_update_total()

func on_item_changed(item_name, item):
	var instance = $UI/Consumers/Items.get_node(item_name)
	if !_previous_plugged_in[item_name] && item["plugged_in"]:
		_items_plugged_in += 1
	elif _previous_plugged_in[item_name] && !item["plugged_in"]:
		_items_plugged_in -= 1
	_update_item(instance, item_name, item)
	_update_items_plugged_in()
	_update_total()

func _update_item(instance, item_name, item):
	instance.label = item["label"]
	instance.power_usage = item["charging_power"]
	instance.power_state = item["charging"]
	
	instance.energy = item["energy"]
	instance.energy_capacity = item["energy_capacity"]
	
	instance.visible = item["plugged_in"]
	_previous_plugged_in[item_name] = item["plugged_in"]

func _update_items_plugged_in():
	if _items_plugged_in > 0:
		$UI/Consumers/Separator.visible = true
		$UI/Consumers/Items.visible = true
	else:
		$UI/Consumers/Separator.visible = false
		$UI/Consumers/Items.visible = false

func _get_total_item_usage():
	var total = 0
	for item in ItemVars.items.values():
		if item["charging"]:
			total += item["charging_power"]
	return total


func _update_total():
	$UI/Total/Total.text = "%s/%sW" % [
		Util.float_to_string_no_trailing(PowerVars.get_total_usage() + _get_total_item_usage()),
		Util.float_to_string_no_trailing(PowerVars.MAX_POWER),
	]


func get_fullscreen_monitor_node():
	return $UI/FullscreenMonitor
