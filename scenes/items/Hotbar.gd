extends Control

export(PackedScene) var item_scene


func _ready():
	on_items_changed(ItemVars.items)


func on_items_changed(items):
	for child in $Items.get_children():
		child.queue_free()
	for item_name in items:
		var item = items[item_name]
		var instance = item_scene.instance()
		instance.item_name = item_name
		instance.label = item["label"]
		instance.active = item["active"]
		instance.name = item_name
		$Items.add_child(instance)

func on_item_changed(item_name, item):
	var instance = $Items.get_node(item_name)
	instance.label = item["label"]
	instance.active = item["active"]
