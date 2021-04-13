extends PanelContainer


func _ready():
	on_temperature_changed(TemperatureVars.temperature_kelvin)


func on_temperature_changed(temperature_kelvin):
	# The LCD Solid font uses the º character for a degree sign rather than °.
	# For other fonts it should be replaced.
	$Labels/TemperatureKelvin.text = "%dK" % temperature_kelvin
	$Labels/TemperatureCelsius.text = "%.fºC" % TemperatureVars.temperature_celsius
	$Labels/TemperatureFahrenheit.text = "%.fºF" % TemperatureVars.temperature_fahrenheit
