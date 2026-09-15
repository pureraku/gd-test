shader_type spatial;

render_mode cull_back;

// ============================================================
// PLAYER COLORS
// ============================================================

uniform vec4 base_color : source_color =
	vec4(0.12, 0.35, 0.75, 1.0);

uniform vec4 highlight_color : source_color =
	vec4(0.25, 0.65, 1.0, 1.0);

uniform vec4 dark_color : source_color =
	vec4(0.025, 0.06, 0.15, 1.0);


// ============================================================
// ANIMATION
// ============================================================

uniform float pulse_speed = 1.5;
uniform float pulse_strength = 0.15;

uniform float rim_strength = 1.5;


// ============================================================
// VERTEX
// ============================================================

void vertex()
{
	// Very subtle breathing effect
	float pulse = sin(TIME * pulse_speed) * 0.015;

	VERTEX += NORMAL * pulse;
}


// ============================================================
// FRAGMENT
// ============================================================

void fragment()
{
	// --------------------------------------------------------
	// Fresnel / rim lighting
	// --------------------------------------------------------

	float fresnel = pow(
		1.0 - max(dot(NORMAL, VIEW), 0.0),
		3.0
	);

	// --------------------------------------------------------
	// Animated pulse
	// --------------------------------------------------------

	float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;

	// --------------------------------------------------------
	// Vertical gradient
	// --------------------------------------------------------

	float height_gradient = UV.y;

	vec3 color = mix(
		dark_color.rgb,
		base_color.rgb,
		height_gradient
	);

	// --------------------------------------------------------
	// Subtle animated highlight
	// --------------------------------------------------------

	color = mix(
		color,
		highlight_color.rgb,
		pulse * pulse_strength
	);

	// --------------------------------------------------------
	// Rim light
	// --------------------------------------------------------

	color += highlight_color.rgb *
		fresnel *
		rim_strength;

	// --------------------------------------------------------
	// Output
	// --------------------------------------------------------

	ALBEDO = color;

	ROUGHNESS = 0.35;

	SPECULAR = 0.65;
}