#language slang 2026
// Komorebi: soft shadows of leaves swaying over the terminal, as if it sat under a tree by a window.
// Original shader. Light themes get warm sunlight with cool leaf shadows; dark themes get faint moonlight.

import kitty_custom_shader_types;

// Controls overridden by komorebi.pipeline.
static const float LEAF_STRENGTH = 1.0;  // Overall effect strength.
static const float LEAF_SWAY = 1.0;      // Sway speed; 0 holds the leaves still.
static const float LEAF_SCALE = 2.6;     // Canopy gap size; higher values give smaller gaps.
static const float FLECK_CELLS = 9.0;    // Sun flecks across the window height; higher gives more, smaller flecks.

static const float BG_TOLERANCE = 0.02;

static float
hash(float2 p) {
    p = frac(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return frac(p.x * p.y);
}

static float
vnoise(float2 p) {
    float2 i = floor(p);
    float2 f = frac(p);
    float2 u = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(hash(i), hash(i + float2(1.0, 0.0)), u.x),
                lerp(hash(i + float2(0.0, 1.0)), hash(i + float2(1.0, 1.0)), u.x), u.y);
}

static float
fbm(float2 p) {
    float s = 0.0, a = 0.5;
    for (int i = 0; i < 4; i++) {
        s += a * vnoise(p);
        p = float2(p.x * 1.6 - p.y * 1.2, p.x * 1.2 + p.y * 1.6) + 17.1;
        a *= 0.5;
    }
    return s;
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    float3 diff = abs(color.rgb - d.background.rgb);
    float bg = 1.0 - smoothstep(0.0, BG_TOLERANCE, max(max(diff.r, diff.g), diff.b));
    if (bg <= 0.0) return color;

    float2 res = max(float2(d.viewport_size_pixels) * t.viewport.zw, float2(1.0));
    float2 uv = float2(t.pos.x * res.x / res.y, t.pos.y);
    // Wrap at 10 minutes: every sway term below repeats over that period, so there is no jump.
    float time = d.wrapped_time(600u) * LEAF_SWAY;
    float w = 6.2831853 / 600.0;

    // Branches sway as a whole, and the leaves on them flutter a little on top.
    float2 sway = float2(sin(time * w * 50.0), sin(time * w * 37.0 + 1.3)) * 0.035;
    float2 flutter = float2(sin(time * w * 130.0 + uv.y * 4.0), cos(time * w * 110.0 + uv.x * 4.0)) * 0.008;

    // Gaps in the canopy: broad regions where light gets through. They sway, and creep sideways
    // as the sun moves, crossing the window in roughly ten minutes.
    float2 drift = float2(d.timestamp * 0.004, 0.0);
    float gap = smoothstep(0.42, 0.62, fbm(uv * LEAF_SCALE + drift + sway + flutter));

    float light = smoothstep(0.25, 0.65, dot(d.background.rgb, float3(0.2126, 0.7152, 0.0722)));
    // Under solid canopy there is no sunlight: dark themes are left untouched, so stop here.
    if (gap <= 0.0 && light <= 0.0) return color;

    // Sun flecks: each gap between leaves acts as a pinhole, so the light lands as soft round spots.
    // Skip the nine-cell search under solid canopy, where the flecks would be multiplied by zero.
    float2 g = uv * FLECK_CELLS;
    float2 gi = floor(g), gf = frac(g);
    float fleck = 0.0;
    if (gap > 0.0) for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            float2 o = float2(float(i), float(j));
            float h1 = hash(gi + o), h2 = hash(gi + o + 3.7), h3 = hash(gi + o + 9.1);
            float2 c = o + 0.5 + (float2(h1, h2) - 0.5) * 0.6 + (sway + flutter) * FLECK_CELLS * (0.6 + h3 * 0.8);
            float r = 0.16 + 0.26 * h3;
            // Squash vertically: low sunlight stretches the spots into ellipses.
            fleck = max(fleck, smoothstep(r, r * 0.55, length((gf - c) * float2(1.0, 1.35))));
        }
    }
    float sun = saturate(max(fleck * gap, gap * 0.22));
    float shade = 1.0 - sun;

    // Light falls in from the top-right; the effect fades toward the bottom-left.
    float envelope = saturate(0.35 + 0.65 * (t.pos.y * 0.6 + t.pos.x * 0.4)) * LEAF_STRENGTH;

    // Light: cool green-grey shadows and a slight warm cast where the sun gets through.
    float3 day = color.rgb * lerp(float3(1.0), float3(0.84, 0.88, 0.85), shade * envelope);
    day *= lerp(float3(1.0), float3(1.02, 1.0, 0.92), sun * envelope);
    // Dark: only the sun flecks glow, as cold moonlight.
    float3 night = color.rgb + float3(0.022, 0.032, 0.055) * sun * envelope;
    float3 col = lerp(night, day, light);

    return float4(lerp(color.rgb, saturate(col), bg), color.a);
}
