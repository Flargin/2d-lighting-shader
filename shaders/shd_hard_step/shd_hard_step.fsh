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

void main()
{
    vec4 color = texture2D(gm_BaseTexture, v_vTexcoord);
    
    float FALLOFF_WIDTH = 100.0;
    

    for(int i = 0; i < circleCount; i++) {
        float dist = distance(v_vTexcoord * screenSize, circlePos[i]);
        float alpha = clamp((dist - circleRadius[i]) / FALLOFF_WIDTH, 0.0, 0.9);
        color.a = min(alpha, color.a);
    }
    
    gl_FragColor = color;
}
