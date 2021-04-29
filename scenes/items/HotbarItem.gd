tool
extends Button

const Util = preload("res://Util.gd")

# Are getters optional?
export(Texture) var plug_in_icon setget plug_in_icon_set
export(Texture) var plugged_in_icon setget plugged_in_icon_set

export(String) var item_name
export(String) var label setget label_set
export(bool) var active setget active_set
var location setget location_set
export(bool) var plugged_in setget plugged_in_set
export(float) var energy setget energy_set
# export(float) var energy_usage setget energy_usage_set
export(float) var energy_usage
export(float) var energy_capacity setget energy_capacity_set
export(bool) var out_of_energy setget out_of_energy_set

var current_room setget current_room_set

func plug_in_icon_set(new_plug_in_icon):
	plug_in_icon = new_plug_in_icon
	if !has_node("PlugIn"):
		return
	if !plugged_in:
		$PlugIn.icon = new_plug_in_icon

func plugged_in_icon_set(new_plugged_in_icon):
	plugged_in_icon = new_plugged_in_icon
	if !has_node("PlugIn"):
		return
	if plugged_in:
		$PlugIn.icon = new_plugged_in_icon


func label_set(new_label):
	label = new_label
	if !has_node("Label"):
		return
	$Label.text = new_label

func active_set(new_active):
	active = new_active
	pressed = new_active

func location_set(new_location):
	location = new_location
	_update_disabled()

func plugged_in_set(new_plugged_in):
	plugged_in = new_plugged_in
	if !has_node("PlugIn"):
		return
	$PlugIn.pressed = new_plugged_in
	$PlugIn.icon = plugged_in_icon if new_plugged_in else plug_in_icon

func energy_set(new_energy):
	energy = new_energy
	if !has_node("Energy/Label"):
		return
	$Energy.value = new_energy
	$Energy/Label.text = Util.float_to_string_no_trailing(new_energy) + " Ws"

func energy_capacity_set(new_energy_capacity):
	energy_capacity = new_energy_capacity
	if !has_node("Energy"):
		return
	$Energy.max_value = new_energy_capacity

func out_of_energy_set(new_out_of_energy):
	out_of_energy = new_out_of_energy
	_update_disabled()


func current_room_set(new_current_room):
	current_room = new_current_room
	var can_be_plugged_in = ItemVars.can_be_plugged_in_inside_room(new_current_room) if !Engine.editor_hint else true
	if !has_node("PlugIn"):
		return
	if plugged_in:
		$PlugIn.disabled = !can_be_plugged_in
	else:
		$PlugIn.visible = can_be_plugged_in
	_update_disabled()


func _update_disabled():
	disabled = out_of_energy if location == null \
		else location != current_room


func _ready():
	plug_in_icon_set(plug_in_icon)
	plugged_in_icon_set(plugged_in_icon)
	
	label_set(label)
	active_set(active)
	location_set(location)
	plugged_in_set(plugged_in)
	energy_set(energy)
	energy_capacity_set(energy_capacity)
	out_of_energy_set(out_of_energy)
	
	current_room_set(current_room)


func _on_Button_pressed():
	if out_of_energy:
		return
	ItemVars.items[item_name]["active"] = !active
	ItemVars.item_changed(item_name)

func _on_PlugIn_pressed():
	if !ItemVars.can_be_plugged_in_inside_room(current_room):
		return
	if !plugged_in:
		ItemVars.items[item_name]["location"] = RoomVars.current_room
		ItemVars.items[item_name]["plugged_in"] = true
		ItemVars.item_changed(item_name)
	else:
		ItemVars.items[item_name]["location"] = null
		ItemVars.items[item_name]["plugged_in"] = false
		ItemVars.items[item_name]["charging"] = false
		ItemVars.item_changed(item_name)
