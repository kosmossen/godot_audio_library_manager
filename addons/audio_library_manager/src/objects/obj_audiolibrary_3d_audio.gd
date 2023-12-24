extends AudioStreamPlayer3D
## Self-destructing AudioStreamPlayer3D w/ persistence past parent freeing

var target : Node3D

func _physics_process(delta):
	if target and weakref(target).get_ref():
		global_position = target.global_position

## Destroy on finish
func _on_finished():
	queue_free()
