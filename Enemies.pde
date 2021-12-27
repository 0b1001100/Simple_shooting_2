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
    rotate=PI;
    useWeapon=new EnergyBullet(this);
  }
  
  void display(){
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-rotate);
    rectMode(CENTER);
    strokeWeight(1);
    noFill();
    stroke(0,0,255);
    rect(0,0,size,size);
    popMatrix();
    printHP();
  }
  
  void update(){
    updateVertex();
    BulletCollision();
    if(random(100)>85){
      eneBullets.add(new Bullet(this,this.useWeapon));
    }
  }
  
  void Hit(){
    HP-=ShotWeapon.power;
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
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-rotate);
    rectMode(CENTER);
    strokeWeight(1);
    noFill();
    stroke(0,100,255);
    rect(0,0,size,size);
    popMatrix();
    printHP();
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
    
  }
}
