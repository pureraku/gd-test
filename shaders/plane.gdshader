shader_type spatial;

render_mode cull_back;

// ============================================================
// COLORS
// ============================================================

uniform vec4 deep_color : source_color =
	vec4(0.005, 0.035, 0.10, 1.0);

uniform vec4 shallow_color : source_color =
	vec4(0.02, 0.30, 0.42, 1.0);


// ============================================================
// LARGE WAVE SETTINGS
// ============================================================

uniform float wave_height = 0.25;
uniform float wave_length = 4.0;
uniform float wave_speed = 1.2;

uniform float wave_2_height = 0.12;
uniform float wave_2_length = 2.5;

uniform float wave_3_height = 0.06;
uniform float wave_3_length = 1.4;


// ============================================================
// SURFACE SETTINGS
// ============================================================

uniform float ripple_strength = 0.25;
uniform float ripple_scale = 12.0;
uniform float ripple_speed = 0.8;

uniform float roughness : hint_range(0.0, 1.0) = 0.08;


// ============================================================
// GERSTNER WAVE
// ============================================================

vec3 gerstner_wave(
	vec3 position,
	vec2 direction,
	float steepness,
	float wavelength,
	float height,
	float speed
)
{
	// Normalize direction
	direction = normalize(direction);

	// Wave number
	float k = 2.0 * PI / wavelength;

	// Angular frequency
	float omega = sqrt(9.8 * k);

	// Phase
	float phase =
		k * (
			direction.x * position.x +
			direction.y * position.z
		)
		- omega * speed * TIME;

	float wave_value = sin(phase);
	float wave_cos = cos(phase);

	// Gerstner steepness
	float q = steepness / (k * height);

	vec3 result;

	// Horizontal displacement
	result.x =
		direction.x *
		q *
		height *
		wave_cos;

	result.z =
		direction.y *
		q *
		height *
		wave_cos;

	// Vertical displacement
	result.y =
		height *
		wave_value;

	return result;
}


// ============================================================
// VERTEX
// ============================================================

void vertex()
{
	vec3 position = VERTEX;

	vec3 displacement = vec3(0.0);

	// Large wave
	displacement += gerstner_wave(
		position,
		vec2(1.0, 0.2),
		0.65,
		wave_length,
		wave_height,
		wave_speed
	);

	// Second wave from another direction
	displacement += gerstner_wave(
		position,
		vec2(-0.4, 1.0),
		0.5,
		wave_2_length,
		wave_2_height,
		wave_speed * 0.8
	);

	// Small wave
	displacement += gerstner_wave(
		position,
		vec2(0.7, -0.7),
		0.35,
		wave_3_length,
		wave_3_height,
		wave_speed * 1.4
	);

	// Apply displacement
	VERTEX += displacement;
}


// ============================================================
// FRAGMENT
// ============================================================

void fragment()
{
	// --------------------------------------------------------
	// Small animated ripples
	// --------------------------------------------------------

	vec2 p = UV * ripple_scale;

	p += vec2(
		TIME * ripple_speed,
		TIME * ripple_speed * 0.6
	);

	float ripple1 = sin(
		p.x * 4.0 +
		sin(p.y * 3.0)
	);

	float ripple2 = sin(
		p.y * 5.0 +
		sin(p.x * 2.0)
	);

	float ripple3 = sin(
		p.x * 7.0 +
		p.y * 4.0 -
		TIME
	);

	float ripple =
		(ripple1 + ripple2 + ripple3) / 3.0;


	// --------------------------------------------------------
	// Fake small surface normal movement
	// --------------------------------------------------------

	vec3 water_normal = normalize(
		vec3(
			ripple * ripple_strength,
			1.0,
			ripple * ripple_strength
		)
	);

	NORMAL = water_normal;


	// --------------------------------------------------------
	// Fresnel
	// --------------------------------------------------------

	float fresnel = pow(
		1.0 - max(dot(NORMAL, VIEW), 0.0),
		4.0
	);


	// --------------------------------------------------------
	// Water color
	// --------------------------------------------------------

	float color_amount =
		ripple * 0.5 + 0.5;

	vec3 water_color = mix(
		deep_color.rgb,
		shallow_color.rgb,
		color_amount * 0.35
	);


	// Fresnel highlight

	water_color = mix(
		water_color,
		shallow_color.rgb,
		fresnel * 0.85
	);


	// --------------------------------------------------------
	// Output
	// --------------------------------------------------------

	ALBEDO = water_color;

	ROUGHNESS = roughness;

	SPECULAR = 0.95;
}