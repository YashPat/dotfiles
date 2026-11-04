#language slang 2026
// Ink wash: slow, domain-warped clouds of ink drifting behind the text.
// Original shader. Light themes get dark sumi-ink blooms; dark themes get faint indigo smoke.

import kitty_custom_shader_types;

// Controls overridden by ink-wash.pipeline.
static const float INK_STRENGTH = 1.0;  // Overall effect strength.
static const float INK_SPEED = 0.02;    // Drift speed; 0 freezes the pattern.
static const float INK_SCALE = 2.2;     // Cloud size; higher values give smaller clouds.

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
fbm(float2 p, int octaves) {
    float s = 0.0, a = 0.5;
    for (int i = 0; i < octaves; i++) {
        s += a * vnoise(p);
        // Rotate and double the frequency each octave to hide the lattice.
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
    float2 p = float2(t.pos.x * res.x / res.y, t.pos.y) * INK_SCALE;
    float time = d.timestamp * INK_SPEED;

    // Two levels of domain warping turn plain noise into curling, ink-like filaments.
    // The warp fields only bend the final noise, so they get fewer octaves; fine detail comes from the last fbm.
    float2 q = float2(fbm(p + float2(0.0, time), 3), fbm(p + float2(5.2, 1.3) - time * 0.7, 3));
    float2 r = float2(fbm(p + 3.0 * q + float2(1.7, 9.2) + time * 0.4, 3), fbm(p + 3.0 * q + float2(8.3, 2.8), 3));
    float f = fbm(p + 2.5 * r, 5);
    float density = smoothstep(0.40, 0.85, f) * INK_STRENGTH;

    float light = smoothstep(0.25, 0.65, dot(d.background.rgb, float3(0.2126, 0.7152, 0.0722)));
    // Dark themes: add a faint teal-to-violet glow.
    float3 smoke = lerp(float3(0.05, 0.22, 0.28), float3(0.22, 0.08, 0.36), saturate(q.x * 1.4 - 0.2));
    float3 glow = color.rgb + smoke * density * 0.20;
    // Light themes: multiply by an indigo ink tint so the wash darkens like watercolor.
    float3 ink = color.rgb * lerp(float3(1.0), float3(0.55, 0.60, 0.78), saturate(density * 0.45));
    float3 col = lerp(glow, ink, light);

    return float4(lerp(color.rgb, saturate(col), bg), color.a);
}
