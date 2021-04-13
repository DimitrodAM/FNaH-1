extends Control


signal fullscreen
signal fullscreeened
signal close
signal closed


var ignore_fullscreen = false
var ignore_lower = false


func _on_FullscreenMonitor_pressed():
	if ignore_fullscreen:
		return
	$FullscreenMonitor.visible = false
	$LowerMonitor.visible = true
	emit_signal("fullscreen")
func fullscreened():
	emit_signal("fullscreeened")

func _on_LowerMonitor_pressed():
	if ignore_lower:
		return
	$LowerMonitor.visible = false
	$FullscreenMonitor.visible = true
	emit_signal("close")
func closed():
	emit_signal("closed")
