extends Node

const Util = preload("res://Util.gd")

export(float) var kelvin_added = 1


var _item_name


func _ready():
	_item_name = Util.pascal_to_snake_case(name)


func on_item_changed(__item_name, item):
	var out_of_energy = item["energy"] < item["energy_usage"] * GameTick.TICK_LENGTH
	item["out_of_energy"] = out_of_energy
	if out_of_energy && !item["plugged_in"]:
		item["active"] = false


func on_tick(delta):
	var item = ItemVars.items[_item_name]
	if item["active"] && !item["out_of_energy"]:
		TemperatureVars.temperature_kelvin += kelvin_added * delta
		item["energy"] -= item["energy_usage"] * stepify(delta, 0.0001)
		ItemVars.item_changed(_item_name)
