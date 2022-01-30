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
  float size=20;
  PVector prePos;
  PVector pos;
  PVector vel;
  PVector LeftUP;
  PVector LeftDown;
  PVector RightUP;
  PVector RightDown;
  Color c=new Color(0,255,0);
  float rotate=0;
  boolean isDead=false;
  
  Entity(){
    
  }
  
  void display(){
    
  }
  
  void update(){
    
  }
  
  void setColor(Color c){
    this.c=c;
  }
}

class Myself extends Entity{
  HashMap<String,StatusManage>effects=new HashMap<String,StatusManage>();
  ArrayList<Weapon>weapons=new ArrayList<Weapon>();
  ItemTable Items;
  ItemTable Materials;
  ItemTable Weapons;
  Weapon selectedWeapon;
  Weapon ShotWeapon;
  Shield selectedShield;
  Camera camera;
  Status HP;
  PImage HPgauge=loadImage(UIPath+"HPgauge.png");
  PImage heatgauge=loadImage(UIPath+"heatgauge.png");
  PShader damageNoise=loadShader(ShaderPath+"Noise.glsl");
  boolean autoShot=true;
  boolean hit=false;
  boolean shield=false;
  double damage=0;
  double absHP;
  float protate=0;
  float diffuse=0;
  float rotateSpeed=10;
  float maxSpeed=7.5;
  float Speed=0;
  float accelSpeed=0.25;
  float bulletSpeed=15;
  float coolingTime=0;
  float maxCoolingTime=10;
  int selectedIndex=0;
  int weaponChangeTime=0;
  
  Myself(){
    Items=new ItemTable();
    Materials=new ItemTable();
    Weapons=new ItemTable();
    Items.addStorage(new Item("回復薬(小)").setRecovoryPercent(0.25),10);
    Items.addStorage(new Item("回復薬(中)").setRecovoryPercent(0.45),3);
    Items.addStorage(new Item("回復薬(大)").setRecovoryPercent(0.75),1);
    Weapons.addStorage(new Item("クォークキャノン").setType(3),1);
    Weapons.addStorage(new Item("タウブラスター").setType(3),1);
    Weapons.addStorage(new Item("フォトンパルス").setType(3),1);
    pos=new PVector(field.spownPoint.x,field.spownPoint.y);
    vel=new PVector(0,0);
    HP=new Status(100);
    absHP=HP.getMax().doubleValue();
    weapons.add(new EnergyBullet(this));
    weapons.add(new DiffuseBullet(this));
    weapons.add(new PulseBullet(this));
    weapons.add(new ILMG(this));
    selectedShield=new Shield(this);
    HPgauge.resize(200,20);
    resetWeapon();
    camera=new Camera();
    camera.setTarget(this);
    //effects.put("test",new StatusManage(this).setHP(32768));
  }
  
  void display(){
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(-rotate);
    strokeWeight(1);
    noFill();
    stroke(c.getRed(),c.getGreen(),c.getBlue());
    ellipse(0,0,size,size);
    strokeWeight(3);
    arc(0,0,size*1.5,size*1.5,
        radians(-5)-PI/2-selectedWeapon.diffuse/2,radians(5)-PI/2+selectedWeapon.diffuse/2);
    popMatrix();
    if(!camera.moveEvent){
      drawUI();
    }
    if(shield){
      selectedShield.display();
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
      BulletCollision();
      keyEvent();
      HashMap<String,StatusManage>nextEffects=new HashMap<String,StatusManage>();
      for(String s:effects.keySet()){
        effects.get(s).update();
        if(!effects.get(s).isEnd)nextEffects.put(s,effects.get(s));
      }
      effects=nextEffects;
      for(Weapon w:weapons){
        w.coolDown();
      }
      selectedShield.coolDown();
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
    if(Float.isNaN(Speed)){
      Speed=0;
    }
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
    if(mousePressed&mouseButton==LEFT&autoShot&!selectedWeapon.heat.overHeat
       &&!selectedWeapon.empty){
      selectedWeapon.heatUP();
      if(selectedWeapon.Attribute==Weapon.LASER){
        
      }
    }else if(mousePress&mouseButton==LEFT&!autoShot&&coolingTime>maxCoolingTime
             &&!selectedWeapon.heat.overHeat&&!selectedWeapon.empty){
      selectedWeapon.absHeatUP();
    }else if(mousePress&mouseButton==RIGHT){
      shield=true;
    }
    if(coolingTime>maxCoolingTime&&((mousePressed&autoShot)||(mousePress&&!autoShot))&mouseButton==LEFT
      &&!selectedWeapon.heat.overHeat&&!selectedWeapon.empty){
      if(selectedWeapon.Attribute==Weapon.ENERGY|selectedWeapon.Attribute==Weapon.PHYSICS){
        selectedWeapon.shot();
        coolingTime=0;
      }else if(selectedWeapon.Attribute==Weapon.LASER){
        
      }
    }else if(selectedWeapon.empty){
      selectedWeapon.reload();
    }
    if(!mousePressed|selectedShield.heat.getPercentage()>=1){
      shield=false;
    }
    if(shield){
      selectedShield.heatUP();
    }
    coolingTime+=vectorMagnification;
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
    //通過したタイルを取得→衝突判定&押し出し
    Y:if(rect.x<=pos.x&&rect.x+TileSize>=pos.x
       &&rect.y-size/2<=pos.y&&rect.y+TileSize+size/2>=pos.y){
      if(rect.y+TileSize/2<pos.y){
        if(field.toAttribute(field.getTile(rect.copy().add(0,TileSize))).equals("Wall")){
          break Y;
        }
        pos.y=rect.y+TileSize+size/2;
      }else{
        if(field.toAttribute(field.getTile(rect.copy().add(0,-TileSize))).equals("Wall")){
          break Y;
        }
        pos.y=rect.y-size/2;
      }
      vel=new PVector(pos.x-prePos.x,pos.y-prePos.y);
      resetSpeed();
    }
    X:if(rect.x-size/2<=pos.x&&rect.x+TileSize+size/2>=pos.x
       &&rect.y<=pos.y&&rect.y+TileSize>=pos.y){
      if(rect.x+TileSize/2<pos.x){
        if(field.toAttribute(field.getTile(rect.copy().add(TileSize,0))).equals("Wall")){
          break X;
        }
        pos.x=rect.x+TileSize+size/2;
      }else{
        if(field.toAttribute(field.getTile(rect.copy().add(-TileSize,0))).equals("Wall")){
          break X;
        }
        pos.x=rect.x-size/2;
      }
      vel=new PVector(pos.x-prePos.x,pos.y-prePos.y);
      resetSpeed();
      return;
    }
    if(qDist(rect,pos,size/2)&
       !(field.toAttribute(field.getTile(rect.copy().add(-TileSize,0))).equals("Wall")
       |(field.toAttribute(field.getTile(rect.copy().add(0,-TileSize))).equals("Wall")))){
      float r=-atan2(rect.x-pos.x,rect.y-pos.y)-PI/2;
      int x=field.getTile(new PVector(pos.x-TileSize,pos.y));
      int y=field.getTile(new PVector(pos.x,pos.y-TileSize));
      pos.x=field.getAttributes().get(x).equals("Wall")?
            rect.x-size/2:rect.x+cos(r)*size/2;
      pos.y=field.getAttributes().get(y).equals("Wall")?
            rect.y+size/2:rect.y+sin(r)*size/2;
      vel=new PVector(pos.x-prePos.x,pos.y-prePos.y);
      resetSpeed();
      println("LeftUp");
      return;
    }else if(qDist(new PVector(rect.x,rect.y+TileSize),pos,size/2)&
             !(field.toAttribute(field.getTile(rect.copy().add(-TileSize,0))).equals("Wall")
             |(field.toAttribute(field.getTile(rect.copy().add(0,TileSize))).equals("Wall")))){
      float r=-atan2(rect.x-pos.x,rect.y+TileSize-pos.y)-PI/2;
      pos.x=rect.x+cos(r)*size/2;
      pos.y=rect.y+TileSize+sin(r)*size/2;
      vel=new PVector(pos.x-prePos.x,pos.y-prePos.y);
      resetSpeed();
      println("LeftDown");
      return;
    }else if(qDist(new PVector(rect.x+TileSize,rect.y),pos,size/2)&
             !(field.toAttribute(field.getTile(rect.copy().add(TileSize,0))).equals("Wall")
             |(field.toAttribute(field.getTile(rect.copy().add(0,-TileSize))).equals("Wall")))){
      float r=-atan2(rect.x+TileSize-pos.x,rect.y-pos.y)-PI/2;
      int x=field.getTile(new PVector(pos.x+TileSize,pos.y));
      int y=field.getTile(new PVector(pos.x,pos.y-TileSize));
      pos.x=field.getAttributes().get(x).equals("Wall")?
            rect.x+TileSize+size/2:rect.x+TileSize+cos(r)*size/2;
      pos.y=field.getAttributes().get(y).equals("Wall")?
            rect.y+size/2:rect.y+sin(r)*size/2;
      vel=new PVector(pos.x-prePos.x,pos.y-prePos.y);
      resetSpeed();
      println("RightUp");
      return;
    }else if(qDist(new PVector(rect.x+TileSize,rect.y+TileSize),pos,size/2)&
             !(field.toAttribute(field.getTile(rect.copy().add(TileSize,0))).equals("Wall")
             |(field.toAttribute(field.getTile(rect.copy().add(0,TileSize))).equals("Wall")))){
      float r=-atan2(rect.x+TileSize-pos.x,rect.y+TileSize-pos.y)-PI/2;
      pos.x=rect.x+TileSize+cos(r)*size/2;
      pos.y=rect.y+TileSize+sin(r)*size/2;
      vel=new PVector(pos.x-prePos.x,pos.y-prePos.y);
      resetSpeed();
      println("RightDown");
      return;
    }
  }
  
  void resetSpeed(){
    Speed=dist(0,0,vel.x,vel.y)*sign(Speed);
    Speed=min(abs(Speed),maxSpeed)/vectorMagnification*sign(Speed);
  }
  
  void BulletCollision(){
    hit=false;
    damage=0;
    if(shield)SHIELD:for(Bullet b:eneBullets){
      PVector bulletVel=b.vel.copy().mult(vectorMagnification);
      PVector vecAP=createVector(b.pos,pos);
      PVector normalAB=normalize(bulletVel);//vecAB->b.vel
      float lenAX=dot(normalAB,vecAP);
      float dist;
      if(lenAX<0){
        dist=dist(b.pos.x,b.pos.y,pos.x,pos.y);
      }else if(lenAX>dist(0,0,bulletVel.x,bulletVel.y)){
        dist=dist(b.pos.x+bulletVel.x,b.pos.y+bulletVel.y,pos.x,pos.y);
      }else{
        dist=abs(cross(normalAB,vecAP));
      }
      if(dist<selectedShield.size/2){
        boolean sHit=false;
        boolean cHit=false;
        float r=selectedShield.rad;
        for(int i=0;i<ceil(selectedShield.rad/(PI/18));i++){
          PVector p=new PVector(pos.x+cos(r/10*i-HALF_PI-r/2-rotate)*selectedShield.size/2,
                                pos.y+sin(r/10*i-HALF_PI-r/2-rotate)*selectedShield.size/2);
          PVector v=new PVector((cos(r/10*(i+1)-HALF_PI-r/2-rotate)-cos(r/10*i-HALF_PI-r/2-rotate))*selectedShield.size/2,
                                (sin(r/10*(i+1)-HALF_PI-r/2-rotate)-sin(r/10*i-HALF_PI-r/2-rotate))*selectedShield.size/2);
          if(SegmentCollision(b.pos.copy().sub(bulletVel.copy()),bulletVel.copy().mult(2),p,v)){
            sHit=true;
            break;
          }else if(LineCollision(p,v,b.pos,bulletVel)){
            cHit=true;
          }
        }
        if(sHit){
          b.isDead=true;
          ShotWeapon=b.usedWeapon;
          continue SHIELD;
        }else if(cHit){
          PVector left=new PVector(cos(-HALF_PI-r/2-rotate)*selectedShield.size/2,
                                   sin(-HALF_PI-r/2-rotate)*selectedShield.size/2);
          PVector right=new PVector(cos(-HALF_PI+r/2-rotate)*selectedShield.size/2,
                                   sin(-HALF_PI+r/2-rotate)*selectedShield.size/2);
          if(SegmentCollision(b.pos,bulletVel,pos,left)|SegmentCollision(b.pos,bulletVel,pos,right)){
            b.isDead=true;
            ShotWeapon=b.usedWeapon;
            continue SHIELD;
          }
        }
      }
    }
    COLLISION:for(Bullet b:eneBullets){
      if(b.isDead)continue COLLISION;
      PVector bulletVel=b.vel.copy().mult(vectorMagnification);
      PVector vecAP=createVector(b.pos,pos);
      PVector normalAB=normalize(bulletVel);//vecAB->b.vel
      float lenAX=dot(normalAB,vecAP);
      float dist;
      if(lenAX<0){
        dist=dist(b.pos.x,b.pos.y,pos.x,pos.y);
      }else if(lenAX>dist(0,0,bulletVel.x,bulletVel.y)){
        dist=dist(b.pos.x+bulletVel.x,b.pos.y+bulletVel.y,pos.x,pos.y);
      }else{
        dist=abs(cross(normalAB,vecAP));
      }
      if(dist<size/2){
        b.isDead=true;
        ShotWeapon=b.usedWeapon;
        Hit();
        continue COLLISION;
      }
    }
    if(hit){
      Particles.add(new Particle(this,str((int)damage)));
    }
  }
  
  protected void Hit(){
    HP.sub(ShotWeapon.power);
    damage+=ShotWeapon.power;
    hit=true;
  }
}

class Enemy extends Entity{
  Weapon useWeapon=null;
  Weapon ShotWeapon=null;
  ItemTable dropTable;
  double damage=0;
  boolean hit=false;
  protected double maxHP=10d;
  protected double HP=10d;
  
  Enemy(){
    setColor(new Color(0,0,255));
  }
  
  protected void setTable(){
    
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
    if(!(maxHP==HP))printHP();
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
  
  void setWeapon(Weapon w){
    useWeapon=w;
  }
  
  void updateVertex(){
    float s=size/2*1.41421356237;
    float r=-rotate+PI/4;
    LeftUP=new PVector(pos.x-cos(r)*s,pos.y+sin(r)*s);
    LeftDown=new PVector(pos.x-cos(r)*s,pos.y-sin(r)*s);
    RightUP=new PVector(pos.x+cos(r)*s,pos.y+sin(r)*s);
    RightDown=new PVector(pos.x+cos(r)*s,pos.y-sin(r)*s);
  }
  
  void BulletCollision(){
    damage=0;
    hit=false;
    COLLISION:for(Bullet b:Bullets){
      for(int i=0;i<4;i++){
        PVector s=new PVector();
        PVector v=new PVector();
        switch(i){
          case 0:s=LeftDown;v=new PVector(LeftUP.x-LeftDown.x,LeftUP.y-LeftDown.y);break;
          case 1:s=RightDown;v=new PVector(LeftDown.x-RightDown.x,LeftDown.y-RightDown.y);break;
          case 2:s=RightUP;v=new PVector(RightDown.x-RightUP.x,RightDown.y-RightUP.y);break;
          case 3:s=LeftUP;v=new PVector(RightUP.x-LeftUP.x,RightUP.y-LeftUP.y);break;
        }
        if(SegmentCollision(s,v,b.pos,new PVector(b.vel.x*vectorMagnification,b.vel.y*vectorMagnification))){
          b.isDead=true;
          ShotWeapon=b.usedWeapon;
          Hit();
          continue COLLISION;
        }
      }
    }
    if(hit)Particles.add(new Particle(this,str((int)damage)));
    if(HP<=0)Down();
  }
  
  protected void Hit(){
    HP-=ShotWeapon.power;
    damage+=ShotWeapon.power;
    hit=true;
  }
  
  protected void Down(){
    isDead=true;
    Particles.add(new Particle(this,(int)size*5,1));
    //Item drop
  }
  
  void Collision(){
    //通過したタイルを取得→衝突判定&押し出し
  }
}

class Bullet extends Entity{
  Weapon usedWeapon=null;
  PVector bVel;
  PVector tPos;
  boolean isMine=false;
  boolean isDead=false;
  boolean bounse=false;
  Color bulletColor;
  float rotate=0;
  float speed=7;
  float age=0;
  int maxAge=0;
  
  Bullet(Myself m){
    rotate=-m.rotate-PI/2+random(-m.diffuse/2,m.diffuse/2);
    speed=m.bulletSpeed;
    bulletColor=m.selectedWeapon.bulletColor;
    pos=new PVector(m.pos.x-cos(rotate)*m.size,m.pos.y-sin(rotate)*m.size);
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
    maxAge=m.selectedWeapon.bulletMaxAge;
    prePos=pos.copy();
    tPos=pos.copy();
    isMine=true;
  }
  
  Bullet(Entity e,Weapon w){
    isMine=e instanceof Myself;
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
    pos=new PVector(e.pos.x-(isMine?0:cos(rotate)*e.size),e.pos.y-(isMine?0:sin(rotate)*e.size));
    vel=new PVector(cos(rotate)*speed,sin(rotate)*speed);
    maxAge=w.bulletMaxAge;
    isMine=e.getClass().getSimpleName().equals("Myself");
    prePos=pos.copy();
    tPos=pos.copy();
    if(!isMine)bulletColor=new Color(255,0,0);
  }
  
  void display(){
    strokeWeight(1);
    stroke(bulletColor.getRed(),bulletColor.getGreen(),bulletColor.getBlue());
    line(pos.x,pos.y,pos.x+vel.x,pos.y+vel.y);
  }
  
  void update(){
    Wall();
    bVel=new PVector(vel.x,vel.y);
    pos.add(vel.copy().mult(vectorMagnification));
    vel=new PVector(bVel.x,bVel.y);
    prePos=new PVector(pos.x,pos.y);
    if(age>maxAge)isDead=true;
    age+=vectorMagnification;
    tPos=prePos.copy();
    prePos=pos.copy();
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
    //通過したタイルを取得→衝突判定
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
      for(int i=0;i<4;i++){
        PVector s=new PVector();
        PVector v=new PVector();
        LeftDown=new PVector(rect.x,rect.y+TileSize);
        LeftUP=new PVector(rect.x,rect.y);
        RightDown=new PVector(rect.x+TileSize,rect.y+TileSize);
        RightUP=new PVector(rect.x+TileSize,rect.y);
        switch(i){
          case 0:s=LeftDown;v=new PVector(LeftUP.x-LeftDown.x,LeftUP.y-LeftDown.y);break;
          case 1:s=RightDown;v=new PVector(LeftDown.x-RightDown.x,LeftDown.y-RightDown.y);break;
          case 2:s=RightUP;v=new PVector(RightDown.x-RightUP.x,RightDown.y-RightUP.y);break;
          case 3:s=LeftUP;v=new PVector(RightUP.x-LeftUP.x,RightUP.y-LeftUP.y);break;
        }
        if(SegmentCollision(pos,vel.copy().mult(vectorMagnification),s,v)){
          pos=SegmentCrossPoint(pos,vel.copy().mult(vectorMagnification),s,v);
          if(bounse){
            if((pos.x-rect.x)%TileSize<0.001&(pos.x-rect.x)%TileSize>-0.001){
              invX();
              break;
            }
            if((pos.y-rect.y)%TileSize<0.001&(pos.y-rect.y)%TileSize>-0.001){
              invY();
              break;
            }
          }else{
            isDead=true;
            Particles.add(new Particle(this,5));
          }
        }
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
