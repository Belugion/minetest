uniform mat4 mWorldViewProj;
uniform mat4 mInvWorld;
uniform mat4 mTransWorld;
uniform mat4 mWorld;

uniform float dayNightRatio;
uniform float animationTimer;

uniform vec3 eyePosition;

varying vec3 vPosition;
varying vec3 worldPosition;

varying vec3 eyeVec;
varying vec3 lightVec;

const float BS = 10.0;

#ifdef ENABLE_WAVING_PLANTS
float smoothCurve( float x ) {
  return x * x *( 3.0 - 2.0 * x );
}
float triangleWave( float x ) {
  return abs( fract( x + 0.5 ) * 2.0 - 1.0 );
}
float smoothTriangleWave( float x ) {
  return smoothCurve( triangleWave( x ) ) * 2.0 - 1.0;
}
#endif

void main(void)
{
	gl_TexCoord[0] = gl_MultiTexCoord0;

#ifdef ENABLE_WAVING_PLANTS
	vec4 pos = gl_Vertex;
	vec4 pos2 = mWorld * gl_Vertex;
	if (gl_TexCoord[0].y < 0.05) {
		pos.x += (smoothTriangleWave(animationTimer * 20.0 + pos2.x * 0.1 + pos2.z * 0.1) * 2.0 - 1.0) * 0.8;
		pos.y -= (smoothTriangleWave(animationTimer * 10.0 + pos2.x * -0.5 + pos2.z * -0.5) * 2.0 - 1.0) * 0.4;
	}
	gl_Position = mWorldViewProj * pos;
#else
	gl_Position = mWorldViewProj * gl_Vertex;
#endif

	vPosition = gl_Position.xyz;
	worldPosition = (mWorld * gl_Vertex).xyz;
	vec3 sunPosition = vec3 (0.0, eyePosition.y * BS + 900.0, 0.0);

	lightVec = sunPosition - worldPosition;
	eyeVec = (gl_ModelViewMatrix * gl_Vertex).xyz;
	
	vec4 color;
	//color = vec4(1.0, 1.0, 1.0, 1.0);

	float day = gl_Color.r;
	float night = gl_Color.g;
	float light_source = gl_Color.b;

	/*color.r = mix(night, day, dayNightRatio);
	color.g = color.r;
	color.b = color.r;*/

	float rg = mix(night, day, dayNightRatio);
	rg += light_source * 2.5; // Make light sources brighter
	float b = rg;

	// Moonlight is blue
	b += (day - night) / 13.0;
	rg -= (day - night) / 13.0;

	// Emphase blue a bit in darker places
	// See C++ implementation in mapblock_mesh.cpp finalColorBlend()
	b += max(0.0, (1.0 - abs(b - 0.13)/0.17) * 0.025);

	// Artificial light is yellow-ish
	// See C++ implementation in mapblock_mesh.cpp finalColorBlend()
	rg += max(0.0, (1.0 - abs(rg - 0.85)/0.15) * 0.065);

	color.r = clamp(rg,0.0,1.0);
	color.g = clamp(rg,0.0,1.0);
	color.b = clamp(b,0.0,1.0);

	// Make sides and bottom darker than the top
	color = color * color; // SRGB -> Linear
	if(gl_Normal.y <= 0.5)
		color *= 0.6;
	color = sqrt(color); // Linear -> SRGB
	color.a = gl_Color.a;

	gl_FrontColor = gl_BackColor = color;
}
