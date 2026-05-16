shader_type canvas_item;

uniform vec2 output_size = vec2(100.0, 100.0);

uniform sampler2D noise1;
uniform sampler2D noise2;

uniform vec2 scroll_speed1 = vec2(0.01, 0.0);
uniform vec2 scroll_speed2 = vec2(0.0, 0.01);

uniform vec4 water_base_color : source_color = vec4(0.2, 0.47, 0.84, 1.);
uniform vec4 water_foam_color : source_color = vec4(0.63, 0.81, 1., 1.);

uniform float foam_threshold : hint_range(0.0, 1.0) = 0.72;
uniform float foam_softness : hint_range(0.001, 0.2) = 0.05;
uniform float water_darkness : hint_range(0.0, 1.0) = 0.4;

uniform float aspect_ratio = 1.0;
uniform vec2 hole_pos_uv = vec2(0.5, 0.5);
uniform float hole_rad = 0.5;

uniform float hole_foam_thickness = 0.2;
uniform vec4 hole_floam_main_color : source_color = vec4(1.);
uniform vec4 hole_floam_secondary_color : source_color = vec4(0.63, 0.81, 1., 1.);

vec2 uv_to_xy(vec2 uv) {
    return vec2(uv.x * aspect_ratio, uv.y);
}

vec2 xy_to_uv(vec2 xy) {
    return vec2(xy.x / aspect_ratio, xy.y);
}

float sqr(float x) {
    return x * x;
}

float dist_sqr(vec2 a, vec2 b) {
    return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
}

vec3 get_water_color(vec4 n1, vec4 n2) {
    // Combined noise value (grayscale)
    float noise_val = sqrt(n1.r * n2.r);
    
    // Water: blend water_base_color darkened in troughs, lighter on crests
    vec3 water = mix(water_base_color.rgb * water_darkness, water_base_color.rgb, step(0.5, noise_val));
    
    // Foam: soft threshold near the bright peaks of the noise
    float foam_amount = step(foam_threshold - foam_softness, noise_val);
    
    // Composite foam over water
    return mix(water, water_foam_color.rgb, foam_amount * water_foam_color.a);
}

vec4 get_foam_circle(vec2 xy, vec2 center, float r, float thickness, vec4 noise) {
    float x = ((1. - abs(sqrt(dist_sqr(xy, center)) - r)) - 1.0 + thickness) / thickness;
    x *= noise.r;
    float mask = step(0.5, x);
    vec3 col = mix(hole_floam_secondary_color.rgb, hole_floam_main_color.rgb, step(0.75, x));

    return vec4(vec3(col*mask), mask);
}

void fragment() {
    vec2 uv = UV;
    vec2 xy = uv_to_xy(UV);
    vec2 hole_pos_xy = uv_to_xy(hole_pos_uv);
    vec4 n1 = texture(noise1, mod(uv + TIME * scroll_speed1, vec2(1.0)));
    vec4 n2 = texture(noise2, mod(uv + TIME * scroll_speed2, vec2(.5)));
    vec4 n3 = (1. - n1) + (1. - n2);

    vec3 water_color = get_water_color(n1, n2);
    float water_a = step(sqr(hole_rad), dist_sqr(xy, hole_pos_xy));

    vec4 foam = get_foam_circle(xy, hole_pos_xy, hole_rad, hole_foam_thickness, n3);

    vec4 col = vec4(mix(water_color, foam.xyz, foam.a), max(water_a, foam.a));
    
    col.a *= water_base_color.a;
    COLOR = col;
}
