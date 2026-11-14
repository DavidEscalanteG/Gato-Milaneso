shader_type canvas_item;

uniform bool active = false;
uniform vec4 tint = vec4(0., 0., 0., 1.);

varying vec4 canvas_modulate;

void vertex() {
	canvas_modulate = COLOR;
}

void fragment() {
	vec4 new_tint;
	vec4 previous_tint = texture(TEXTURE, UV);

	if (active == true)
	{
		float gris = dot(previous_tint.rgb, vec3(.2126,.7152,.0722));
		new_tint.rgb = vec3(gris) * tint.rgb * 3.5;
		new_tint.a = previous_tint.a;
		COLOR = new_tint * canvas_modulate;
	}
}