@tool
class_name AudioLibraryStatus extends Resource
## Audio Library Manager Status
##
## The AudioLibraryStatus class is used to store and represent an audio library status.

signal status_updated

enum STATUS {
	OK,
	WARN,
	CRIT,
	NEUTRAL
}
const STATUS_COLOR = {
	STATUS.OK : Color.GREEN,
	STATUS.WARN : Color.ORANGE,
	STATUS.CRIT : Color.RED,
	STATUS.NEUTRAL : Color.WHITE
}

@export var status_type : STATUS = STATUS.OK:
	set(v):
		status_type = v
		emit_signal("status_updated")
@export var status_msg : String = "OK":
	set(v):
		status_msg = v
		emit_signal("status_updated")
