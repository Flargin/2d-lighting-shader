varying vec2 v_vTexcoord;
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform int u_rect_count;
uniform vec4 u_rects[40];

const int MAX_RECTS = 40;

// Returns true if the segment from eye to target is blocked by the box [mins, maxs]
bool rayBlockedByBox(vec2 eye, vec2 target, vec2 mins, vec2 maxs) {
    vec2 d = target - eye;
    vec2 invD = 1.0 / d;

    vec2 t0 = (mins - eye) * invD;
    vec2 t1 = (maxs - eye) * invD;

    vec2 tmin2 = min(t0, t1);
    vec2 tmax2 = max(t0, t1);

    float tmin = max(tmin2.x, tmin2.y);
    float tmax = min(tmax2.x, tmax2.y);

    // Intersection only valid if tmax >= tmin, and the hit is between eye and target
    return tmax >= tmin && tmin < 1.0 && tmax > 0.0;
}

int insideWall(vec2 p) {
    for (int i = 0; i < MAX_RECTS; i++) {
        if (i >= u_rect_count) break;
        vec2 mins = u_rects[i].xy;
        vec2 maxs = u_rects[i].zw;
        if (p.x > mins.x && p.x < maxs.x && p.y > mins.y && p.y < maxs.y) return i;
    }
    return -1;
}

void main() {
    vec2 uv  = v_vTexcoord * u_resolution;
    vec2 eye = u_mouse;

    int wallIndex = insideWall(uv);

    bool blocked = false;
    for (int i = 0; i < MAX_RECTS; i++) {
        if (i >= u_rect_count) break;
        if (i == wallIndex) continue;
        if (rayBlockedByBox(eye, uv, u_rects[i].xy, u_rects[i].zw)) {
            blocked = true;
            break;
        }
    }

    float visible = blocked ? 0.1 : 1.0;
    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0 - visible);
}