import java.math.*;

class Status{
  protected BigDecimal status;
  protected BigDecimal maxStatus;
  protected BigDecimal resetStatus;
  protected BigDecimal minStatus=new BigDecimal(0);
  
  Status(float s){
    status=new BigDecimal(s);
    maxStatus=new BigDecimal(s);
    resetStatus=new BigDecimal(s);
    maxStatus=isMin(maxStatus);
    status=isMin(isMax(status));
    resetStatus=isMin(isMax(resetStatus));
  }
  
  Status(float s,float max,float reset){
    status=new BigDecimal(s);
    maxStatus=new BigDecimal(max);
    resetStatus=new BigDecimal(reset);
    maxStatus=isMin(maxStatus);
    status=isMin(isMax(status));
    resetStatus=isMin(isMax(resetStatus));
  }
  
  void add(float s){
    status=status.add(new BigDecimal(s));
    status=isMin(isMax(status));
  }
  
  void addMax(float s){
    maxStatus=maxStatus.add(new BigDecimal(s));
    maxStatus=isMin(maxStatus);
  }
  
  void addReset(float s){
    resetStatus=resetStatus.add(new BigDecimal(s));
    resetStatus=isMin(isMax(resetStatus));
  }
  
  void addMin(float s){
    minStatus=minStatus.add(new BigDecimal(s));
    minStatus=isMax(minStatus);
  }
  
  void sub(float s){
    status=status.subtract(new BigDecimal(s));
    status=isMin(isMax(status));
  }
  
  void subMax(float s){
    maxStatus=maxStatus.subtract(new BigDecimal(s));
    maxStatus=isMin(maxStatus);
  }
  
  void subReset(float s){
    resetStatus=resetStatus.subtract(new BigDecimal(s));
    resetStatus=isMin(isMax(resetStatus));
  }
  
  void subMin(float s){
    minStatus=minStatus.subtract(new BigDecimal(s));
    minStatus=isMax(minStatus);
  }
  
  void set(float s){
    status=new BigDecimal(s);
    status=isMin(isMax(status));
  }
  
  void setMax(float s){
    maxStatus=new BigDecimal(s);
    maxStatus=isMin(maxStatus);
  }
  
  void setReset(float s){
    resetStatus=new BigDecimal(s);
    resetStatus=isMin(isMax(resetStatus));
  }
  
  void setMin(float s){
    minStatus=new BigDecimal(s);
    minStatus=isMax(minStatus);
  }
  
  BigDecimal get(){
    return new BigDecimal(status.toString());
  }
  
  BigDecimal getMax(){
    return new BigDecimal(maxStatus.toString());
  }
  
  BigDecimal getReset(){
    return new BigDecimal(resetStatus.toString());
  }
  
  BigDecimal getMin(){
    return new BigDecimal(minStatus.toString());
  }
  
  float getPercentage(){
    return !status.equals(new BigDecimal(0)) ? status.divide(maxStatus).floatValue() : 0;
  }
  
  void reset(){
    status=new BigDecimal(resetStatus.toString());
  }
  
  private BigDecimal isMax(BigDecimal b){
    return new BigDecimal(maxStatus.min(b).toString());
  }
  
  private BigDecimal isMin(BigDecimal b){
    return new BigDecimal(minStatus.max(b).toString());
  }
}

class heatCapacity extends Status{
  boolean overHeat=false;
  
  heatCapacity(float h){
    super(h);
  }
  
  heatCapacity(float h,float max,float reset){
    super(h,max,reset);
  }
  
  float getPercentage(){
    if(status.compareTo(maxStatus)==0)overHeat=true;
    if(status.compareTo(minStatus)==0)overHeat=false;
    return !status.equals(new BigDecimal(0)) ? status.divide(maxStatus).floatValue() : 0;
  }
}
