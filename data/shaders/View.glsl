uniform vec2 resolution;
uniform vec2 StartPos;
uniform vec2 offset;
uniform sampler2D Map;
uniform sampler2D Tiles;

float cross(vec2 a, vec2 b) {
  return a.x * b.y - a.y * b.x;
}

bool LineCollision(vec2 s1,vec2 v1,vec2 s2,vec2 v2){
  vec2 v=s2-s1;
  float crs_v1_v2=cross(v1,v2);
  if(crs_v1_v2==0.0){
    return false;
  }
  float t=cross(v,v1);
  if (t+0.00001<0.0||1.0<t-0.00001) {
    return false;
  }
  return true;
}

void main(void){
  vec2 pos=vec2(gl_FragCoord)/resolution;
  vec2 TilePos=(vec2(gl_FragCoord)-offset)/resolution;
  vec4 color=vec4(texture2D(Tiles,abs(vec2(0.0,1.0)-TilePos)))*vec4(0.15, 0.15, 0.15, 0.0);
  gl_FragColor=vec4(texture2D(Map,pos))-color;
}