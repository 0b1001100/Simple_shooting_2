PImage t;

void Menu(){
  background(0);
  if(nowMenu.equals("Config")){
    configration();
    return;
  }
  if(changeScene){
    starts.removeAll();
    NormalButton New=new NormalButton("New Game");
    New.setBounds(100,100,120,30);
    New.addListener(()->{scene=2;});
    NormalButton Load=new NormalButton("Load Game");
    Load.setBounds(100,140,120,30);
    NormalButton Config=new NormalButton("Confuguration");
    Config.setBounds(100,180,120,30);
    Config.addListener(()->{nowMenu="Config";});
    starts.add(New);
    starts.add(Load);
    starts.add(Config);
  }
  starts.display();
  starts.update();
}

void configration(){
  background(50);
  if(changeScene){
    configs.removeAll();
    NormalButton halfFPS=new NormalButton("30FPS");
    halfFPS.addListener(()->{frameRate(30);});
    NormalButton fullFPS=new NormalButton("60FPS");
    fullFPS.addListener(()->{frameRate(60);});
    NormalButton qFPS=new NormalButton("144FPS");
    qFPS.addListener(()->{frameRate(144);});
    NormalButton ulFPS=new NormalButton("無制限");
    ulFPS.addListener(()->{frameRate(1024);});
    MultiButton fps=new MultiButton(halfFPS,fullFPS,qFPS,ulFPS);
    fps.setBounds(100,30,300,25);
    NormalButton Inv=new NormalButton("色反転");
    Inv.setBounds(100,60,80,25);
    Inv.addListener(()->{ColorInv=!ColorInv;});
    configs.add(fps);
    configs.add(Inv);
  }
  configs.display();
  configs.update();
  if(keyPress&nowPressedKeyCode==SHIFT){
    nowMenu="Main";
  }
}

void Shader(){
  if(ColorInv){
    g.loadPixels();
    t.pixels=g.pixels;
    t.updatePixels();
    colorInv.set("tex",t);
    colorInv.set("resolution",width,height);
    filter(colorInv);
  }
}

void printFPS(){
  pushMatrix();
  resetMatrix();
  textAlign(LEFT);
  textSize(10);
  fill(0,220,0);
  float MTime=0;
  for(long l:Times)MTime+=l;
  MTime/=(float)Times.size();
  text(1000f/MTime,10,10);
  popMatrix();
}
