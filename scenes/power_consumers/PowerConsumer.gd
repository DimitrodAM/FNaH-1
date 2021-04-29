tool
extends Control

const Util = preload("res://Util.gd")

export(String) var consumer_name
export(String) var label setget label_set
export(float) var power_usage setget power_usage_set
export(bool) var power_state setget power_state_set

export(bool) var is_item = false
export(float) var energy = null setget energy_set
export(float) var energy_capacity = null setget energy_capacity_set

func label_set(new_label):
	label = new_label
	if !has_node("HBox/Label"):
		return
	$HBox/Label.text = new_label

func power_usage_set(new_power_usage):
	power_usage = new_power_usage
	if !has_node("HBox/PowerUsage"):
		return
	_update_power_usage()

func power_state_set(new_power_state):
	power_state = new_power_state
	if !has_node("HBox/PowerState") || !has_node("HBox/PowerUsage"):
		return
	$HBox/PowerState.text = "ON " if new_power_state else "OFF"
	var color = Color(0, 1, 0) if new_power_state else Color(1, 0, 0)
	$HBox/PowerState.add_color_override("font_color", color)
	$HBox/PowerState.add_color_override("font_color_hover", color)
	$HBox/PowerState.add_color_override("font_color_pressed", color)
	$HBox/PowerUsage.add_color_override("font_color", Color(1, 1, 1) if new_power_state else Color(0.5, 0.5, 0.5))


func energy_set(new_energy):
	new_energy = new_energy if !(Engine.editor_hint && new_energy == 0) else null
	energy = new_energy
	if has_node("Energy"):
		if new_energy != null:
			$Energy.value = new_energy
			if energy_capacity != null:
				_update_energy_label()
				$Energy.visible = true
				if has_node("HBox/Energy"):
					$HBox/Energy.visible = true
		else:
			$Energy.visible = false
			if has_node("HBox/Energy"):
				$HBox/Energy.visible = false
	if has_node("HBox/PowerUsage"):
		_update_power_usage()

func energy_capacity_set(new_energy_capacity):
	new_energy_capacity = new_energy_capacity if !(Engine.editor_hint && new_energy_capacity == 0) else null
	energy_capacity = new_energy_capacity
	if has_node("Energy"):
		if new_energy_capacity != null:
			$Energy.max_value = new_energy_capacity
			if energy != null:
				_update_energy_label()
				$Energy.visible = true
				if has_node("HBox/Energy"):
					$HBox/Energy.visible = true
		else:
			$Energy.visible = false
			if has_node("HBox/Energy"):
				$HBox/Energy.visible = false
	if has_node("HBox/PowerUsage"):
		_update_power_usage()

func _update_energy_label():
	$HBox/Energy.text = "%sW/\n%sW " % [Util.float_to_string_no_trailing(energy), Util.float_to_string_no_trailing(energy_capacity)]


func _update_power_usage():
	$HBox/PowerUsage.text = Util.float_to_string_no_trailing(power_usage) + "W"


func _ready():
	label_set(label)
	power_usage_set(power_usage)
	power_state_set(power_state)
	
	energy_set(energy)
	energy_capacity_set(energy_capacity)


func _on_PowerState_pressed():
	if is_item:
		var item = ItemVars.items[consumer_name]
		if item["energy"] >= item["energy_capacity"]:
			return
		item["charging"] = !power_state
		ItemVars.item_changed(consumer_name)
	else:
		PowerVars.consumers[consumer_name]["power_state"] = !power_state
		PowerVars.consumer_changed(consumer_name)
	power_state_set(!power_state)
