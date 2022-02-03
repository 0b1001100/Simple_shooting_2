class Turret extends Enemy{
  
  Turret(){
    init();
  }
  
  Turret(PVector pos){
    init();
    this.pos=pos;
  }
  
  private void init(){
    setHP(100);
    useWeapon=new EnergyBullet(this);
  }
  
  void display(){
    super.display();
  }
  
  void update(){
    updateVertex();
    BulletCollision();
    if(random(100)>185){
      eneBullets.add(new HomingBullet(this,this.useWeapon,player));
    }
    Collision();
  }
  
  void Hit(){
    super.Hit();
  }
}

class Normal extends Enemy{
  
  Normal(){
    init();
  }
  
  Normal(PVector pos){
    this.pos=pos;
    init();
  }
  
  private void init(){
    setHP(100);
    rotate=PI;
    useWeapon=new EnergyBullet(this);
  }
  
  void display(){
    super.display();
  }
  
  void update(){
    updateVertex();
    BulletCollision();
    if(random(100)>85){
      eneBullets.add(new Bullet(this,this.useWeapon));
    }
    move();
  }
  
  void move(){
    //壁を避けて移動
    Collision();
  }
}
