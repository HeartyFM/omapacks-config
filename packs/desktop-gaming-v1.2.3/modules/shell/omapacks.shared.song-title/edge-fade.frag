#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float fadeFraction;
    float fadeStrength;
};
layout(binding = 1) uniform sampler2D source;
void main() {
    float edge = max(fadeFraction, 0.0001);
    float leftFade = smoothstep(0.0, edge, qt_TexCoord0.x);
    float rightFade = smoothstep(0.0, edge, 1.0 - qt_TexCoord0.x);
    float alpha = mix(1.0, leftFade * rightFade, fadeStrength);
    fragColor = texture(source, qt_TexCoord0) * qt_Opacity * alpha;
}
