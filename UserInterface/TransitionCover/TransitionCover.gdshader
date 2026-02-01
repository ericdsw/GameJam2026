shader_type canvas_item;
render_mode unshaded;

uniform float cutoff : hint_range(0.0, 1.0);
uniform float smooth_size : hint_range(0.0, 1.0);
uniform sampler2D mask : source_color;

void fragment() {
	float value = textureLod(mask, UV, 0.0).r;
	float lower_range = cutoff + smooth_size;
	float upper_range = cutoff;
	float alpha = smoothstep(lower_range, upper_range, value * (1.0 - smooth_size) + smooth_size);
	COLOR = vec4(COLOR.rgb, alpha);
}