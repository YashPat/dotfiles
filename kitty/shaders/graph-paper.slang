#language slang 2026
// Graph paper: faint grid with a heavier line every few cells.
// Original shader. Blue ink on light themes, blueprint cyan on dark themes.
// Static: draws only on background pixels and needs no animation clock.

import kitty_custom_shader_types;

// Controls overridden by graph-paper.pipeline.
static const float GRID_PX = 40.0;       // Minor grid spacing in physical pixels.
static const float GRID_MAJOR = 5.0;     // Minor cells per major line.
static const float GRID_STRENGTH = 1.0;  // Overall line strength.

static const float BG_TOLERANCE = 0.02;

// Coverage of a line of the given width (pixels) for a grid with the given spacing (pixels).
static float
grid_line(float2 px, float spacing, float width) {
    float2 dist = abs(frac(px / spacing - 0.5) - 0.5) * spacing;   // Pixels to the nearest line.
    return 1.0 - saturate(min(dist.x, dist.y) - width * 0.5 + 0.5);
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    float3 diff = abs(color.rgb - d.background.rgb);
    float bg = 1.0 - smoothstep(0.0, BG_TOLERANCE, max(max(diff.r, diff.g), diff.b));
    if (bg <= 0.0) return color;

    float2 res = max(float2(d.viewport_size_pixels) * t.viewport.zw, float2(1.0));
    // Anchor the grid at the top-left corner so resizing the window keeps the top row steady.
    float2 px = float2(t.pos.x, 1.0 - t.pos.y) * res;

    float minor = grid_line(px, GRID_PX, 1.0);
    float major = grid_line(px, GRID_PX * GRID_MAJOR, 1.5);

    float light = smoothstep(0.25, 0.65, dot(d.background.rgb, float3(0.2126, 0.7152, 0.0722)));
    float3 ink = lerp(float3(0.20, 0.50, 0.85), float3(0.04, 0.18, 0.62), light);
    float a = max(minor * lerp(0.06, 0.10, light), major * lerp(0.13, 0.20, light)) * GRID_STRENGTH;

    return float4(lerp(color.rgb, ink, saturate(a) * bg), color.a);
}
