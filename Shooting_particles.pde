class Particle{
  ArrayList<particleFlagment>particles=new ArrayList<particleFlagment>();
  boolean isDead=false;
  Color pColor;
  float min=1;
  float max=5;
  int time=0;
  
  Particle(Bullet b,int num){
    for(int i=0;i<num;i++){
      float scala=random(0,0.5);
      float rad=random(0,360);
      PVector vec=new PVector(cos(radians(rad))*scala,sin(radians(rad))*scala);
      Color c=new Color(b.bulletColor.getRed(),b.bulletColor.getGreen(),b.bulletColor.getBlue(),(int)random(16,255));
      particles.add(new particleFlagment(b.pos,vec,c,random(min,max)));
    }
  }
  
  Particle(Myself m,int num){
    for(int i=0;i<num;i++){
      float scala=random(0,0.5);
      float rad=random(0,360);
      PVector vec=new PVector(cos(radians(rad))*scala,sin(radians(rad))*scala);
      Color c=new Color(0,255,0,(int)random(16,255));
      particles.add(new particleFlagment(m.pos,vec,c,random(min,max)));
    }
  }
  
  Particle setSize(float min,float max){
    this.min=min;
    this.max=max;
    for(particleFlagment p:particles){
      p.setSize(random(min,max));
    }
    return this;
  }
  
  void display(){
    for(particleFlagment p:particles){
      p.display();
    }
  }
  
  void update(){
    ArrayList<particleFlagment>nextParticles=new ArrayList<particleFlagment>();
    for(particleFlagment p:particles){
      p.setAlpha(p.pColor.getAlpha()-2);
      p.update();
      if(!p.isDead)nextParticles.add(p);
    }
    particles=nextParticles;
    time+=2;
    if(time>255){
      isDead=true;
    }
  }
}

class particleFlagment{
  PVector pos;
  PVector vel;
  boolean isDead=false;
  Color pColor;
  float size;
  
  particleFlagment(PVector pos,PVector vel,Color c,float size){
    this.pos=new PVector(pos.x,pos.y);
    this.vel=new PVector(vel.x,vel.y);
    this.pColor=new Color(c.getRed(),c.getGreen(),c.getBlue(),c.getAlpha());
    this.size=size;
  }
  
  particleFlagment setSize(float f){
    size=f;
    return this;
  }
  
  particleFlagment setColor(Color c){
    this.pColor=new Color(c.getRed(),c.getGreen(),c.getBlue(),c.getAlpha());
    return this;
  }
  
  particleFlagment setAlpha(int a){
    pColor=new Color(pColor.getRed(),pColor.getGreen(),pColor.getBlue(),max(0,a));
    return this;
  }
  
  void display(){
    if(pColor.getAlpha()<=0){isDead=true;return;}
    noStroke();
    fill(pColor.getRed(),pColor.getGreen(),pColor.getBlue(),pColor.getAlpha());
    rectMode(CENTER);
    rect(pos.x,pos.y,size,size);
  }
  
  void update(){
    pos.add(vel);
  }
}
