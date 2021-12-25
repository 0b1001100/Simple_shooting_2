PImage t;

void Menu(){
  background(0);
  if(nowMenu.equals("Config")){
    configration();
    return;
  }
  if(changeScene){
    starts.removeAll();
    NomalButton New=new NomalButton("New Game");
    New.setBounds(100,100,120,30);
    New.addListener(()->{scene=2;});
    NomalButton Load=new NomalButton("Load Game");
    Load.setBounds(100,140,120,30);
    NomalButton Config=new NomalButton("Confuguration");
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
    NomalButton halfFPS=new NomalButton("30FPS");
    halfFPS.addListener(()->{frameRate(30);});
    NomalButton fullFPS=new NomalButton("60FPS");
    fullFPS.addListener(()->{frameRate(60);});
    NomalButton qFPS=new NomalButton("144FPS");
    qFPS.addListener(()->{frameRate(144);});
    NomalButton ulFPS=new NomalButton("無制限");
    ulFPS.addListener(()->{frameRate(1024);});
    MultiButton fps=new MultiButton(halfFPS,fullFPS,qFPS,ulFPS);
    fps.setBounds(100,30,300,25);
    NomalButton Inv=new NomalButton("色反転");
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
}

void Shader(){
  if(ColorInv){
    loadPixels();
    t.pixels=pixels;
    t.updatePixels();
    colorInv.set("tex",t);
    colorInv.set("resolution",width,height);
    shader(colorInv);
    pushMatrix();
    resetMatrix();
    background(0);
    fill(255);
    rect(0,0,width,height);
    popMatrix();
    resetShader();
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
