uniform sampler2D tex;
uniform vec2 resolution;

void main(void){
  vec2 pos=vec2(gl_FragCoord.x/resolution.x,gl_FragCoord.y/resolution.y);
  vec4 color=vec4(texture2D(tex,vec2(pos.x,1.0-pos.y)));
  gl_FragColor = vec4(1.0 - color.x, 1.0 - color.y, 1.0 - color.z, 1.0);
}