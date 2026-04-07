//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 circlePos[40];
uniform float circleRadius[40];
uniform int circleCount;
uniform vec2 screenSize;
uniform float currentStep;

void main()
{
    vec4 color = texture2D(gm_BaseTexture, v_vTexcoord);
    color.a = 0.0;
    
    gl_FragColor = color;
}
