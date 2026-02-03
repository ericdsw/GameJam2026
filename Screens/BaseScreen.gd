class_name BaseScreen
extends Control


## True when the screen is on the tree and the TransitionCover already finished animating.
var screen_is_ready := false


############### Signals

@warning_ignore("unused_signal")
signal navigate_to_screen(screen_resource)

@warning_ignore("unused_signal")
signal update_bgm(bgm_path, fade_out_duration, silence_duration, fade_in_duration)


# ================================= Public ================================== #


## Overwrite this metod to perform some logic after the navigation finishes and
## the screen is loaded.
func navigation_finished() -> void:
	pass
