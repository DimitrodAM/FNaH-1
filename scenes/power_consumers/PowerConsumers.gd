extends Node

const Util = preload("res://Util.gd")


func _ready():
	on_consumers_changed(PowerVars.consumers)


func on_consumers_changed(consumers):
	for consumer_name in consumers:
		on_consumer_changed(consumer_name, consumers[consumer_name])

func on_consumer_changed(consumer_name, consumer):
	var node = get_node_or_null(Util.snake_to_pascal_case(consumer_name))
	if node == null || !node.has_method("on_consumer_changed"):
		return
	node.on_consumer_changed(consumer_name, consumer)
