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
    Collision();
  }
  
  void Hit(){
    HP-=ShotWeapon.power;
  }
}
