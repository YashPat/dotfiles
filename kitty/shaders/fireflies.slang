#language slang 2026
// Fireflies: sparse glowing specks that wander, blink and rise slowly; they light up near the mouse.
// Original shader. Warm glow on dark themes; on light themes they become drifting amber pollen.

import kitty_custom_shader_types;

// Controls overridden by fireflies.pipeline.
static const float FLY_CELL_PX = 150.0;  // One possible firefly per cell of this size (physical pixels).
static const float FLY_DENSITY = 0.45;   // Fraction of cells that hold a firefly.
static const float FLY_BRIGHT = 0.35;    // Peak glow brightness.
static const float FLY_RISE = 6.0;       // Upward drift in pixels per second.

static const float BG_TOLERANCE = 0.02;
static const float MOUSE_RADIUS_PX = 320.0;

static float
hash(float2 p) {
    p = frac(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return frac(p.x * p.y);
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    float3 diff = abs(color.rgb - d.background.rgb);
    float bg = 1.0 - smoothstep(0.0, BG_TOLERANCE, max(max(diff.r, diff.g), diff.b));
    if (bg <= 0.0) return color;

    float2 res = max(float2(d.viewport_size_pixels) * t.viewport.zw, float2(1.0));
    float2 px = t.pos * res;
    // Wrap at an hour; the field jumps once then, which is invisible among blinking specks.
    float time = d.wrapped_time(3600u);

    // The whole field rises slowly, so fireflies leave at the top and new ones arrive from below.
    float2 field = (px - float2(0.0, time * FLY_RISE)) / FLY_CELL_PX;
    float2 id = floor(field);
    float2 f = frac(field);

    float h1 = hash(id), h2 = hash(id + 7.31), h3 = hash(id + 13.17);
    if (h3 > FLY_DENSITY) return color;

    // Wander inside the middle of the cell so the glow never reaches the cell edge and gets clipped.
    float2 center = 0.5 + 0.2 * float2(sin(time * (0.25 + 0.3 * h1) + h1 * 6.28),
                                       cos(time * (0.2 + 0.3 * h2) + h2 * 6.28));
    float dist = length(f - center) * FLY_CELL_PX;
    // Beyond this the glow is under a thousandth of its peak; most pixels stop here.
    if (dist > 45.0) return color;

    // Each firefly is lit only part of the time, on its own rhythm.
    float blink = smoothstep(0.35, 1.0, sin(time * (0.4 + 0.6 * h2) + h1 * 40.0));
    // Fireflies near the mouse pointer glow steadily.
    float2 world = (id + center) * FLY_CELL_PX + float2(0.0, time * FLY_RISE);
    float near = 1.0 - smoothstep(0.0, MOUSE_RADIUS_PX, length(world - d.mouse_pos.xy * res));
    blink = max(blink, near * 0.9);

    float core = exp(-dist * dist / (2.0 * 3.0 * 3.0));
    float halo = exp(-dist * dist / (2.0 * 11.0 * 11.0));
    float g = (core + halo * 0.35) * blink * FLY_BRIGHT;

    float light = smoothstep(0.25, 0.65, dot(d.background.rgb, float3(0.2126, 0.7152, 0.0722)));
    float3 glow = color.rgb + float3(0.60, 0.80, 0.15) * g;                       // Dark: add warm light.
    float3 pollen = color.rgb * (1.0 - saturate(g * 1.6) * float3(0.25, 0.45, 0.85)); // Light: amber specks.
    float3 col = lerp(glow, pollen, light);

    return float4(lerp(color.rgb, saturate(col), bg), color.a);
}
