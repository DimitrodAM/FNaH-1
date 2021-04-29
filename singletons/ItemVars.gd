extends Node

var items = {
	"portable_heater": {
		"label": "Portable heater",
		"energy_usage": 100,
		"charging_power": 100,
		"energy_capacity": 1000,
	},
	"portable_fan": {
		"label": "Portable fan",
		"energy_usage": 100,
		"charging_power": 100,
		"energy_capacity": 1000,
	},
}

func _init():
	for item in items.values():
		if !"active" in item:
			item["active"] = false
		if !"location" in item:
			item["location"] = null
		if !"plugged_in" in item:
			item["plugged_in"] = false
		if !"charging" in item:
			item["charging"] = false
		if !"energy" in item:
			item["energy"] = item["energy_capacity"]
		if !"out_of_energy" in item:
			item["out_of_energy"] = false

# Should ALWAYS be called if items is changed unless item_changed handles this change.
func items_changed():
	get_tree().call_group("notify_items", "on_items_changed", items)

# Should be called ONLY when a property of an item is changed.
func item_changed(item_name):
	get_tree().call_group("notify_items", "on_item_changed", item_name, items[item_name])


const _ROOMS_WITH_CHARGER = ["maintenance_room_inner"]

func can_be_plugged_in_inside_room(room):
	return room["name"] in _ROOMS_WITH_CHARGER
