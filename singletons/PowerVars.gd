extends Node

const MAX_POWER = 500

var consumers = {
	"camera_monitor": {
		"label": "Camera monitor",
		"power_usage": 100,
		"power_state": true,
	},
	"desktop_heater": {
		"label": "Desktop heater",
		"power_usage": 100,
	},
	"air_conditioner": {
		"label": "Air conditioner",
		"power_usage": 100,
	},
}


func _init():
	for consumer in consumers.values():
		if !"power_state" in consumer:
			consumer["power_state"] = false


# Should ALWAYS be called if consumers is changed unless consumer_changed handles this change.
func consumers_changed():
	get_tree().call_group("notify_consumers", "on_consumers_changed", consumers)

# Should be called ONLY when a property of a consumer is changed.
func consumer_changed(consumer_name):
	get_tree().call_group("notify_consumers", "on_consumer_changed", consumer_name, consumers[consumer_name])


func get_total_usage():
	var total = 0
	for consumer in consumers.values():
		if consumer["power_state"]:
			total += consumer["power_usage"]
	return total
