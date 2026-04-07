//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 circlePos[40];
uniform float circleRadius[40];
uniform vec3 circleColor[40];
uniform int circleCount;
uniform vec2 screenSize;
uniform float currentStep;

float smin(float a, float b, float k) {
    k *= 4.0;
    float x =   (b-a)/k;
    float g =   (x > 1.0) ? x :
                (x < -1.0) ? 0.0 :
                (x * (2.0 + x) + 1.0) / 4.0;
    return b - k * g;
}

vec2 pixToScreenCoords(vec2 p) {
    p /= screenSize;
    p -= vec2(0.5);
    p.x * screenSize.x / screenSize.y;
    return p;
}

void main()
{
    vec4 color = texture2D(gm_BaseTexture, v_vTexcoord);
    
    float FALLOFF_WIDTH = 40.0;
    
    for(int i = 0; i < circleCount; i++) {
        float dist = distance(v_vTexcoord * screenSize, circlePos[i]);
        float X = clamp((dist - circleRadius[i]) / FALLOFF_WIDTH, 0., 1.);
        float alpha = 3.0 * pow(X, 2.0) + 2.0 * pow(X, 3.0);
        
        color.a = min(alpha, color.a);
    }
    
    gl_FragColor = color;
}
