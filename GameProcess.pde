class GameProcess{
  float UItime=0;
  boolean animation=false;
  String menu="Main";
  
  GameProcess(){
    setup();
  }
  
  void setup(){
    field.loadMap("Field02.lfdf");
    player=new Myself();
    Enemies.add(new Turret(new PVector(300,300)));
  }
  
  void process(){
    if(animation){
      switchMenu();
    }else{
      if(menu.equals("Main")){
        background(0);
        field.displayMap();
        drawShape();
        updateShape();
      }else if(menu.equals("Menu")){
        background(255,230,200);
      }
    }
    if(keyPress&key=='x')switchMenu();
  }

  void updateShape(){
    try{
    execFuture=exec.submit(particleTask);
    }catch(Exception e){
      e.printStackTrace();
    }
  }
  
  void drawShape(){
    pushMatrix();
    translate(scroll.x,scroll.y);
    localMouse=unProject(mouseX,mouseY);
    player.display();
    for(Enemy e:Enemies){
      e.display();
    }
    for(Bullet b:eneBullets){
      b.display();
    }
    for(Bullet b:Bullets){
      b.display();
    }
    for(Particle p:Particles){
      p.display();
    }
    popMatrix();
    fill(255);
    textSize(15);
    text("x : Open menu",width-20,80);
  }
  
  void switchMenu(){
    background(255*UItime/30,230*UItime/30,200*UItime/30);
    if(menu.equals("Main")&!animation){
      menu="Menu";
      UItime=0f;
      animation=true;
    }
    if(menu.equals("Menu")&!animation){
      menu="Main";
      UItime=30f;
      animation=true;
    }
    float Width=width/16f;
    float Height=height/9f;
    for(int i=0;i<9;i++){//y
      for(int j=0;j<16;j++){//x
        fill(255,230,200);
        noStroke();
        rectMode(CENTER);
        pushMatrix();
        scale(min(max(UItime-(j+i),0),1));
        rect(Width*j+Width/2,Height*i+Height/2,Width,Height);
        popMatrix();
      }
    }
    switch(menu){
      case "Main":UItime-=vectorMagnification;if(UItime<0)animation=false;break;
      case "Menu":UItime+=vectorMagnification;if(UItime>30)animation=false;break;
    }
  }
  
  void drawMenu(){
    
  }
}
