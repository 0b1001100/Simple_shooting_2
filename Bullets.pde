class HomingBullet extends Bullet{
  Entity target=null;
  float mag=0.0005;
  
  HomingBullet(Myself m,Entity e){
    super(m);
    target=e;
  }
  
  HomingBullet(Entity e,Weapon w,Entity t){
    super(e,w);
    target=t;
  }
  
  @Override
  void display(){
    super.display();
  }
  
  @Override
  void update(){
    super.update();
    float rad=atan2(target.pos.x-pos.x,target.pos.y-pos.y)-PI*0.5;
    float nRad=0<rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(rotate-rad)<abs(rotate-nRad)?rad:nRad;
    rad=sign(rad-rotate)*constrain(abs(rad-rotate),0,PI*mag*vectorMagnification);
    rotate+=rad;
    rotate%=TWO_PI;
    lineVel.get(0).set(new PVector(cos(-rotate)*speed,sin(-rotate)*speed));
  }
}

class CollisionBullet extends Bullet{
  Entity parent=null;
  
  CollisionBullet(Myself m){
    super(m);
    parent=m;
  }
  
  CollisionBullet(Entity e,Weapon w){
    super(e,w);
    parent=e;
  }
  
  @Override
  void display(){
    super.display();
  }
  
  @Override
  void update(){
    for(Bullet b:Bullets){
      if(b instanceof CollisionBullet){
        if(((CollisionBullet)b).parent.equals(parent)){
          continue;
        }
      }
      if(SegmentCollision(pos,vel.copy().mult(vectorMagnification),
                          b.pos,b.vel.copy().mult(vectorMagnification))){
        b.isDead=true;
        isDead=true;
        Particles.add(new Particle(b,1));
        Particles.add(new Particle(this,1));
      }
    }
    for(Bullet b:eneBullets){
      if(b instanceof CollisionBullet){
        if(((CollisionBullet)b).parent.equals(parent)){
          continue;
        }
      }
      if(SegmentCollision(pos,vel.copy().mult(vectorMagnification),
                          b.pos,b.vel.copy().mult(vectorMagnification))){
        b.isDead=true;
        isDead=true;
        Particles.add(new Particle(b,1));
        Particles.add(new Particle(this,1));
      }
    }
    if(!isDead)super.update();
  }
}
