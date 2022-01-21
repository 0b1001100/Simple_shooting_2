import java.util.concurrent.atomic.AtomicInteger;

class ParticleProcess implements Callable<String>{
  long pTime=0;
  
  ParticleProcess(){
    
  }
  
  synchronized String call(){pTime=System.currentTimeMillis();
    ArrayList<Particle>nextParticles=new ArrayList<Particle>();
    synchronized(Particles){
      for(Particle p:Particles){
        p.update();
        if(!p.isDead)nextParticles.add(p);
      }
      Particles=nextParticles;
    }
    println("sub",System.currentTimeMillis()-pTime);
    return "";
  }
}

class EnemyProcess implements Callable<String>{
  long pTime=0;
  
  EnemyProcess(){
    
  }
  
  synchronized String call(){pTime=System.currentTimeMillis();
    player.update();
    ArrayList<Enemy>nextEnemies=new ArrayList<Enemy>();
    synchronized(Enemies){
      for(Enemy e:Enemies){
        e.update();
        if(!e.isDead)nextEnemies.add(e);
      }
      Enemies=nextEnemies;
    }
    println("ene",System.currentTimeMillis()-pTime);
    return "";
  }
}

class BulletProcess implements Callable<String>{
  long pTime=0;
  
  BulletProcess(){
    
  }
  
  synchronized String call(){pTime=System.currentTimeMillis();
    ArrayList<Bullet>nextBullets=new ArrayList<Bullet>();
    synchronized(Bullets){
      for(Bullet b:Bullets){
        if(b.isDead)continue;
        b.update();
        if(!b.isDead)nextBullets.add(b);
      }
      Bullets=nextBullets;
    }
    ArrayList<Bullet>nextEneBullets=new ArrayList<Bullet>();
    synchronized(eneBullets){
      for(Bullet b:eneBullets){
        if(b.isDead)continue;
        b.update();
        if(!b.isDead)nextEneBullets.add(b);
      }
      eneBullets=nextEneBullets;
    }
    println("bul",System.currentTimeMillis()-pTime);
    return "";
  }
}

class LoadProcess implements Callable<Fields>{
  protected Fields f;
  protected ItemLoader i;
  protected String Path;
  protected boolean LoadItem=false;
  boolean done=false;
  AtomicInteger progress=new AtomicInteger(0);
  
  LoadProcess(Fields f,String Path,boolean Item){
    this.f=f;
    this.Path=Path;
    LoadItem=Item;
  }
  
  synchronized Fields call(){
    if(LoadItem){
      LoadItem();
      progress.set(43);
    }
    f.loadMap(Path);//load->file size(KB)*0.2ms parse->20ms
    progress.set(100);
    done=true;
    return f;
  }
  
  void LoadItem(){
    i=new ItemLoader(ResourcePath+"Item.json");
    MastarItemTable=i.getTable();
    i=new ItemLoader(ResourcePath+"Material.json");
    MastarMaterialTable=i.getTable();
  }
}
