class Particle{
  ArrayList<particleFragment>particles=new ArrayList<particleFragment>();
  boolean isDead=false;
  Color pColor;
  float min=1;
  float max=5;
  float time=0;
  
  Particle(Bullet b,int num){
    for(int i=0;i<num;i++){
      float scala=random(0,0.5);
      float rad=random(0,360);
      PVector vec=new PVector(cos(radians(rad))*scala,sin(radians(rad))*scala);
      Color c=new Color(b.bulletColor.getRed(),b.bulletColor.getGreen(),b.bulletColor.getBlue(),(int)random(16,255));
      particles.add(new LineFragment(b.pos,vec,c,random(min,max)));
    }
  }
  
  Particle(Entity e,int num){
    for(int i=0;i<num;i++){
      float scala=random(0,0.5);
      float rad=random(0,360);
      PVector vec=new PVector(cos(radians(rad))*scala,sin(radians(rad))*scala);
      Color c=new Color(e.c.getRed(),e.c.getGreen(),e.c.getBlue(),(int)random(16,255));
      particles.add(new particleFragment(e.pos,vec,c,random(min,max)));
    }
  }
  
  Particle(Entity e,String s){
    particles.add(new StringFragment(e.pos,new PVector(0,-1),
                      e instanceof Myself?new Color(255,0,0):new Color(255,255,255),15,s));
  }
  
  Particle(Entity e,int num,float speed){
    for(int i=0;i<num;i++){
      float scala=random(0,speed);
      float rad=random(0,360);
      PVector vec=new PVector(cos(radians(rad))*scala,sin(radians(rad))*scala);
      Color c=new Color(e.c.getRed(),e.c.getGreen(),e.c.getBlue(),(int)random(16,255));
      particles.add(new particleFragment(e.pos,vec,c,random(min,max)));
    }
  }
  
  Particle setSize(float min,float max){
    this.min=min;
    this.max=max;
    for(particleFragment p:particles){
      p.setSize(random(min,max));
    }
    return this;
  }
  
  void display(){
    for(particleFragment p:particles){
      p.display();
    }
  }
  
  void update(){
    ArrayList<particleFragment>nextParticles=new ArrayList<particleFragment>();
    for(particleFragment p:particles){
      p.setAlpha(p.alpha-2*vectorMagnification);
      p.update();
      if(!p.isDead)nextParticles.add(p);
    }
    particles=nextParticles;
    time+=2*vectorMagnification;
    if(time>255){
      isDead=true;
    }
  }
}

class StringFragment extends particleFragment{
  String text="0";
  
  StringFragment(PVector pos,PVector vel,Color c,float size,String s){
    super(pos,vel,c,size);
    setText(s);
  }
  
  void setText(String s){
    text=s;
  }
  
  void display(){
    blendMode(BLEND);
    textAlign(CENTER);
    textSize(size+1);
    fill(128,128,128,pColor.getAlpha());
    text(text,pos.x,pos.y);
    textSize(size);
    fill(toColor(pColor));
    text(text,pos.x,pos.y);
  }
  
  void update(){
    super.update();
  }
}

class LineFragment extends particleFragment{
  
  LineFragment(PVector pos,PVector vel,Color c,float size){
    super(pos,vel,c,size);
  }
  
  void display(){
    if(!inScreen)return;
    if(alpha<=0){
      isDead=true;
      return;
    }
    stroke(pColor.getRed(),pColor.getGreen(),pColor.getBlue(),pColor.getAlpha());
    line(pos.x,pos.y,pos.x+vel.x*size*3,pos.y+vel.y*size*3);
  }
  
  void update(){
    super.update();
  }
}

class particleFragment{
  PVector pos;
  PVector vel;
  boolean inScreen=true;
  boolean isDead=false;
  Color pColor;
  float alpha;
  float size;
  
  particleFragment(PVector pos,PVector vel,Color c,float size){
    this.pos=new PVector(pos.x,pos.y);
    this.vel=new PVector(vel.x,vel.y);
    this.pColor=new Color(c.getRed(),c.getGreen(),c.getBlue(),c.getAlpha());
    alpha=c.getAlpha();
    this.size=size;
  }
  
  particleFragment setSize(float f){
    size=f;
    return this;
  }
  
  particleFragment setColor(Color c){
    this.pColor=new Color(c.getRed(),c.getGreen(),c.getBlue(),c.getAlpha());
    return this;
  }
  
  particleFragment setAlpha(float a){
    alpha=a;
    pColor=new Color(pColor.getRed(),pColor.getGreen(),pColor.getBlue(),round(max(0,alpha)));
    return this;
  }
  
  void display(){
    if(!inScreen)return;
    if(alpha<=0){
      isDead=true;
      return;
    }
    noStroke();
    fill(pColor.getRed(),pColor.getGreen(),pColor.getBlue(),pColor.getAlpha());
    rectMode(CENTER);
    rect(pos.x,pos.y,size,size);
  }
  
  void update(){
    pos.add(vel.copy().mult(vectorMagnification));
    if(-scroll.x<pos.x-size/2&pos.x+size/2<-scroll.x+width&
       -scroll.y<pos.y-size/2&pos.y+size/2<-scroll.y+height){
      inScreen=true;
    }else{
      inScreen=false;
    }
  }
}

class physicsParticleFragment extends particleFragment{
  PVector prePos;
  
  physicsParticleFragment(PVector pos,PVector vel,Color c,float size){
    super(pos,vel,c,size);
    prePos=pos.copy();
  }
  
  void update(){
    super.update();
    PVector tilePos=new PVector(floor(pos.x/TileSize),floor(pos.y/TileSize));
    PVector offset=new PVector(TileSize*(tilePos.x-1),TileSize*(tilePos.y-1));
    int[][] tiles=field.getAround(pos);
    for(int i=0;i<tiles.length;i++){
      for(int j=0;j<tiles[i].length;j++){
        PVector rectPos=new PVector(offset.x+TileSize*j,offset.y+TileSize*i);
        if(field.getAttributes().get(tiles[i][j]).equals("Wall")){
          Collision(rectPos,pos);
        }
      }
    }
    prePos=pos.copy();
  }
  
  void Collision(PVector rect,PVector pos){
    if(rect.x<=pos.x&&rect.x+TileSize>=pos.x
       &&rect.y-size/2<=pos.y&&rect.y+TileSize+size/2>=pos.y){
      if(rect.y+TileSize/2<pos.y){
        pos.y=rect.y+TileSize+size/2;
      }else{
        pos.y=rect.y-size/2;
      }
      vel=new PVector(pos.x-prePos.x,pos.y-prePos.y);
    }
    if(rect.x-size/2<=pos.x&&rect.x+TileSize+size/2>=pos.x
       &&rect.y<=pos.y&&rect.y+TileSize>=pos.y){
      if(rect.x+TileSize/2<pos.x){
        pos.x=rect.x+TileSize+size/2;
      }else{
        pos.x=rect.x-size/2;
      }
      vel=new PVector(pos.x-prePos.x,pos.y-prePos.y);
      return;
    }
  }
  
  private void invX(){
    vel=new PVector(-vel.x,vel.y);
  }
  
  private void invY(){
    vel=new PVector(vel.x,-vel.y);
  }
}
