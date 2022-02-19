class Weapon implements Equipment{
  heatCapacity heat=new heatCapacity(0,100,0);
  Entity parent;
  boolean autoShot=true;
  boolean pHeat=false;
  boolean empty=false;
  String name="default";
  float power=1;
  float speed=15;
  Float diffuse=0f;
  float coolTime=10;
  float heatUP=0.4;
  float coolDown=0.2;
  int bulletNumber=1;
  int bulletMaxAge=120;
  int Attribute=ENERGY;
  int itemNumber=INFINITY;
  int loadNumber=INFINITY;
  int loadedNumber=INFINITY;
  int reloadTime=0;
  int maxReloadTime=60;
  int type=ATTAK;
  Color bulletColor=new Color(0,0,255);
  
  static final int ENERGY=0;
  static final int LASER=1;
  static final int PHYSICS=2;
  static final int EXPLOSIVE=3;
  
  static final int INFINITY=-1;
  
  Weapon(Entity e){
    parent=e;
  }
  
  void setType(int t){
    type=t;
  }
  
  void setPower(float p){
    power=p;
  }
  
  void setSpeed(float s){
    speed=s;
  }
  
  void setColor(Color c){
    bulletColor=c;
  }
  
  void setColor(int r,int g,int b){
    bulletColor=new Color(r,g,b);
  }
  
  void setDiffuse(Float rad){
    diffuse=rad;
  }
  
  void setCoolTime(float t){
    coolTime=t;
  }
  
  void setName(String s){
    name=s;
  }
  
  void setAttribute(int a){
    Attribute=a;
  }
  
  void setAutoShot(boolean a){
    autoShot=a;
  }
  
  void setMaxAge(int i){
    bulletMaxAge=i;
  }
  
  void setBulletNumber(int n){
    bulletNumber=n;
  }
  
  void setHeatUP(float h){
    heatUP=h;
  }
  
  void setCoolDown(float c){
    coolDown=c;
  }
  
  void setLoadNumber(int i){
    loadNumber=i;
  }
  
  void setLoadedNumber(int i){
    loadedNumber=i;
  }
  
  void setReloadTime(int t){
    maxReloadTime=t;
  }
  
  String getName(){
    return name;
  }
  
  void heatUP(){
    heat.add(heatUP*vectorMagnification);
    heat.getPercentage();
  }
  
  void absHeatUP(){
    heat.add(heatUP);
    heat.getPercentage();
  }
  
  void overHeat(){
    heat.set(100);
  }
  
  void coolDown(){
    if(!heat.overHeat){
      heat.add(-coolDown*vectorMagnification);
    }else{
      heat.add(-coolDown*vectorMagnification*2.5);
    }
    heat.getPercentage();
  }
  
  void reload(){
    reloadTime+=floor(vectorMagnification);
    empty=true;
    if(reloadTime!=0&!pHeat){
      overHeat();
      pHeat=true;
    }
    if(maxReloadTime<=reloadTime){
      loadedNumber=min(loadNumber,itemNumber!=INFINITY ? itemNumber:loadNumber);
      itemNumber-=itemNumber!=INFINITY ? loadedNumber:0;
      empty=false;
      if(itemNumber==0&&loadedNumber==0){
        empty=true;
      }
      reloadTime=0;
      pHeat=false;
    }
  }
  
  void shot(){
    switch(Attribute){
    case ENERGY:
    case PHYSICS:synchronized(Bullets){
                   for(int i=0;i<this.bulletNumber;i++){
                     Bullets.add(new Bullet(parent,this));
                   }
                 }
                 break;
    case LASER:break;
    }
  }
}

class EnergyBullet extends Weapon{
  
  EnergyBullet(Entity e){
    super(e);
    setPower(2);
    setDiffuse(radians(3));
    setName("クォークキャノン");
  }
}

class DiffuseBullet extends Weapon{
  
  DiffuseBullet(Entity e){
    super(e);
    setPower(4);
    setAutoShot(false);
    setBulletNumber(4);
    setColor(new Color(255,105,20));
    setCoolTime(15);
    setHeatUP(20);
    setCoolDown(0.2);
    setDiffuse(radians(20));
    setName("タウブラスター");
  }
}

class PulseBullet extends Weapon{
  
  PulseBullet(Entity e){
    super(e);
    setPower(1.3);
    setAutoShot(true);
    setColor(new Color(0,255,255));
    setCoolTime(5);
    setHeatUP(0.45);
    setDiffuse(radians(7.5));
    setName("フォトンパルス");
  }
}

class LMG extends Weapon{
  
  LMG(Entity e){
    super(e);
    setPower(3.21);
    setAutoShot(true);
    setColor(new Color(255,95,0));
    setCoolTime(5);
    setHeatUP(0.47);
    setCoolDown(0.2);
    setDiffuse(radians(8));
    setName("小型機関銃");
  }
  
  void heatUP(){
    heat.add(heatUP*vectorMagnification);
    setDiffuse(radians(8+35*heat.getPercentage()));
  }
  
  void coolDown(){
    if(!heat.overHeat){
      heat.add(-coolDown*vectorMagnification);
    }else{
      heat.add(-coolDown*vectorMagnification*2.5);
    }
    setDiffuse(radians(8+35*heat.getPercentage()));
  }
}

class ILMG extends Weapon{
  
  ILMG(Entity e){
    super(e);
    setPower(3.21);
    setAutoShot(true);
    setColor(new Color(255,95,0));
    setCoolTime(5);
    setHeatUP(0.41);
    setCoolDown(0.17);
    setDiffuse(radians(30));
    setName("改良型機関銃");
  }
  
  void heatUP(){
    heat.add(heatUP*vectorMagnification);
    setDiffuse(radians(30-25*heat.getPercentage()));
  }
  
  void coolDown(){
    if(!heat.overHeat){
      heat.add(-coolDown*vectorMagnification);
    }else{
      heat.add(-coolDown*vectorMagnification*2.5);
    }
    setDiffuse(radians(30-25*heat.getPercentage()));
  }
}

class LASER extends Weapon{
  
  LASER(Entity e){
    super(e);
    setPower(1.3);
    setAttribute(LASER);
    setAutoShot(true);
    setColor(new Color(0,255,255));
    setCoolTime(5);
    setHeatUP(0.45);
    setDiffuse(radians(7.5));
    setName("レーザー");
  }
}

class Shield{
  heatCapacity heat=new heatCapacity(0,100,0);
  Entity parent;
  Color c=new Color(0,140,255);
  String name="";
  float magnification=1;
  float size=20;
  float coolTime=10;
  float heatUP=0.6;
  float coolDown=0.2;
  float rad=radians(90);
  
  Shield(Entity e){
    parent=e;
    this.size=e.size*1.3;
  }
  
  void setCoolTime(float f){
    coolTime=f;
  }
  
  void setHeatUP(float f){
    heatUP=f;
  }
  
  void setCoolDown(float f){
    coolDown=f;
  }
  
  void setMagnification(float f){
    magnification=f;
  }
  
  void heatUP(){
    heat.add(heatUP*vectorMagnification);
  }
  
  void damage(double d){
    heat.add(d*magnification);
  }
  
  void overHeat(){
    heat.set(100);
  }
  
  void coolDown(){
    if(!heat.overHeat){
      heat.add(-coolDown*vectorMagnification);
    }else{
      heat.add(-coolDown*vectorMagnification*2.5);
    }
  }
  
  void display(){
    blendMode(BLEND);
    noFill();
    stroke(128);
    strokeWeight(2);
    pushMatrix();
    translate(parent.pos.x,parent.pos.y);
    rotate(-parent.rotate);
    arc(0,0,size,size,-rad/2-HALF_PI,rad/2-HALF_PI);
    stroke(toColor(c));
    arc(0,0,size,size,-HALF_PI-rad/2,-HALF_PI-rad/2+rad*(1-heat.getPercentage()));
    popMatrix();
  }
}

interface Equipment{
  int ATTAK=1;
  int DIFENCE=2;
}
