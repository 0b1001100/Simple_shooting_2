class Item{
  PImage image;
  protected String name="";
  String explanation="";
  int maxStack=99;
  
  Item(String name){
    this.name=name;
  }
  
  Item(int max,String name){
    maxStack=max;
    this.name=name;
  }
  
  String getName(){
    return name;
  }
}

class ItemTable{
  LinkedHashMap<String,Item>table;
  HashMap<String,Float>prob;
  HashMap<String,Integer>num;
  
  ItemTable(){
    table=new LinkedHashMap<String,Item>();
    prob=new HashMap<String,Float>();
    num=new HashMap<String,Integer>();
  }
  
  ItemTable(String[]names){
    table=new LinkedHashMap<String,Item>();
    num=new HashMap<String,Integer>();
    for(String s:names){
      table.put(s,new Item(s));
      num.put(s,0);
    }
    prob=new HashMap<String,Float>();
  }
  
  ItemTable(ArrayList<String>names){
    table=new LinkedHashMap<String,Item>();
    num=new HashMap<String,Integer>();
    for(String s:names){
      table.put(s,new Item(s));
      num.put(s,0);
    }
    prob=new HashMap<String,Float>();
  }
  
  ItemTable(Item[]items){
    table=new LinkedHashMap<String,Item>();
    num=new HashMap<String,Integer>();
    for(Item i:items){
      table.put(i.getName(),i);
      num.put(i.getName(),0);
    }
    prob=new HashMap<String,Float>();
  }
  
  void addItem(Item i){
    if(!table.containsKey(i.getName())){
      table.put(i.getName(),i);
      num.put(i.getName(),0);
    }
  }
  
  void addTable(Item i,float prob){
    if(!table.containsKey(i.getName())){
      table.put(i.getName(),i);
      num.put(i.getName(),0);
      this.prob.put(i.getName(),prob);
    }else{
      this.prob.put(i.getName(),prob);
    }
  }
  
  boolean addStorage(Item i){
    if(!table.containsKey(i.getName())){
      table.put(i.getName(),i);
      num.put(i.getName(),0);
      int n=num.get(i.getName())+1;
      if(n>i.maxStack)return false;
      num.put(i.getName(),max(0,n));
      return true;
    }else{
      int n=num.get(i.getName())+1;
      if(n>i.maxStack)return false;
      num.put(i.getName(),max(0,n));
      return true;
    }
  }
  
  boolean addStorage(Item i,int number){
    if(!table.containsKey(i.getName())){
      table.put(i.getName(),i);
      num.put(i.getName(),0);
      int n=num.get(i.getName())+number;
      if(n>i.maxStack)return false;
      num.put(i.getName(),max(0,n));
      return true;
    }else{
      int n=num.get(i.getName())+number;
      if(n>i.maxStack)return false;
      num.put(i.getName(),max(0,n));
      return true;
    }
  }
  
  int getNumber(Item i){
    if(table.containsKey(i.getName())){
      return num.get(i.getName());
    }else{
      return -1;
    }
  }
  
  Item getRandom(){
    HashMap<Item,doubleValue>vals=new HashMap<Item,doubleValue>();
    float offset=0;
    for(String s:prob.keySet()){
      vals.put(table.get(s),new doubleValue(offset,offset+prob.get(s)));
      offset+=prob.get(s);
    }
    float rand=random(0,offset);
    for(Item i:vals.keySet()){
      if(vals.get(i).min<=rand&rand<vals.get(i).max)return i;
    }
    return null;
  }
}

final class doubleValue{
  float min;
  float max;
  
  doubleValue(){
    
  }
  
  doubleValue(float min,float max){
    this.min=min;
    this.max=max;
  }
}
