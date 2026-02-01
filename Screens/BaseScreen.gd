class_name BaseScreen
extends Control


var screen_is_ready := false


@warning_ignore("unused_signal")
signal navigate_to_screen(screen_resource)


## Can be overwritten by the screens to know when they are ready to be used.
func navigation_finished() -> void:
	pass
