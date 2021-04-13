extends Node

var items = {
	"portable_heater": {
		"label": "Portable heater",
	},
	"portable_fan": {
		"label": "Portable fan",
	},
}

func _init():
	for item in items.values():
		if !"active" in item:
			item["active"] = false

# Should ALWAYS be called if items is changed unless item_changed handles this change.
func items_changed():
	get_tree().call_group("notify_items", "on_items_changed", items)

# Should be called ONLY when a property of an item is changed.
func item_changed(item_name):
	get_tree().call_group("notify_items", "on_item_changed", item_name, items[item_name])
