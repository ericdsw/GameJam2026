class_name BaseScreen
extends Control


var screen_is_ready := false


@warning_ignore("unused_signal")
signal navigate_to_screen(screen_resource)

@warning_ignore("unused_signal")
signal shake_camera(intensity, duration)

@warning_ignore("unused_signal")
signal update_bgm(bgm_path, fade_out_duration, silence_duration, fade_in_duration)


## Can be overwritten by the screens to know when they are ready to be used.
func navigation_finished() -> void:
	pass
