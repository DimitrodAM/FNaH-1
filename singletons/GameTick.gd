extends Node

const TICK_LENGTH = 1.0 / 20

var delta = 0


func _physics_process(current_delta):
	delta += current_delta
	if delta < TICK_LENGTH:
		return
	get_tree().call_group("notify_tick_pr1", "on_tick", delta)
	get_tree().call_group("notify_tick", "on_tick", delta)
	get_tree().call_group("notify_tick_pr-1", "on_tick", delta)
	delta -= TICK_LENGTH
