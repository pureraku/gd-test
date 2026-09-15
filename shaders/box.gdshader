shader_type spatial;

render_mode cull_back;

// ============================================================
// COLORS
// ============================================================

uniform vec4 wood_light : source_color =
	vec4(0.48, 0.24, 0.08, 1.0);

uniform vec4 wood_dark : source_color =
	vec4(0.20, 0.075, 0.025, 1.0);

uniform vec4 edge_color : source_color =
	vec4(0.10, 0.035, 0.012, 1.0);


// ============================================================
// WOOD SETTINGS
// ============================================================

uniform float grain_scale = 7.0;
uniform float grain_strength = 0.35;

uniform float plank_scale = 2.5;
uniform float plank_variation = 0.15;

uniform float edge_darkness = 0.45;


// ============================================================
// SIMPLE HASH
// ============================================================

float hash(vec2 p)
{
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);

	return fract(p.x * p.y);
}


// ============================================================
// NOISE
// ============================================================

float noise(vec2 p)
{
	vec2 i = floor(p);
	vec2 f = fract(p);

	f = f * f * (3.0 - 2.0 * f);

	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	return mix(
		mix(a, b, f.x),
		mix(c, d, f.x),
		f.y
	);
}


// ============================================================
// VORONOI-ISH PLANK VARIATION
// ============================================================

float plank_noise(vec2 p)
{
	float n = noise(p * plank_scale);

	return n * 2.0 - 1.0;
}


// ============================================================
// FRAGMENT
// ============================================================

void fragment()
{
	// --------------------------------------------------------
	// UV
	// --------------------------------------------------------

	vec2 uv = UV;


	// --------------------------------------------------------
	// Wood grain
	// --------------------------------------------------------

	// Stretch the noise horizontally to create grain
	vec2 grain_uv = vec2(
		uv.x * grain_scale,
		uv.y * grain_scale * 0.18
	);

	float grain = noise(grain_uv);

	// Multiple grain layers
	float grain2 = noise(
		grain_uv * 3.0 +
		vec2(4.7, 2.1)
	);

	float grain_pattern =
		grain * 0.7 +
		grain2 * 0.3;


	// --------------------------------------------------------
	// Wavy grain
	// --------------------------------------------------------

	float waves = sin(
		uv.x * 35.0 +
		sin(uv.y * 12.0) * 3.0
	);

	waves = waves * 0.5 + 0.5;

	float wood_pattern =
		grain_pattern * 0.65 +
		waves * 0.35;


	// --------------------------------------------------------
	// Plank variation
	// --------------------------------------------------------

	float plank = plank_noise(
		uv * plank_scale
	);

	wood_pattern += plank * plank_variation;

	wood_pattern = clamp(
		wood_pattern,
		0.0,
		1.0
	);


	// --------------------------------------------------------
	// Base color
	// --------------------------------------------------------

	vec3 wood = mix(
		wood_dark.rgb,
		wood_light.rgb,
		wood_pattern
	);


	// --------------------------------------------------------
	// Darken edges
	// --------------------------------------------------------

	float edge_x = min(
		uv.x,
		1.0 - uv.x
	);

	float edge_y = min(
		uv.y,
		1.0 - uv.y
	);

	float edge = min(
		edge_x,
		edge_y
	);

	float edge_mask =
		1.0 - smoothstep(
			0.0,
			0.18,
			edge
		);

	wood = mix(
		wood,
		edge_color.rgb,
		edge_mask * edge_darkness
	);


	// --------------------------------------------------------
	// Slight lighting variation
	// --------------------------------------------------------

	float lighting_noise =
		noise(uv * 5.0);

	wood *= mix(
		0.88,
		1.08,
		lighting_noise
	);


	// --------------------------------------------------------
	// Output
	// --------------------------------------------------------

	ALBEDO = wood;

	ROUGHNESS = 0.72;

	SPECULAR = 0.25;
}