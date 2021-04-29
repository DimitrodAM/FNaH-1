extends Control

export(PackedScene) var item_scene


func _ready():
	on_items_changed(ItemVars.items)


func on_items_changed(items):
	call_deferred("_on_items_changed_deferred", items)
func _on_items_changed_deferred(items):
	for child in $Items.get_children():
		child.free()
	for item_name in items:
		var item = items[item_name]
		var instance = item_scene.instance()
		instance.item_name = item_name
		_update_item(instance, item)
		instance.current_room = RoomVars.current_room
		instance.name = item_name
		$Items.add_child(instance)

func on_item_changed(item_name, item):
	var instance = $Items.get_node(item_name)
	_update_item(instance, item)

func _update_item(instance, item):
	instance.label = item["label"]
	instance.active = item["active"]
	instance.location = item["location"]
	instance.plugged_in = item["plugged_in"]
	instance.energy = item["energy"]
	instance.energy_usage = item["energy_usage"]
	instance.energy_capacity = item["energy_capacity"]
	instance.out_of_energy = item["out_of_energy"]


func on_room_changed(_old_room, room):
	for child in $Items.get_children():
		child.current_room = room
