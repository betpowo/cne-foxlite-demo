#define SKY_PANORAMA_FRAG
#include "foxlite/inc/foxlite.glsl"
#include "foxlite/inc/material.glsl"
#include "foxlite/inc/sky.glsl"      // For worldDirection and sky funcs

uniform float iTime;

void main() {
	vec2 coord = coordFromSphere(normalize(worldDirection)) + skyOffset;
	coord.x += sin(iTime+coord.y*20.)*.075 * max(1.0-coord.y*1.75, 0.0);
	gl_FragColor = texture2D(skyTexture, coord);
}