extends AudioStreamPlayer2D
## Self-destructing AudioStreamPlayer2D w/ persistence past parent freeing

var target : Node2D

func _physics_process(delta):
	if target and weakref(target).get_ref():
		global_position = target.global_position

## Destroy on finish
func _on_finished():
	queue_free()
