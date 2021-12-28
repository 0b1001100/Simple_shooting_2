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
    float rad=atan2(localMouse.x-pos.x,localMouse.y-pos.y)-PI*0.5;
    float nRad=0<rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(rotate-rad)<abs(rotate-nRad)?rad:nRad;
    rad=sign(rad-rotate)*constrain(abs(rad-rotate),0,PI*mag*vectorMagnification);
    rotate+=rad;
    rotate%=TWO_PI;
    vel=new PVector(cos(-rotate)*speed,sin(-rotate)*speed);
    super.update();
  }
}
