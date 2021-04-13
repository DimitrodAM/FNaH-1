extends Node

const Util = preload("res://Util.gd")


func _ready():
	on_items_changed(ItemVars.items)


func on_items_changed(items):
	for item_name in items:
		on_item_changed(item_name, items[item_name])

func on_item_changed(item_name, item):
	var node = get_node_or_null(Util.snake_to_pascal_case(item_name))
	if node == null || !node.has_method("on_item_changed"):
		return
	node.on_item_changed(item_name, item)
