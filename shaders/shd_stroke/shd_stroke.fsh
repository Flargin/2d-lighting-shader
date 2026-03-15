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
    
    float FALLOFF = 5.0;
    
    
    
    for(int i = 0; i < circleCount; i++) {
        float dist = distance(v_vTexcoord * screenSize, circlePos[i]);
        if(dist < circleRadius[i] + FALLOFF) {
            color = vec4(circleColor[i], 0.75);
        }
    }
    
    for(int i = 0; i < circleCount; i++) {
        float dist = distance(v_vTexcoord * screenSize, circlePos[i]);
        if(dist < circleRadius[i]) {
            color.a = 0.5;
            color.rgb = (circleColor[i]);
        }
    }
    
    gl_FragColor = color;
}
