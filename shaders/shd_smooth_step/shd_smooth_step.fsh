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
        float X = clamp((dist - circleRadius[i]) / FALLOFF_WIDTH, 0., 1.);
        float alpha = 3.0 * pow(X, 2.0) + 2.0 * pow(X, 3.0);
        
        color.a = min(alpha, min(color.a, 0.9));
    }
    
    gl_FragColor = color;
}
