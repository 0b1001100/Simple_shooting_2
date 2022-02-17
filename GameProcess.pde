class GameProcess{
  menuManage mainMenu;
  Color menuColor=new Color(230,230,230);
  PShader menuShader;
  float UItime=0;
  boolean animation=false;
  boolean done=false;
  String menu="Main";
  int x=16;
  int y=9;
  
  GameProcess(){
    setup();
  }
  
  void setup(){
    menuShader=loadShader(ShaderPath+"Menu.glsl");
    mainMenu=new menuManage();
    player=new Myself();
    //for(int i=0;i<300;i++)
    Enemies.add(new Turret(new PVector(300,300)));
  }
  
  void process(){
    done=false;
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
    done=true;
  }

  void updateShape(){
    try{
      particleFuture=exec.submit(particleTask);
      enemyFuture=exec.submit(enemyTask);
      bulletFuture=exec.submit(bulletTask);
    }catch(Exception e){
    }
  }
  
  void drawShape(){
    pushMatrix();
    translate(scroll.x,scroll.y);
    localMouse=unProject(mouseX,mouseY);
    player.display();
    synchronized(Enemies){
      for(Enemy e:Enemies){
        e.display();
      }
    }
    synchronized(eneBullets){
      for(Bullet b:eneBullets){
        b.display();
      }
    }
    synchronized(Bullets){
      for(Bullet b:Bullets){
        b.display();
      }
    }
    synchronized(Particles){
      for(Particle p:Particles){
          p.display();
      }
    }
    popMatrix();
    fill(255);
    textSize(15);
    text("c : Open menu",width-20,80);
  }
  
  void switchMenu(){
    if((key=='c'|keyCode==CONTROL)&menu.equals("Main")&!animation){
      mainMenu.init();
      menu="Menu";
      UItime=0f;
      animation=true;
    }else
    if((key=='x'|keyCode==SHIFT|keyCode==LEFT)&menu.equals("Menu")&!animation){
      if(mainMenu.layer.getDepth()>0){
        mainMenu.back();
        return;
      }
      menu="Main";
      UItime=30f;
      animation=true;
    }
    if(!animation)return;
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
        float scale=min(max(UItime*(y/9)-(j+i),0),1);
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
    if(keyPress&(key=='c'|keyCode==CONTROL|key=='x'|keyCode==SHIFT|keyCode==LEFT))switchMenu();
  }
  
  void menuShading(){
    menuShader.set("time",UItime);
    menuShader.set("xy",(float)x,(float)y);
    menuShader.set("resolution",(float)width,(float)height);
    menuShader.set("menuColor",(float)menuColor.getRed()/255,(float)menuColor.getGreen()/255,(float)menuColor.getBlue()/255,1.0);
    menuShader.set("tex",g);
    filter(menuShader);
  }
  
  class menuManage{
    ComponentSetLayer layer;
    HashMap<String,ComponentSet>componentMap=new HashMap<String,ComponentSet>();
    ComponentSet main;
    ComponentSet equ;
    ComponentSet Item;
    ComponentSet arc;
    ComponentSet conf;
    boolean pStack=false;
    boolean first=true;
    
    menuManage(){
    }
    
    void init(){
      layer=new ComponentSetLayer();
      main=null;
      equ=null;
      Item=null;
      arc=null;
      conf=null;
      initMain();
      initEqu();
      initItem();
      initArc();
      initConf();
      if(first){
        first=false;
      }
    }
    
    void initMain(){
      main=new ComponentSet();
      layer.addLayer("Main",main);
      MenuButton equip=new MenuButton("装備");
      equip.setBounds(100,120,120,25);
      equip.addListener(()->{
        layer.toChild("equ");
      });
      MenuButton item=new MenuButton("アイテム");
      item.setBounds(100,160,120,25);
      item.addListener(()->{
        layer.toChild("Item");
      });
      MenuButton archive=new MenuButton("アーカイブ");
      archive.setBounds(100,200,120,25);
      archive.addListener(()->{
        layer.toChild("arc");
      });
      MenuButton setting=new MenuButton("設定");
      setting.setBounds(100,240,120,25);
      setting.addListener(()->{
        layer.toChild("conf");
      });
      main.add(equip);
      main.add(item);
      main.add(archive);
      main.add(setting);
      main.setSubSelectButton(RIGHT);
      componentMap.put("main",main);
    }
    
    void initEqu(){
      equ=new ComponentSet();
      layer.addChild("Main","equ",equ);
      MenuItemList wList=new MenuItemList();
      MenuButton eBack=new MenuButton("戻る");
      eBack.setBounds(20,100,120,25);
      eBack.addListener(()->{
        layer.toParent();
      });
      eBack.addFocusListener(new FocusEvent(){
        void getFocus(){
          wList.LinkTable(null);
        }
        
        void lostFocus(){
        }
      });
      MenuButton weapon=new MenuButton("武器");
      weapon.setBounds(20,130,120,25);
      weapon.addListener(()->{
      });
      weapon.addFocusListener(new FocusEvent(){
        void getFocus(){
          wList.LinkTable(player.Weapons);
        }
        
        void lostFocus(){
        }
      });
      ComponentSet cListSet=new ComponentSet();
      MenuItemList cList=new MenuItemList();
      cList.LinkTable(player.Chips);
      MenuButton ext=new MenuButton("拡張");
      ext.setBounds(20,160,120,25);
      ext.addListener(()->{
      });
      ext.addFocusListener(new FocusEvent(){
        void getFocus(){
        }
        
        void lostFocus(){
        }
      });
      equ.add(eBack);
      equ.add(weapon);
      equ.add(ext);
      equ.setSubSelectButton(RIGHT);
      componentMap.put("equ",equ);
    }
    
    void initItem(){
      Item=new ComponentSet();
      layer.addChild("Main","Item",Item);
      MenuItemList iList=new MenuItemList();
      iList.setBounds(170,50,325,height-200);
      iList.setSubBounds(520,50,325,400);
      StatusList iSta=new StatusList(player);
      iSta.setBounds(width-400,50,350,0);
      iList.addItemListener((Item i)->{
        if(iList.table!=null){
          if(iList.table.equals(player.Items)){
            iSta.setAddHP(i.getRecovory());
          }
        }
      });
      MenuButton iBack=new MenuButton("戻る");
      iBack.setBounds(20,100,120,25);
      iBack.addListener(()->{
        layer.toParent();
      });
      iBack.addFocusListener(new FocusEvent(){
        void getFocus(){
          iList.LinkTable(null);
        }
        
        void lostFocus(){
        }
      });
      MenuButton ite=new MenuButton("アイテム");
      ite.setBounds(20,130,120,25);
      ite.addListener(()->{
        layer.toChild("iList");
      });
      ite.addFocusListener(new FocusEvent(){
        void getFocus(){
          iList.LinkTable(player.Items);
        }
        
        void lostFocus(){
        }
      });
      MenuButton mat=new MenuButton("素材");
      mat.setBounds(20,160,120,25);
      mat.addListener(()->{
        layer.toChild("iList");
      });
      mat.addFocusListener(new FocusEvent(){
        void getFocus(){
          iList.LinkTable(player.Materials);
        }
        
        void lostFocus(){
        }
      });
      MenuButton wea=new MenuButton("武器");
      wea.setBounds(20,190,120,25);
      wea.addListener(()->{
        layer.toChild("iList");
      });
      wea.addFocusListener(new FocusEvent(){
        void getFocus(){
          iList.LinkTable(player.Weapons);
        }
        
        void lostFocus(){
        }
      });
      MenuButton chi=new MenuButton("拡張チップ");
      chi.setBounds(20,220,120,25);
      chi.addListener(()->{
        layer.toChild("iList");
      });
      chi.addFocusListener(new FocusEvent(){
        void getFocus(){
          iList.LinkTable(player.Chips);
        }
        
        void lostFocus(){
        }
      });
      Item.add(iBack);
      Item.add(ite);
      Item.add(mat);
      Item.add(wea);
      Item.add(chi);
      layer.addSubChild("Item","iList",toSet(iList));
      layer.addContent("Item",toSet(iSta));
      Item.setSubSelectButton(RIGHT);
      componentMap.put("Item",Item);
    }
    
    void initArc(){
      arc=new ComponentSet();
      layer.addChild("Main","arc",arc);
      MenuButton aBack=new MenuButton("戻る");
      aBack.setBounds(20,100,120,25);
      aBack.addListener(()->{
        layer.toParent();
      });
      arc.add(aBack);
      arc.setSubSelectButton(RIGHT);
      componentMap.put("arc",arc);
    }
    
    void initConf(){
      conf=new ComponentSet();
      layer.addChild("Main","conf",conf);
      MenuButton cBack=new MenuButton("戻る");
      cBack.setBounds(120,110,120,25);
      cBack.addListener(()->{
        layer.toParent();
      });
      MenuButton quit=new MenuButton("ゲームを終了");
      quit.setBounds(120,150,120,25);
      quit.addListener(()->{
        exit();
      });
      conf.add(cBack);
      conf.add(quit);
      conf.setSubSelectButton(RIGHT);
      componentMap.put("conf",conf);
    }
    
    void display(){
      layer.display();
    }
    
    void update(){
      boolean Stack=false;
      layer.update();
      pStack=Stack;
    }
    
    void dispose(){
      main=null;
      equ=null;
      Item=null;
      arc=null;
      conf=null;
    }
    
    boolean isMain(){
      return layer.getLayerName().equals("Main");
    }
    
    void back(){
      layer.toParent();
    }
  }
}
