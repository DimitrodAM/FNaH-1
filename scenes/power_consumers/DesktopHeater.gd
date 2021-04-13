extends Node

export(float) var kelvin_added = 1

var _power_state


func _ready():
	TemperatureVars.timer.connect("timeout", self, "_on_TemperatureTimer_timeout")


func on_consumer_changed(_consumer_name, consumer):
	_power_state = consumer["power_state"]


func _on_TemperatureTimer_timeout():
	if _power_state:
		TemperatureVars.temperature_kelvin += kelvin_added * TemperatureVars.timer.wait_time
