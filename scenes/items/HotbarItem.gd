tool
extends Button

export(String) var item_name
export(String) var label setget label_set, label_get
export(bool) var active setget active_set, active_get

func label_set(new_label):
	label = new_label
	if !has_node("Label"):
		return
	$Label.text = new_label
func label_get():
	return label

func active_set(new_active):
	active = new_active
	pressed = active
func active_get():
	return active


func _ready():
	label_set(label)
	active_set(active)


func _on_Button_pressed():
	ItemVars.items[item_name]["active"] = !active
	ItemVars.item_changed(item_name)
	active_set(!active)
