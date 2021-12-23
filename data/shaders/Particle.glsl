#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 resolution;
uniform vec4 prects[100];
uniform vec4 color[100];

bool inRect(vec2 position, vec2 offset, float size) {
  vec2 q = (position - offset) / size;
  if (abs(q.x) < 1.0 && abs(q.y) < 1.0) {
    return true;
  }
  return false;
}

void main(void){
  vec4 OutPut=vec4(0.0, 0.0, 0.0, 1.0);
  vec2 position = (gl_FragCoord.xy * 2.0 - resolution) / min(resolution.x, resolution.y);
  if (inRect(position, vec2( 0.5, -0.5), 0.25)) {
    OutPut= vec4(0.0,0.0,255.0,1.0);
  }
  gl_FragColor = OutPut;
}