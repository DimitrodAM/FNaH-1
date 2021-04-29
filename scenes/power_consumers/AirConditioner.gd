extends Node

export(float) var kelvin_removed = 1

var _power_state



func on_consumer_changed(_consumer_name, consumer):
	_power_state = consumer["power_state"]


func on_tick(delta):
	if _power_state:
		TemperatureVars.temperature_kelvin -= kelvin_removed * delta
