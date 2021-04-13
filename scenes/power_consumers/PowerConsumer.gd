tool
extends HBoxContainer

const Util = preload("res://Util.gd")

export(String) var consumer_name
export(String) var label setget label_set, label_get
export(float) var power_usage setget power_usage_set, power_usage_get
export(bool) var power_state setget power_state_set, power_state_get

func label_set(new_label):
	label = new_label
	if !has_node("Label"):
		return
	$Label.text = new_label
func label_get():
	return label

func power_usage_set(new_power_usage):
	power_usage = new_power_usage
	if !has_node("PowerUsage"):
		return
	$PowerUsage.text = Util.float_to_string_no_trailing(new_power_usage) + "W"
func power_usage_get():
	return power_usage

func power_state_set(new_power_state):
	power_state = new_power_state
	if !has_node("PowerState") || !has_node("PowerUsage"):
		return
	$PowerState.text = "ON " if new_power_state else "OFF"
	var color = Color(0, 1, 0) if new_power_state else Color(1, 0, 0)
	$PowerState.add_color_override("font_color", color)
	$PowerState.add_color_override("font_color_hover", color)
	$PowerState.add_color_override("font_color_pressed", color)
	$PowerUsage.add_color_override("font_color", Color(1, 1, 1) if new_power_state else Color(0.5, 0.5, 0.5))
func power_state_get():
	return power_state


func _ready():
	label_set(label)
	power_usage_set(power_usage)
	power_state_set(power_state)


func _on_PowerState_pressed():
	PowerVars.consumers[consumer_name]["power_state"] = !power_state
	PowerVars.consumer_changed(consumer_name)
	power_state_set(!power_state)
