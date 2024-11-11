shader_type canvas_item;

uniform vec3 red;
uniform vec3 green;
uniform vec3 blue;
uniform float mult;

void fragment() {
	vec4 color = COLOR;
	if (mult > 0.0) {
		vec4 newColor = color;
		newColor.rgb = min(color.r * red + color.g * green + color.b * blue, vec3(1.0));
		newColor.a = color.a;

		color = mix(color, newColor, mult);
	}
	COLOR = color;
}