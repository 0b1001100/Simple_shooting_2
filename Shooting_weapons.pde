class Weapon implements Equipment{
  heatCapacity heat=new heatCapacity(0,100,0);
  Entity parent;
  boolean autoShot=true;
  boolean pHeat=false;
  boolean empty=false;
  String name="default";
  float power=1;
  float speed=15;
  float diffuse=0;
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
  
  void setDiffuse(float rad){
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
    if(Attribute==LASER){
      int maxLength=0;
      pushMatrix();
      resetMatrix();
      translate(width/2,height/2);
      rotate(-parent.rotate-radians(90));
      strokeWeight(1);
      stroke(100);
      for(int i=1;i<=bulletMaxAge*3;i++){
        
      }
      line(0,0,bulletMaxAge*3,0);
      popMatrix();
    }
  }
  
  void absHeatUP(){
    heat.add(heatUP);
    heat.getPercentage();
    if(Attribute==LASER){
      int maxLength=0;
      pushMatrix();
      resetMatrix();
      translate(width/2,height/2);
      rotate(-parent.rotate-radians(90));
      strokeWeight(1);
      stroke(100);
      for(int i=1;i<=bulletMaxAge*3;i++){
        
      }
      line(0,0,bulletMaxAge*3,0);
      popMatrix();
    }
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
    case PHYSICS:for(int i=0;i<this.bulletNumber;i++){
                   Bullets.add(new Bullet(parent,this));
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
  
}

interface Equipment{
  int ATTAK=1;
  int DIFENCE=2;
}
