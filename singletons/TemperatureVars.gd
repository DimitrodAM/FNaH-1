extends Node


const KELVIN_TO_CELSIUS_SUB = 273.15
const KELVIN_TO_FAHRENHEIT_SUB = 459.67

var temperature_kelvin = 293 setget temperature_kelvin_set, temperature_kelvin_get
var temperature_celsius setget temperature_celsius_set, temperature_celsius_get
var temperature_fahrenheit setget temperature_fahrenheit_set, temperature_fahrenheit_get

func temperature_kelvin_set(new_temperature_kelvin):
	temperature_kelvin = new_temperature_kelvin
	get_tree().call_group("notify_temperature", "on_temperature_changed", new_temperature_kelvin)
func temperature_kelvin_get():
	return temperature_kelvin

func temperature_celsius_set(new_temperature_celsius):
	temperature_kelvin_set(new_temperature_celsius + KELVIN_TO_CELSIUS_SUB)
func temperature_celsius_get():
	return temperature_kelvin - KELVIN_TO_CELSIUS_SUB

func temperature_fahrenheit_set(new_temperature_fahrenheit):
	temperature_kelvin_set((new_temperature_fahrenheit + KELVIN_TO_FAHRENHEIT_SUB) * 5 / 9)
func temperature_fahrenheit_get():
	return temperature_kelvin * 1.8 - KELVIN_TO_FAHRENHEIT_SUB
