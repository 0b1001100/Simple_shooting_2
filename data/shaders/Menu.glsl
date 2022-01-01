uniform float time;
uniform vec2 xy;
uniform vec2 resolution;
uniform vec4 menuColor;
uniform sampler2D tex;

vec4 toScreen(float standard,vec4 col){
  return mix(vec4(0.902),col,floor(standard));
}

void main(void){
  vec2 pos=vec2(gl_FragCoord);
  vec2 normPos=pos/resolution.xy;
  vec4 color=vec4(texture2D(tex,vec2(normPos.x,1.0-normPos.y)));
  vec2 dist=vec2(floor(pos/(resolution/xy)));
  float scale=min(max(time-(dist.x+(xy.y-dist.y)),0.0),1.0);
  gl_FragColor=vec4(toScreen(scale,color));
}