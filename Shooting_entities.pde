class Camera{
  Entity target;
  boolean moveEvent=false;
  boolean resetMove=false;
  boolean moveTo=false;
  PVector movePos;
  PVector pos;
  PVector vel;
  float maxVel=18;
  float moveDist;
  int stopTime=60;
  int moveTime=0;
  
  Camera(){
  }
  
  void update(){
    if(moveEvent){
      if(!moveTo&&!resetMove){
        move();
      }else if(!resetMove){
        if(stopTime>0){
          stopTime--;
        }else{
          resetMove=true;
          moveTo=false;
        }
      }else if(resetMove){
        returnMove();
      }
    }else{
      vel=target.vel;
      pos.sub(vel);
      scroll=pos;
      translate(scroll.x,scroll.y);
    }
  }
  
  void setTarget(Entity e){
    target=e;
    pos=new PVector(width/2,height/2).sub(e.pos);
  }
  
  void moveTo(float wx,float wy){
    movePos=new PVector(-wx,-wy).add(width,height).sub(pos.x*2,pos.y*2);
    moveDist=movePos.dist(pos);
    moveEvent=true;
    moveTo=false;
  }
  
  void resetMove(){
    moveEvent=false;
    resetMove=false;
    moveTo=false;
    pos=new PVector(width/2,height/2).sub(target.pos);
    moveTime=0;
    stopTime=60;
  }
  
  void move(){
    if(moveTime<60){
      float scala=ESigmoid((float)moveTime/6f/5.91950);
      vel=new PVector((movePos.x-target.pos.x)*scala,(movePos.y-target.pos.y)*scala);
      pos.add(vel);
      moveTime++;
    }else{
      pos=new PVector(movePos.x,movePos.y);
      moveTo=true;
    }
  }
  
  void returnMove(){
    if(moveTime>0){
      float scala=ESigmoid((float)moveTime/6f/5.91950);
      vel=new PVector((movePos.x-target.pos.x)*scala,(movePos.y-target.pos.y)*scala);
      pos.sub(vel);
      moveTime--;
    }else{
      moveEvent=false;
      resetMove();
    }
  }
}

class Entity implements Egent{
  PVector prePos;
  PVector pos;
  PVector vel;
  PVector LeftUP;
  PVector LeftDown;
  PVector RightUP;
  PVector RightDown;
  float rotate=0;
  
  Entity(){
    
  }
  
  void display(){
    
  }
  
  void update(){
    
  }
}

class Myself extends Entity{
  ArrayList<Weapon>weapons=new ArrayList<Weapon>();
  Weapon selectedWeapon;
  Camera camera;
  Status HP;
  PImage HPgauge=loadImage(UIPath+"HPgauge.png");
  PImage heatgauge=loadImage(UIPath+"heatgauge.png");
  boolean autoShot=true;
  float protate=0;
  float diffuse=0;
  float rotateSpeed=10;
  float maxSpeed=7.5;
  float Speed=0;
  float accelSpeed=0.25;
  float bulletSpeed=15;
  float coolingTime=0;
  float maxCoolingTime=10;
  float size=20;
  int selectedIndex=0;
  int weaponChangeTime=0;
  
  Myself(){
    pos=new PVector(field.spownPoint.x,field.spownPoint.y);
    vel=new PVector(0,0);
    HP=new Status(100);
    weapons.add(new EnergyBullet(this));
    weapons.add(new DiffuseBullet(this));
    weapons.add(new PulseBullet(this));
    weapons.add(new LASER(this));
    HPgauge.resize(200,20);
    resetWeapon();
    camera=new Camera();
    camera.setTarget(this);
  }
  
  void display(){
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-rotate);
    strokeWeight(1);
    noFill();
    stroke(0,255,0);
    ellipse(0,0,size,size);
    strokeWeight(3);
    arc(0,0,size*1.5,size*1.5,radians(-5)-PI/2-diffuse/2,radians(5)-PI/2+diffuse/2);
    if(selectedWeapon.Attribute==Weapon.LASER){
      
    }
    popMatrix();
    if(!camera.moveEvent){
      drawUI();
    }
  }
  
  void drawUI(){
    pushMatrix();
    translate(pos.x-width/2,pos.y-height/2);
    rectMode(CORNER);
    fill(255);
    noStroke();
    image(HPgauge,width-220,10);
    rect(width-217.5,12.5,195*HP.getPercentage(),15);
    fill(255,30,30);
    image(heatgauge,width-170,35);
    rect(width-167.5,37.5,145*selectedWeapon.heat.getPercentage(),7);
    fill(250,max(0,255-weaponChangeTime));
    textSize(13);
    textAlign(RIGHT);
    text(selectedWeapon.getName(),width-180,46.5);
    fill(250);
    String item=selectedWeapon.itemNumber<=-1?"∞":str(selectedWeapon.itemNumber);
    String loaded=selectedWeapon.loadedNumber<=-1?"∞":str(selectedWeapon.loadedNumber);
    textSize(17.5);
    text(loaded+"/"+item,width-30,65);
    popMatrix();
  }
  
  void update(){
    if(!camera.moveEvent){
      Rotate();
      move();
      shot();
      keyEvent();
      for(Weapon w:weapons){
        w.coolDown();
      }
    }
    Wall();
    camera.update();
    weaponChangeTime+=4;
    weaponChangeTime=constrain(weaponChangeTime,0,255);
    prePos=new PVector(pos.x,pos.y);
  }
  
  @Deprecated
  void setpos(PVector pos){
    vel=new PVector(pos.x,pos.y).sub(this.pos);
    this.pos=pos;
  }
  
  @Deprecated
  void setpos(float x,float y){
    vel=new PVector(x,y).sub(this.pos);
    pos=new PVector(x,y);
  }
  
  void addWeapon(Weapon w){
    weapons.add(w);
  }
  
  void changeWeapon(){
    selectedIndex++;
    if(selectedIndex>=weapons.size()){
      selectedIndex=0;
    }
    selectedWeapon=weapons.get(selectedIndex);
    setParameta();
  }
  
  void resetWeapon(){
    selectedIndex=0;
    selectedWeapon=weapons.get(selectedIndex);
    setParameta();
  }
  
  void setParameta(){
    diffuse=selectedWeapon.diffuse;
    maxCoolingTime=selectedWeapon.coolTime;
    autoShot=selectedWeapon.autoShot;
    weaponChangeTime=0;
  }
  
  void Rotate(){
    float rad=atan2(pos.x-localMouse.x,pos.y-localMouse.y);
    float nRad=0<rotate?rad+TWO_PI:rad-TWO_PI;
    rad=abs(rotate-rad)<abs(rotate-nRad)?rad:nRad;
    rad=sign(rad-rotate)*constrain(abs(rad-rotate),0,radians(rotateSpeed)*vectorMagnification);
    protate=rotate;
    rotate+=rad;
    rotate=rotate%TWO_PI;
  }
  
  void move(){
    rotate(rotate);
    if(keyPressed&&(nowPressedKey.equals("w")||nowPressedKey.equals("s"))){
      switch(nowPressedKey){
        case "w":addVel(accelSpeed,false);break;
        case "s":subVel(accelSpeed,false);break;
      }
    }else{
      Speed=Speed>0?Speed-min(Speed,accelSpeed*2*vectorMagnification):Speed-max(Speed,-accelSpeed*2*vectorMagnification);
    }
    vel=new PVector(0,0);
    vel.y=-Speed;
    vel=unProject(vel.x,vel.y);
    pos.add(vel.mult(vectorMagnification));
    LeftUP=new PVector(pos.x-size,pos.y+size);
    LeftDown=new PVector(pos.x-size,pos.y-size);
    RightUP=new PVector(pos.x+size,pos.y+size);
    RightDown=new PVector(pos.x+size,pos.y-size);
  }
  
  private void addVel(float accel,boolean force){
    if(!force){
      Speed+=accel*vectorMagnification;
      Speed=min(maxSpeed,Speed);
    }else{
      Speed+=accel*vectorMagnification;
    }
  }
  
  private void subVel(float accel,boolean force){
    if(!force){
      Speed-=accel*vectorMagnification;
      Speed=max(-maxSpeed,Speed);
    }else{
      Speed-=accel*vectorMagnification;
    }
  }
  
  void shot(){
    if(mousePressed&&autoShot&&!selectedWeapon.heat.overHeat
       &&!selectedWeapon.empty){
      selectedWeapon.heatUP();
      if(selectedWeapon.Attribute==Weapon.LASER){
        
      }
    }else if(mousePress&&!autoShot&&coolingTime>maxCoolingTime
             &&!selectedWeapon.heat.overHeat&&!selectedWeapon.empty){
      selectedWeapon.absHeatUP();
    }
    if(coolingTime>maxCoolingTime&&((mousePressed&&autoShot)||(mousePress&&!autoShot))
      &&!selectedWeapon.heat.overHeat&&!selectedWeapon.empty){
      if(selectedWeapon.Attribute==Weapon.ENERGY|selectedWeapon.Attribute==Weapon.PHYSICS){
        selectedWeapon.shot();
        coolingTime=0;
      }else if(selectedWeapon.Attribute==Weapon.LASER){
        
      }
    }else if(selectedWeapon.empty){
      selectedWeapon.reload();
    }
    coolingTime+=floor(vectorMagnification);
  }
  
  void keyEvent(){
    if(keyPress&&ModifierKey==TAB){
      changeWeapon();
    }
  }
  
  boolean hit(PVector pos){
    if(this.pos.dist(pos)<=size){
      return true;
    }else{
      return false;
    }
  }
  
  void Wall(){
    PVector tilePos=new PVector(floor(pos.x/TileSize),floor(pos.y/TileSize));
    PVector offset=new PVector(TileSize*(tilePos.x-1),TileSize*(tilePos.y-1));
    int[][] Map=field.getAround(tilePos);
    for(int i=0;i<Map.length;i++){
      for(int j=0;j<Map[i].length;j++){
        PVector rectPos=new PVector(offset.x+TileSize*j,offset.y+TileSize*i);
        if(field.getAttributes().get(Map[i][j]).equals("Wall")){
          Collision(rectPos,pos);
        }
      }
    }
  }
  
  void Collision(PVector rect,PVector pos){
    if(rect.x<pos.x&&rect.x+TileSize>pos.x
       &&rect.y-size/2<pos.y&&rect.y+TileSize+size/2>pos.y){
      if(rect.y+TileSize/2<pos.y){
        pos.y=rect.y+TileSize+size/2;
      }else{
        pos.y=rect.y-size/2;
      }
      vel=new PVector(pos.x-prePos.x,pos.y-prePos.y);
      return;
    }else if(rect.x-size/2<pos.x&&rect.x+TileSize+size/2>pos.x
       &&rect.y<pos.y&&rect.y+TileSize>pos.y){
      if(rect.x+TileSize/2<pos.x){
        pos.x=rect.x+TileSize+size/2;
      }else{
        pos.x=rect.x-size/2;
      }
      vel=new PVector(pos.x-prePos.x,pos.y-prePos.y);
      return;
    }else if(qDist(rect,pos,size/2)){
      float r=atan2(pos.x-rect.x,pos.y-rect.y);
      int x=field.getTile(new PVector(pos.x-TileSize,pos.y));
      int y=field.getTile(new PVector(pos.x,pos.y-TileSize));
      pos.x=field.getAttributes().get(x).equals("Wall")?
            rect.x-size/2:rect.x+cos(r)*size/2;
      pos.y=field.getAttributes().get(y).equals("Wall")?
            rect.y+size/2:rect.y+sin(r)*size/2;
      vel=new PVector(pos.x-prePos.x,pos.y-prePos.y);
      println("LeftUp");
      return;
    }else if(qDist(new PVector(rect.x,rect.y+TileSize),pos,size/2)){
      float r=atan2(pos.x-rect.x,pos.y-rect.y-TileSize);
      pos.x=rect.x+cos(r)*size/2;
      pos.y=rect.y+TileSize+sin(r)*size/2;
      vel=new PVector(pos.x-prePos.x,pos.y-prePos.y);
      println("LeftDown");
      return;
    }else if(qDist(new PVector(rect.x+TileSize,rect.y),pos,size/2)){
      float r=atan2(pos.x-rect.x-TileSize,pos.y-rect.y);
      int x=field.getTile(new PVector(pos.x+TileSize,pos.y));
      int y=field.getTile(new PVector(pos.x,pos.y-TileSize));
      pos.x=field.getAttributes().get(x).equals("Wall")?
            rect.x+TileSize+size/2:rect.x+TileSize+cos(r)*size/2;
      pos.y=field.getAttributes().get(y).equals("Wall")?
            rect.y+size/2:rect.y+sin(r)*size/2;
      vel=new PVector(pos.x-prePos.x,pos.y-prePos.y);
      println("RightUp");
      return;
    }else if(qDist(new PVector(rect.x+TileSize,rect.y+TileSize),pos,size/2)){
      float r=atan2(pos.x-rect.x-TileSize,pos.y-rect.y-TileSize);
      pos.x=rect.x+TileSize+cos(r)*size/2;
      pos.y=rect.y+TileSize+sin(r)*size/2;
      vel=new PVector(pos.x-prePos.x,pos.y-prePos.y);
      println("RightDown");
      return;
    }
  }
}

class Enemy extends Entity{
  Weapon useWeapon=null;
  Color c=new Color(0,0,255);
  float size=20;
  protected double maxHP=10d;
  protected double HP=10d;
  
  Enemy(){
    
  }
  
  void display(){
    
  }
  
  void update(){
    
  }
  
  void setSize(float s){
    size=s;
  }
  
  void printHP(){
    blendMode(BLEND);
    pushMatrix();
    translate(pos.x,pos.y);
    rectMode(CENTER);
    noStroke();
    fill(255,0,0);
    rect(0,size*1.25,size*1.4,size*0.2);
    rectMode(CORNER);
    noStroke();
    fill(0,255,0);
    rect(-size*0.7,size*1.15,size*1.4*(float)(HP/maxHP),size*0.2);
    popMatrix();
  }
  
  void setHP(double h){
    maxHP=h;
    HP=h;
  }
  
  void updateVertex(){
    float s=size/2*1.41421356237;
    float r=-rotate+PI/4;
    LeftUP=new PVector(pos.x-cos(r)*s,pos.y+sin(r)*s);
    LeftDown=new PVector(pos.x-cos(r)*s,pos.y-sin(r)*s);
    RightUP=new PVector(pos.x+cos(r)*s,pos.y+sin(r)*s);
    RightDown=new PVector(pos.x+cos(r)*s,pos.y-sin(r)*s);
  }
  
  void Collision(){
    ArrayList<Bullet>nextBullets=new ArrayList<Bullet>();
    COLLISION:for(Bullet b:Bullets){
      int sign=0;;
      for(int i=0;i<4;i++){
        PVector v=new PVector();
        switch(i){
          case 0:v=new PVector(LeftUP.x-b.pos.x,LeftUP.y-b.pos.y);
          case 1:v=new PVector(LeftDown.x-b.pos.x,LeftDown.y-b.pos.y);
          case 2:v=new PVector(RightUP.x-b.pos.x,RightUP.y-b.pos.y);
          case 3:v=new PVector(RightDown.x-b.pos.x,RightDown.y-b.pos.y);
        }
        float cross=cross(b.vel,v);println(LeftUP,LeftDown,RightUP,RightDown,cross);
        if(i==0){
          sign=sign(cross);
        }else{
          if(sign!=sign(cross)){
            b.isDead=true;
            continue COLLISION;
          }
        }
      }
      if(!b.isDead)nextBullets.add(b);
    }
    Bullets=nextBullets;
  }
}

class Bullet extends Entity{
  Weapon usedWeapon=null;
  PVector bVel;
  boolean isMine=false;
  boolean isDead=false;
  boolean bounse=false;
  Color bulletColor;
  float rotate=0;
  float speed=7;
  int age=0;
  int maxAge=0;
  
  Bullet(Myself m){
    rotate=-m.rotate-PI/2+random(-m.diffuse/2,m.diffuse/2);
    speed=m.bulletSpeed;
    bulletColor=m.selectedWeapon.bulletColor;
    pos=new PVector(m.pos.x,m.pos.y);
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
    maxAge=m.selectedWeapon.bulletMaxAge;
    isMine=true;
  }
  
  Bullet(Entity e,Weapon w){
    usedWeapon=w;
    if(w.loadedNumber>1){
      w.loadedNumber--;
    }else if(w.loadedNumber>0){
      w.loadedNumber--;
      w.reload();
    }
    rotate=-e.rotate-PI/2+random(-w.diffuse/2,w.diffuse/2);
    speed=w.speed;
    bulletColor=w.bulletColor;
    pos=new PVector(w.parent.pos.x,w.parent.pos.y);
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
    maxAge=w.bulletMaxAge;
    isMine=e.getClass().getSimpleName().equals("Myself");
  }
  
  void display(){
    strokeWeight(1);
    if(isMine){
      stroke(bulletColor.getRed(),bulletColor.getGreen(),bulletColor.getBlue());
    }else{
      stroke(255,0,0);
    }
    line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
  }
  
  void update(){
    Wall();
    bVel=new PVector(vel.x,vel.y);
    pos.add(vel.mult(vectorMagnification));
    vel=new PVector(bVel.x,bVel.y);
    prePos=new PVector(pos.x,pos.y);
    if(age>maxAge)isDead=true;
    age++;
  }
  
  void setBounse(boolean b){
    bounse=b;
  }
  
  void Wall(){
    PVector tilePos=new PVector(floor(pos.x/TileSize),floor(pos.y/TileSize));
    PVector offset=new PVector(TileSize*(tilePos.x-1),TileSize*(tilePos.y-1));
    int[][] Map=field.getAround(tilePos);
    for(int i=0;i<Map.length;i++){
      for(int j=0;j<Map[i].length;j++){
        PVector rectPos=new PVector(offset.x+TileSize*j,offset.y+TileSize*i);
        if(field.getAttributes().get(Map[i][j]).equals("Wall")){
          Collision(rectPos,pos);
        }
      }
    }
  }
  
  void Collision(PVector rect,PVector pos){
    //COLLISION:{
    //  int loop=0;
    //  boolean ray=false;
    //  PVector start=new PVector(pos.x/TileSize,pos.y/TileSize);
    //  PVector end=new PVector(start.x+vel.x/TileSize,start.y+vel.y/TileSize);
    //  float Xdist=vel.x/80;
    //  float Ydist=vel.y/80;
    //  float nowX=0;
    //  float nowY=0;
    //  if(field.toAttribute(field.getTileFromIndex(start)).equals("Wall")){
    //    isDead=true;
    //    Particles.add(new Particle(this,3));
    //    break COLLISION;
    //  }else{
    //    if(abs(Xdist)>abs(Ydist)){
    //      start.x=sign(vel.x)>0?floor(start.x):ceil(start.x);
    //      nowX=(sign(vel.x)>0?1.0-float(nf(start.x,1,7)):1.0+float(nf(start.x,1,7)))/Xdist;
    //    }else{
    //      start.y=sign(vel.y)>0?floor(start.y):ceil(start.y);
    //    }
    //  }
    //  while(!ray){
    //    if(abs(Xdist)>abs(Ydist)){
    //      if(abs(nowX)<abs(nowY)){
    //        nowX+=1/Xdist;
    //        start.x+=sign(Xdist);
    //        nowX=round(nowX);
    //      }else{
    //        nowY+=1/Ydist;
    //        start.y+=sign(Ydist);
    //        nowY=round(nowY);
    //      }
    //      if(field.toAttribute(field.getTileFromIndex(round(start.x),round(start.y))).equals("Wall")){
    //        isDead=true;
    //        Particles.add(new Particle(this,3));
    //        break COLLISION;
    //      }
    //    }else{
          
    //    }
    //    loop++;
    //  }
    //}
    if(rect.x<=pos.x&&rect.x+field.tileSize>=pos.x
       &&rect.y-vel.y<=pos.y&&rect.y+field.tileSize-vel.y>=pos.y){
      if(bounse){
        if(rect.y+field.tileSize/2<pos.y){
          pos.y=rect.y+field.tileSize-vel.y;
        }else{
          pos.y=rect.y-vel.y;
        }
        invY();
      }else{
        isDead=true;
        Particles.add(new Particle(this,3));
      }
      return;
    }else if(rect.x-vel.x<=pos.x&&rect.x+field.tileSize-vel.x>=pos.x
       &&rect.y<=pos.y&&rect.y+field.tileSize>=pos.y){
      if(bounse){
        if(rect.x+field.tileSize/2<pos.x){
          pos.x=rect.x+field.tileSize-vel.x;
        }else{
          pos.x=rect.x-vel.x;
        }
        invX();
      }else{
        isDead=true;
        Particles.add(new Particle(this,3));
      }
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

class light{
  PVector pos;
  float bright;
  float rad;
  
  light(Entity  e){
    pos=e.pos;
  }
  
  light(PVector pos){
    this.pos=pos;
  }
  
  void setBrightness(float f){
    bright=f;
  }
  
  void setSize(float f){
    rad=f;
  }
  
  void display(){
    blendMode(ADD);
  }
}

interface Egent{
  void display();
  
  void update();
}
