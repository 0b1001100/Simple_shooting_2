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

class pixelProcess implements Callable<String>{
  
  pixelProcess(){
    
  }
  
  String call(){
    loadPixels();
    t.pixels=pixels;
    t.updatePixels();
    return "";
  }
}
