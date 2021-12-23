class GameComponent{
  protected PVector pos;
  protected PVector dist;
  protected PVector center;
  protected boolean focus=false;
  protected boolean pFocus=false;
  protected boolean FocusEvent=false;
  protected Color background=new Color(200,200,200);
  protected Color selectbackground=new Color(255,255,255);
  protected Color foreground=new Color(0,0,0);
  protected Color selectforeground=new Color(0,0,0);
  protected Color border=new Color(0,0,0);
  protected Color nonSelectBorder=border;
  
  GameComponent(){
    
  }
  
  GameComponent setBounds(float x,float y,float dx,float dy){
    pos=new PVector(x,y);
    dist=new PVector(dx,dy);
    center=new PVector(x+dx/2,y+dy/2);
    return this;
  }
  
  void setBackground(Color c){
    background=c;
  }
  
  void setSelectBackground(Color c){
    selectbackground=c;
  }
  
  void setForeground(Color c){
    foreground=c;
  }
  
  void setSelectForeground(Color c){
    selectforeground=c;
  }
  
  void setBorderColor(Color c){
    border=c;
  }
  
  void setNonSelectBorderColor(Color c){
    border=new Color(c.getRed(),c.getGreen(),c.getBlue());
  }
  
  void display(){
    
  }
  
  void update(){
    
  }
  
  void executeEvent(){
    
  }
  
  void requestFocus(){
    focus=true;
  }
  
  void removeFocus(){
    focus=false;
  }
}

class ButtonItem extends GameComponent{
  protected SelectEvent e=()->{};
  protected boolean pCursor=false;
  protected boolean setCursor=false;
  protected boolean setCursorEvent=false;
  protected boolean select=false;
  protected String text="";
  
  ButtonItem(){
    
  }
  
  ButtonItem(String s){
    text=s;
  }
  
  void addListener(SelectEvent e){
    this.e=e;
  }
  
  void mouseProcess(){
    if(mouseX>pos.x&&mouseX<pos.x+dist.x&&mouseY>pos.y&&mouseY<pos.y+dist.y){
      setCursor=true;
      select=mousePress;
      setCursorEvent=pCursor!=setCursor;
      requestFocus();
    }else{
      setCursor=false;
    }
    if(select){
      executeEvent();
    }
    if(focus&&!pFocus)FocusEvent=true;else FocusEvent=false;
    pCursor=setCursor;
    pFocus=focus;
  }
  
  void executeEvent(){
    e.selectEvent();
  }
}

class SliderItem extends GameComponent{
  protected ChangeEvent e=()->{};
  protected boolean smooth=true;
  protected boolean move=false;
  protected float Xdist=0;
  protected int Value=1;
  protected int pValue=1;
  protected int elementNum=2;
  
  SliderItem(){
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  SliderItem(int element){
    elementNum=element;
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  void setSmooth(boolean b){
    smooth=b;
  }
  
  void display(){
    blendMode(BLEND);
    strokeWeight(1);
    fill(!focus?color(background.getRed(),background.getGreen(),background.getBlue(),background.getAlpha()):
         color(selectbackground.getRed(),selectbackground.getGreen(),selectbackground.getBlue(),selectbackground.getAlpha()));
    stroke(0);
    line(pos.x,pos.y,pos.x+dist.x,pos.y);
    fill(!focus?color(foreground.getRed(),foreground.getGreen(),foreground.getBlue(),foreground.getAlpha()):
         color(selectforeground.getRed(),selectforeground.getGreen(),selectforeground.getBlue(),selectforeground.getAlpha()));
    stroke(border.getRed(),border.getGreen(),border.getBlue(),border.getAlpha());
    rectMode(CENTER);
    rect(pos.x+Xdist,pos.y,dist.y/3,dist.y,dist.y/12);
  }
  
  void update(){
    mouseProcess();
    keyProcess();
    pValue=Value;
  }
  
  void mouseProcess(){
    if(mousePress){
      if(pos.x+Xdist-dist.y/6<mouseX&mouseX<pos.x+Xdist+dist.y/6&
         pos.y-dist.y/2<mouseY&mouseY<pos.y+dist.y/2){
        move=true;
        requestFocus();
      }
    }else if(move&mousePressed){
      move=true;
    }else {
      move=false;
    }
    if(focus&&!pFocus)FocusEvent=true;else FocusEvent=false;
    pFocus=focus;
    if(move){
      Xdist=constrain(mouseX,pos.x,pos.x+dist.x)-pos.x;
      Value=constrain(round(Xdist/(dist.x/elementNum))+1,1,elementNum);
    }
    if(!smooth){
      Xdist=(dist.x/elementNum)*Value;
    }
    if(Value!=pValue)executeEvent();
  }
  
  void keyProcess(){
    switch(nowPressedKeyCode){
      case RIGHT:Value=constrain(Value+1,1,elementNum);break;
      case LEFT:Value=constrain(Value-1,1,elementNum);break;
    }
    Xdist=(dist.x/elementNum)*(Value-1);
  }
  
  void addListener(ChangeEvent e){
    this.e=e;
  }
  
  void executeEvent(){
    e.changeEvent();
  }
  
  int getValue(){
    return Value;
  }
  
  @Deprecated
  void setValue(int v){
    Value=constrain(v,1,elementNum);
    Xdist=(dist.x/elementNum)*Value;
  }
}

class MultiButton extends GameComponent{
  protected ArrayList<NomalButton>Buttons=new ArrayList<NomalButton>();
  protected boolean resize=true;
  protected int focusIndex=0;
  protected int pFocusIndex=0;
  
  MultiButton(NomalButton... b){
    Buttons=new ArrayList<NomalButton>(java.util.Arrays.asList(b));
    for(NomalButton B:Buttons){
      B.setNonSelectBorderColor(new Color(0,0,0));
      B.removeFocus();
    }
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  void add(NomalButton b){
    
  }
  
  void display(){
    if(resize){
      for(int i=0;i<Buttons.size();i++){
        Buttons.get(i).setBounds(pos.x+i*(dist.x/Buttons.size()),pos.y,dist.x/Buttons.size(),dist.y);
      }
      resize=false;
    }
    reloadIndex();
    for(NomalButton b:Buttons){
      b.display();
    }
    blendMode(BLEND);
    strokeWeight(2);
    noFill();
    stroke(border.getRed(),border.getGreen(),border.getBlue(),border.getAlpha());
    rectMode(CORNER);
    rect(pos.x,pos.y,dist.x,dist.y,dist.y/4);
  }
  
  void update(){
    mouseProcess();
    for(NomalButton b:Buttons){
      b.update();
    }
    pFocusIndex=focusIndex;
  }
  
  void mouseProcess(){
    if(mouseX>pos.x&&mouseX<pos.x+dist.x&&mouseY>pos.y&&mouseY<pos.y+dist.y){
      requestFocus();
      focusIndex=floor((mouseX-pos.x)/(dist.x/Buttons.size()));
      reloadIndex();
    }
    if(focus){
      if(keyPress)
        switch(nowPressedKeyCode){
          case RIGHT:focusIndex=constrain(focusIndex+1,0,Buttons.size()-1);reloadIndex();break;
          case LEFT:focusIndex=constrain(focusIndex-1,0,Buttons.size()-1);reloadIndex();break;
          case ENTER:Buttons.get(focusIndex).executeEvent();break;
        }
      if(!pFocus)FocusEvent=true;else FocusEvent=false;
    }
    pFocus=focus;
  }
  
  void reloadIndex(){
    for(NomalButton b:Buttons){
      b.removeFocus();
    }
    if(focus){
      Buttons.get(focusIndex).requestFocus();
    }
  }
  
  void requestFocus(){
    super.requestFocus();
    for(NomalButton b:Buttons){
      b.removeFocus();
    }
    Buttons.get(focusIndex).requestFocus();
  }
  
  void removeFocus(){
    super.removeFocus();
    for(NomalButton b:Buttons){
      b.removeFocus();
    }
  }
}

class TextButton extends ButtonItem{
  
  TextButton(){
    
  }
  
  TextButton(String s){
    super(s);
  }
  
  void display(){
    blendMode(BLEND);
    strokeWeight(1);
    fill(!focus?color(background.getRed(),background.getGreen(),background.getBlue(),background.getAlpha()):
         color(selectbackground.getRed(),selectbackground.getGreen(),selectbackground.getBlue(),selectbackground.getAlpha()));
    stroke(focus?color(border.getRed(),border.getGreen(),border.getBlue(),border.getAlpha()):
           color(nonSelectBorder.getRed(),nonSelectBorder.getGreen(),nonSelectBorder.getBlue(),nonSelectBorder.getAlpha()));
    rectMode(CORNER);
    rect(pos.x,pos.y,dist.x,dist.y);
    fill(!focus?color(foreground.getRed(),foreground.getGreen(),foreground.getBlue(),foreground.getAlpha()):
         color(selectforeground.getRed(),selectforeground.getGreen(),selectforeground.getBlue(),selectforeground.getAlpha()));
    textAlign(CENTER);
    textSize(dist.y*0.5);
    text(text,center.x,center.y+dist.y*0.2);
    blendMode(ADD);
  }
  
  void update(){
    mouseProcess();
  }
  
  TextButton setText(String s){
    text=s;
    return this;
  }
}

class NomalButton extends TextButton{
  
  NomalButton(){
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  NomalButton(String s){
    super(s);
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  void display(){
    blendMode(BLEND);
    strokeWeight(2);
    fill(!focus?color(background.getRed(),background.getGreen(),background.getBlue(),background.getAlpha()):
         color(selectbackground.getRed(),selectbackground.getGreen(),selectbackground.getBlue(),selectbackground.getAlpha()));
    stroke(border.getRed(),border.getGreen(),border.getBlue(),border.getAlpha());
    rectMode(CORNER);
    rect(pos.x,pos.y,dist.x,dist.y,dist.y/4);
    fill(!focus?color(foreground.getRed(),foreground.getGreen(),foreground.getBlue(),foreground.getAlpha()):
         color(selectforeground.getRed(),selectforeground.getGreen(),selectforeground.getBlue(),selectforeground.getAlpha()));
    textAlign(CENTER);
    textSize(dist.y*0.5);
    text(text,center.x,center.y+dist.y*0.2);
    blendMode(ADD);
  }
  
  void update(){
    super.update();
  }
  
  TextButton setText(String s){
    text=s;
    return this;
  }
}

class Menu extends ButtonItem{
  
  Menu(){
    
  }
  
  
}

class ComponentSet{
  ArrayList<GameComponent>conponents=new ArrayList<GameComponent>();
  int selectedIndex=0;
  int type=0;
  
  static final int Down=0;
  static final int Up=1;
  static final int Right=2;
  static final int Left=3;
  
  ComponentSet(){
    
  }
  
  void add(GameComponent val){
    conponents.add(val);
  }
  
  void remove(GameComponent val){
    conponents.remove(val);
  }
  
  void removeAll(){
    conponents.clear();
  }
  
  void display(){
    for(GameComponent c:conponents){
      c.display();
    }
  }
  
  void update(){
    for(GameComponent c:conponents){
      c.update();
      if(c.FocusEvent){
        for(GameComponent C:conponents){
          C.removeFocus();
        }
        c.requestFocus();
      }
      if(c.focus)selectedIndex=conponents.indexOf(c);
    }
    keyEvent();
  }
  
  void keyEvent(){
    if(keyPress){
      if(type==0|type==1){
        switch(nowPressedKeyCode){
          case DOWN:if(type==0)addSelect();else subSelect();break;
          case UP:if(type==0)subSelect();else addSelect();break;
        }
      }else if(type==2|type==3){
        switch(nowPressedKeyCode){
          case RIGHT:break;
          case LEFT:break;
        }
      }
      if(nowPressedKeyCode==ENTER){
        conponents.get(selectedIndex).executeEvent();
      }
    }
  }
  
  void addSelect(){
    for(GameComponent c:conponents){
      c.removeFocus();
    }
    selectedIndex=selectedIndex>=conponents.size()-1?0:selectedIndex+1;
    conponents.get(selectedIndex).requestFocus();
  }
  
  void subSelect(){
    for(GameComponent c:conponents){
      c.removeFocus();
    }
    selectedIndex=selectedIndex<=0?conponents.size()-1:selectedIndex-1;
    conponents.get(selectedIndex).requestFocus();
  }
}

interface SelectEvent{
  void selectEvent();
}

interface ChangeEvent{
  void changeEvent();
}
