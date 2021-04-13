extends Node

export(float) var kelvin_added = 1

var _active


func _ready():
	TemperatureVars.timer.connect("timeout", self, "_on_TemperatureTimer_timeout")


func on_item_changed(_item_name, item):
	_active = item["active"]


func _on_TemperatureTimer_timeout():
	if _active:
		TemperatureVars.temperature_kelvin += kelvin_added * TemperatureVars.timer.wait_time
