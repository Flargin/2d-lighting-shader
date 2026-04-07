varying vec2 v_vTexcoord;

uniform vec2 u_resolution;
uniform vec2 u_mouse;

uniform int u_rect_count;
uniform vec4 u_rects[40];

const int MAX_STEPS = 2500;
const int MAX_RECTS = 40;
const float MAX_DIST = 100.0;
const float EPSILON = 0.0001;

float sdBox(vec2 p, vec2 mins, vec2 maxs) {
    vec2 center   = (mins + maxs) * 0.5;
    vec2 halfSize = (maxs - mins) * 0.5;
    vec2 d = abs(p - center) - halfSize;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Returns the index of the wall the point is inside, or -1 if none
int insideWall(vec2 p) {
    for (int i = 0; i < MAX_RECTS; i++) {
        if (i >= u_rect_count) break;
        vec2 mins = u_rects[i].xy / u_resolution.y;
        vec2 maxs = u_rects[i].zw / u_resolution.y;
        if (sdBox(p, mins, maxs) < 0.0) return i;
    }
    return -1;
}

float sdSceneExcluding(vec2 p, int exclude) {
    float d = MAX_DIST;
    for (int i = 0; i < MAX_RECTS; i++) {
        if (i >= u_rect_count) break;
        if (i == exclude) continue;
        vec2 mins = u_rects[i].xy / u_resolution.y;
        vec2 maxs = u_rects[i].zw / u_resolution.y;
        d = min(d, sdBox(p, mins, maxs));
    }
    return d;
}

float sdScene(vec2 p) {
    float d = MAX_DIST;
    for (int i = 0; i < MAX_RECTS; i++) {
        if (i >= u_rect_count) break;
        vec2 mins = u_rects[i].xy / u_resolution.y;
        vec2 maxs = u_rects[i].zw / u_resolution.y;
        d = min(d, sdBox(p, mins, maxs));
    }
    return d;
}

float map(vec2 uv, vec2 eye, int excludeWall) {
    vec2 eyeVec = uv - eye;
    float maxDist = length(eyeVec);
    vec2 eyeVecNorm = normalize(eyeVec);
    float depth = 0.0;
    for (int i = 0; i < MAX_STEPS; ++i) {
        vec2 p = eye + eyeVecNorm * depth;
        float dist = excludeWall >= 0 ? sdSceneExcluding(p, excludeWall) : sdScene(p);
        if (dist < EPSILON) {
            return depth - maxDist;
        }
        depth += dist;
        if (depth > maxDist) {
            return MAX_DIST;
        }
        if (depth > MAX_DIST) {
            return MAX_DIST;
        }
    }
    return depth;
}

void main() {
    vec2 fragCoord = v_vTexcoord * u_resolution;
    vec2 uv = vec2(fragCoord.x, fragCoord.y) / u_resolution.y;
    vec2 eye = vec2(u_mouse.x, u_mouse.y) / u_resolution.y;

    int wallIndex = insideWall(uv);

    float eyeDist = map(uv, eye, wallIndex);
    float visible = eyeDist >= 0.0 ? 1.0 : 0.0;

    gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0 - visible);
}