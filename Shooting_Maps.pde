class Fields{
  
  ExecutorService load=Executors.newCachedThreadPool();
  Runnable r;
  //Map---------------------------------------------
  ArrayList<String>MainAttr=new ArrayList<String>();
  MetaTileManagement MetaTiles=new MetaTileManagement();
  PVector spownPoint;
  //Stage------------------------------------------------
  ArrayList<String>StageMainAttr=new ArrayList<String>();
  MetaTileManagement StageMetaTiles=new MetaTileManagement();
  PVector StageSpownPoint;
  //Map&Stage connector-
  String nowField="Map";
  String selectedPath;
  //FieldBuffer-------
  int[][] SelectedMap;
  int[][] SelectedStage;
  int[][] loadUP;
  int[][] loadDown;
  int[][] loadRight;
  int[][] loadLeft;
  int buffer_size=32;
  //GlobalData-----------------------------------
  ArrayList<String>Paths=new ArrayList<String>();
  int[][] SelectedField;
  
  static final int tileSize=80;
  
  Fields(){
    r=()->{
      
    };
  }
  
  void reloadPath(){
    
  }
  
  void loadMap(String s){
    XML data=loadXML(MapPath+s);
    XML[] Main=data.getChildren("Main");
    XML[] Meta=data.getChildren("MetaData");
    for(XML x:Main){
      int[][] FieldData=new int[int(x.getChildren("FieldHeight")[0].getContent())][int(x.getChildren("FieldWidth")[0].getContent())];
      XML[] Attribute=x.getChildren("Attributes")[0].getChildren("Attribute");
      MainAttr.clear();
      for(XML Att:Attribute){
        MainAttr.add(Att.getInt("Type"),(String)Att.getContent());
      }
      XML[] LayeredField=x.getChildren("LayeredField")[0].getChildren("Field");
      for(XML lf:LayeredField){
        FieldData[lf.getInt("y")][lf.getInt("x")]=int(lf.getContent());
      }
      SelectedMap=FieldData;
    }
    for(XML x:Meta){
      XML[] MetaData=x.getChildren("MetaTileData");
      MetaTiles.clearTile();
      for(XML tile:MetaData){
        String Values=tile.getContent();
        MetaTiles.addTile(tile.getString("Attribute"),Values.split(":")[0],Values.split(":")[1],
                          new PVector(tile.getInt("x"),tile.getInt("y")));
      }
    }
    if(nowField.equals("Map")){
      SelectedField=SelectedMap;
    }
    spownPoint=MetaTiles.getTiles("Spown")[0].getPos().mult(tileSize).add(tileSize/2,tileSize/2);
  }
  
  void loadStage(String s){
    XML data=loadXML(MapPath+s);
    XML[] Main=data.getChildren("Main");
    XML[] Meta=data.getChildren("MetaData");
    for(XML x:Main){
      int[][] FieldData=new int[int(x.getChildren("FieldHeight")[0].getContent())][int(x.getChildren("FieldWidth")[0].getContent())];
      XML[] Attribute=x.getChildren("Attributes")[0].getChildren("Attribute");
      StageMainAttr.clear();
      for(XML Att:Attribute){
        StageMainAttr.add(Att.getInt("Type"),(String)Att.getContent());
      }
      XML[] LayeredField=x.getChildren("LayeredField")[0].getChildren("Field");
      for(XML lf:LayeredField){
        FieldData[lf.getInt("y")][lf.getInt("x")]=int(lf.getContent());
      }
      SelectedStage=FieldData;
    }
    for(XML x:Meta){
      XML[] MetaData=x.getChildren("MetaTileData");
      StageMetaTiles.clearTile();
      for(XML tile:MetaData){
        String Values=tile.getContent();
        StageMetaTiles.addTile(tile.getString("Attribute"),Values.split(":")[0],Values.split(":")[1],
                          new PVector(tile.getInt("x"),tile.getInt("y")));
      }
    }
    if(nowField.equals("Stage")){
      SelectedField=SelectedStage;
    }
    StageSpownPoint=StageMetaTiles.getTiles("Spown")[0].getPos().mult(tileSize).add(tileSize/2,tileSize/2);
  }
  
  void toStage(){
    if(nowField.equals("Map")){
      SelectedField=SelectedStage;
      player.setpos(StageSpownPoint);
      nowField="Stage";
    }
  }
  
  void changeStage(String s){
    if(nowField.equals("Stage")){
    loadStage(s);
    SelectedField=SelectedStage;
    player.setpos(StageSpownPoint);
    }
  }
  
  void toMap(){
    if(nowField.equals("Stage")){
      SelectedField=SelectedMap;
      player.setpos(spownPoint);
      nowField="Map";
    }
  }
  
  void changeMap(String s){
    if(nowField.equals("Map")){
    loadMap(s);
    SelectedField=SelectedMap;
    player.setpos(spownPoint);
    }
  }
  
  void displayMap(){
    Camera c=player.camera;
    PGraphics Maskg=createGraphics(width,height);
    Maskg.beginDraw();
    Maskg.fill(255);
    rectMode(CORNER);
    blendMode(BLEND);
    for(int i=min(SelectedField.length,max(0,floor((-c.pos.y)/tileSize)));i<min(SelectedField.length,ceil((-c.pos.y+height)/tileSize));i++){
      for(int j=min(SelectedField[i].length,max(0,floor((-c.pos.x)/tileSize)));j<min(SelectedField[i].length,ceil((-c.pos.x+width)/tileSize));j++){
        noStroke();
        try{
          if((nowField.equals("Map")|nowField.equals("Stage"))&MainAttr.get(SelectedField[i][j]).equals("Wall")&MainAttr!=null){
            noFill();
            Maskg.noFill();
          }else{
            fill(0,20,80);
            Maskg.fill(0);
          }
        }catch(IndexOutOfBoundsException e){
          fill(0,20,80);
          Maskg.fill(0);
        }
        rect(tileSize*j+c.pos.x,tileSize*i+c.pos.y,tileSize+1,tileSize+1);
        Maskg.rect(tileSize*j,tileSize*i,tileSize+1,tileSize+1);
      }
    }
    displayObject();
    Maskg.endDraw();
    PVector zero=unProject(0,0);
    //Mask=Maskg.get((int)zero.x,(int)zero.y,width,height);
    //Map=g.get((int)zero.x,(int)zero.y,width,height);
    blendMode(ADD);
  }
  
  void displayObject(){
    
  }
  
  int[][] getAround(PVector pos){
    int[][]Around=new int[3][3];
    for(int i=0;i<3;i++){
      for(int j=0;j<3;j++){
        if(nowField.equals("Map")){
          Around[i][j]=SelectedMap[min(max(0,(int)pos.y+(i-1)),SelectedMap.length-1)]
                                    [min(max(0,(int)pos.x+(j-1)),SelectedMap[0].length-1)];
        }else if(nowField.equals("Stage")){
          Around[i][j]=SelectedStage[min(max(0,(int)pos.y+(i-1)),SelectedStage.length-1)]
                                    [min(max(0,(int)pos.x+(j-1)),SelectedStage[0].length-1)];
        }
      }
    }
    return Around;
  }
  
  int getTile(PVector pos){
    pos=new PVector(floor(pos.x/tileSize),floor(pos.y/tileSize));
    return SelectedMap[min(max(0,(int)pos.y),SelectedMap.length-1)]
                      [min(max(0,(int)pos.x),SelectedMap[0].length-1)];
  }
  
  int getTile(float x,float y){
    x=floor(x/tileSize);
    y=floor(y/tileSize);
    return SelectedMap[min(max(0,(int)y),SelectedMap.length-1)]
                      [min(max(0,(int)x),SelectedMap[0].length-1)];
  }
  
  int getTileFromIndex(PVector pos){
    return SelectedMap[(int)pos.y][(int)pos.x];
  }
  
  int getTileFromIndex(float x,float y){
    return SelectedMap[(int)y][(int)x];
  }
  
  ArrayList<String> getAttributes(){
    return nowField.equals("Map")?MainAttr:nowField.equals("Stage")?StageMainAttr:null;
  }
  
  String toAttribute(int i){
    return nowField.equals("Map")?MainAttr.get(i):nowField.equals("Stage")?StageMainAttr.get(i):null;
  }
}

class MetaTileManagement{
  HashMap<String,ArrayList<MetaTile>>MetaTiles=new HashMap<String,ArrayList<MetaTile>>();
  
  MetaTileManagement(){
    
  }
  
  void addTile(String type,PVector pos){
    if(MetaTiles.containsKey(type)){
      boolean add=true;
      for(int i=0;i<MetaTiles.get(type).size();i++){
        if(MetaTiles.get(type).get(i).getPos().equals(pos)){
          add=false;
          break;
        }
      }
      if(add)MetaTiles.get(type).add(new MetaTile(type,pos));
    }else{
      MetaTiles.put(type,new ArrayList<MetaTile>());
      MetaTiles.get(type).add(new MetaTile(type,pos));
    }
  }
  
  void addTile(String type,String v1,String v2,PVector pos){
    if(MetaTiles.containsKey(type)){
      boolean add=true;
      for(int i=0;i<MetaTiles.get(type).size();i++){
        if(MetaTiles.get(type).get(i).getPos().equals(pos)){
          add=false;
          break;
        }
      }
      if(add)MetaTiles.get(type).add(new MetaTile(type,v1,v2,pos));
    }else{
      MetaTiles.put(type,new ArrayList<MetaTile>());
      MetaTiles.get(type).add(new MetaTile(type,v1,v2,pos));
    }
  }
  
  void removeTile(String type,PVector pos){
    for(int i=0;i<MetaTiles.get(type).size();i++){
      if(MetaTiles.get(type).get(i).getPos().equals(pos)){
        MetaTiles.get(type).remove(i);
        return;
      }
    }
  }
  
  void removeTile(PVector pos){
    for(String s:MetaTiles.keySet()){
      for(int i=0;i<MetaTiles.get(s).size();i++){
        if(MetaTiles.get(s).get(i).getPos().equals(pos)){
          MetaTiles.get(s).remove(i);
          return;
        }
      }
    }
  }
  
  void clearTile(){
    MetaTiles.clear();
  }
  
  void setTile(String type,PVector pos){
    for(String s:MetaTiles.keySet()){
      for(int i=0;i<MetaTiles.get(s).size();i++){
        if(MetaTiles.get(s).get(i).getPos().equals(pos)){
          MetaTiles.get(s).remove(i);
          addTile(type,pos);
          return;
        }
      }
    }
  }
  
  MetaTile getTile(PVector pos){
    for(String s:MetaTiles.keySet()){
      for(int i=0;i<MetaTiles.get(s).size();i++){
        if(MetaTiles.get(s).get(i).getPos().equals(pos)){
          return MetaTiles.get(s).get(i);
        }
      }
    }
    return null;
  }
  
  MetaTile[] getTiles(String type){
    if(MetaTiles.containsKey(type)){
      MetaTile[] rTiles=new MetaTile[MetaTiles.get(type).size()];
      for(int i=0;i<rTiles.length;i++){
        rTiles[i]=MetaTiles.get(type).get(i);
      }
      return rTiles;
    }else{
      return null;
    }
  }
  
  MetaTile[] getTiles(){
    int size=0;
    int count=0;
    for(String s:MetaTiles.keySet()){
      for(int i=0;i<MetaTiles.get(s).size();i++){
        size++;
      }
    }
    MetaTile[] rTiles=new MetaTile[size];
    for(String s:MetaTiles.keySet()){
      for(int i=0;i<MetaTiles.get(s).size();i++){
        rTiles[count]=MetaTiles.get(s).get(i);
        count++;
      }
    }
    return rTiles;
  }
}

class MetaTile{
  PVector pos;
  String Attribute="Spown";
  String val1="0";
  String val2="0";
  
  MetaTile(PVector pos){
    this.pos=pos;
  }
  
  MetaTile(String Att,PVector pos){
    Attribute=Att;
    this.pos=pos;
  }
  
  MetaTile(String Att,String v1,String v2,PVector pos){
    Attribute=Att;
    val1=v1;
    val2=v2;
    this.pos=pos;
  }
  
  void setAttribute(String s){
    Attribute=s;
  }
  
  void setPos(PVector p){
    pos=p;
  }
  
  void toPos(PVector p){
    pos=new PVector(floor(p.x/Fields.tileSize),floor(p.y/Fields.tileSize));
  }
  
  void setValue(String s){
    val1=s;
  }
  
  void setSubValue(String s){
    val2=s;
  }
  
  PVector getPos(){
    return new PVector(pos.x,pos.y);
  }
  
  String getValue(){
    return val1;
  }
  
  String getSubValue(){
    return val2;
  }
  
  String getAttribute(){
    return Attribute;
  }
  
  MetaTile get(PVector pos){
    return this.pos.equals(pos)?this:null;
  }
}
