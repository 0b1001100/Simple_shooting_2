class Turret extends Enemy{
  
  Turret(){
    
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
  }
  
  void update(){
    
  }
}
