class GameProcess{
  menuManage mainMenu;
  Color menuColor=new Color(230,230,230);
  float UItime=0;
  boolean animation=false;
  String menu="Main";
  
  GameProcess(){
    setup();
  }
  
  void setup(){
    field.loadMap("Field02.lfdf");
    mainMenu=new menuManage();
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
        background(menuColor.getRed(),menuColor.getGreen(),menuColor.getBlue());
        drawMenu();
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
    float normUItime=UItime/30;
    background(menuColor.getRed()*normUItime,menuColor.getGreen()*normUItime,
               menuColor.getBlue()*normUItime,menuColor.getAlpha());
    if(menu.equals("Main")&!animation){
      mainMenu.init();
      menu="Menu";
      UItime=0f;
      animation=true;
    }
    if(menu.equals("Menu")&!animation){
      mainMenu.dispose();
      menu="Main";
      UItime=30f;
      animation=true;
    }
    int x=9;
    int y=16;
    float Width=width/16f;
    float Height=height/9f;
    for(int i=0;i<x;i++){//y
      for(int j=0;j<y;j++){//x
        fill(menuColor.getRed(),menuColor.getGreen(),menuColor.getBlue());
        noStroke();
        rectMode(CENTER);
        pushMatrix();
        float scale=min(max(UItime-(j+i),0),1);
        rect(Width*j+Width/2,Height*i+Height/2,Width*scale,Height*scale);
        popMatrix();
      }
    }
    switch(menu){
      case "Main":UItime-=vectorMagnification;if(UItime<0)animation=false;break;
      case "Menu":UItime+=vectorMagnification;if(UItime>30)animation=false;break;
    }
  }
  
  void drawMenu(){
    mainMenu.display();
  }
  
  class menuManage{
    String scene="main";
    ComponentSet main;
    ComponentSet conf;
    
    menuManage(){
      
    }
    
    void init(){
      main=new ComponentSet();
      MenuButton equip=new MenuButton("装備");
      equip.setBounds(100,120,120,25);
      MenuButton item=new MenuButton("アイテム");
      item.setBounds(100,160,120,25);
      MenuButton archive=new MenuButton("アーカイブ");
      archive.setBounds(100,200,120,25);
      MenuButton setting=new MenuButton("設定");
      setting.setBounds(100,240,120,25);
      main.add(equip);
      main.add(item);
      main.add(archive);
      main.add(setting);
    }
    
    void display(){
      switch(scene){
        case "main":main.display();break;
        case "conf":conf.display();break;
      }
    }
    
    void update(){
      switch(scene){
        case "main":main.update();break;
        case "conf":conf.update();break;
      }
    }
    
    void dispose(){
      main=null;
      conf=null;
    }
  }
}
