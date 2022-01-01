class GameProcess{
  menuManage mainMenu;
  Color menuColor=new Color(230,230,230);
  PShader menuShader;
  float UItime=0;
  boolean animation=false;
  String menu="Main";
  int x=16;
  int y=9;
  
  GameProcess(){
    setup();
  }
  
  void setup(){
    field.loadMap("Field02.lfdf");
    menuShader=loadShader(ShaderPath+"Menu.glsl");
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
        updateMenu();
      }
    }
    keyProcess();
  }

  void updateShape(){
    try{
    execFuture=exec.submit(particleTask);
    }catch(Exception e){
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
    text("c : Open menu",width-20,80);
  }
  
  void switchMenu(){
    if(menu.equals("Main")&!animation){
      mainMenu.init();
      menu="Menu";
      UItime=0f;
      animation=true;
    }
    if(menu.equals("Menu")&!animation){
      if(!mainMenu.isMain())return;
      menu="Main";
      UItime=30f;
      animation=true;
    }
    float normUItime=UItime/30;
    background(menuColor.getRed()*normUItime,menuColor.getGreen()*normUItime,
               menuColor.getBlue()*normUItime);
    blendMode(BLEND);
    float Width=width/x;
    float Height=height/y;
    for(int i=0;i<y;i++){//y
      for(int j=0;j<x;j++){//x
        fill(toRGB(menuColor));
        noStroke();
        rectMode(CENTER);
        float scale=min(max(UItime-(j+i),0),1);
        rect(Width*j+Width/2,Height*i+Height/2,Width*scale,Height*scale);
      }
    }
    drawMenu();
    updateMenu();
    menuShading();
    switch(menu){
      case "Main":UItime-=vectorMagnification;if(UItime<0){animation=false;mainMenu.dispose();}break;
      case "Menu":UItime+=vectorMagnification;if(UItime>30)animation=false;break;
    }
  }
  
  void drawMenu(){
    mainMenu.display();
  }
  
  void updateMenu(){
    mainMenu.update();
  }
  
  void keyProcess(){
    if(keyPress&(key=='c'|keyCode==CONTROL))switchMenu();
  }
  
  void menuShading(){
    loadPixels();
    t.pixels=pixels;
    t.updatePixels();
    menuShader.set("time",UItime);
    menuShader.set("xy",(float)x,(float)y);
    menuShader.set("resolution",(float)width,(float)height);
    menuShader.set("menuColor",(float)menuColor.getRed()/255,(float)menuColor.getGreen()/255,(float)menuColor.getBlue()/255,1.0);
    menuShader.set("tex",t);
    shader(menuShader);
    rectMode(CORNER);
    background(0);
    rect(0,0,width,height);
    resetShader();
  }
  
  class menuManage{
    String scene="main";
    ComponentSet main;
    ComponentSet conf;
    
    menuManage(){
      
    }
    
    void init(){
      main=null;
      conf=null;
      main=new ComponentSet();
      MenuButton equip=new MenuButton("装備");
      equip.setBounds(100,120,120,25);
      MenuButton item=new MenuButton("アイテム");
      item.setBounds(100,160,120,25);
      MenuButton archive=new MenuButton("アーカイブ");
      archive.setBounds(100,200,120,25);
      MenuButton setting=new MenuButton("設定");
      setting.setBounds(100,240,120,25);
      setting.addListener(()->{
        scene="conf";
        init();
      });
      main.add(equip);
      main.add(item);
      main.add(archive);
      main.add(setting);
      conf=new ComponentSet();
      MenuButton cBack=new MenuButton("戻る");
      cBack.setBounds(120,110,120,25);
      cBack.addListener(()->{
        scene="main";
        init();
      });
      MenuButton quit=new MenuButton("ゲームを終了");
      quit.setBounds(120,150,120,25);
      quit.addListener(()->{
        exit();
      });
      conf.add(cBack);
      conf.add(quit);
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
    
    boolean isMain(){
      return scene.equals("main");
    }
  }
}
