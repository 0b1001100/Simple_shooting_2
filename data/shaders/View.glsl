uniform vec2 size;
uniform vec2 StartPos;
uniform sampler2D Mask;
uniform sampler2D Map;

void main(void){
    vec2 EndPos=vec2(gl_FragCoord);
    vec2 RoundPos=round(StartPos);
    vec2 pos=vec2(RoundPos);
    float nx=0.0;
    float ny=0.0;
    float X=1.0/(EndPos.x/RoundPos.x);
    float Y=1.0/(RoundPos.y/EndPos.y);
    float Xsign=sign(X);
    float Ysign=sign(Y);
    for(int i=0;i<1500;i++){
        if(pos.x*Xsign<EndPos.x*Xsign&&nx*Xsign<=ny*Ysign){
            pos.x+=Xsign;
            nx+=X;
        }
        if(pos.y*Ysign<EndPos.y*Ysign&&ny*Ysign<nx*Xsign){
            pos.y+=Ysign;
            ny+=Y;
        }
        if(texture2D(Map,pos/size)==vec4(0.0)){
            gl_FragColor=vec4(0.1255, 0.1255, 0.1255, 0.568);
            break;
        }
        if(pos.x*Xsign>EndPos.x*Xsign&&pos.y*Ysign>EndPos.y*Ysign){
            gl_FragColor=vec4(0,0,0,0);
            break;
        }
    }
}