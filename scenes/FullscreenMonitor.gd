extends Control


signal fullscreen
signal fullscreeened
signal close
signal closed


var _inside_lower = false
var ignore_fullscreen = false
var ignore_lower = false


func _on_FullscreenMonitor_pressed():
	if ignore_fullscreen:
		return
	if $LowerMonitor.get_rect().has_point(get_viewport().get_mouse_position()):
		_inside_lower = true
	$FullscreenMonitor.visible = false
	$LowerMonitor.visible = true
	emit_signal("fullscreen")
func fullscreened():
	emit_signal("fullscreeened")

func _on_LowerMonitor_mouse_exited():
	_inside_lower = false
func _on_LowerMonitor_mouse_entered():
	if ignore_lower or _inside_lower:
		return
	$LowerMonitor.visible = false
	$FullscreenMonitor.visible = true
	emit_signal("close")
func closed():
	emit_signal("closed")
