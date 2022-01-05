class ParticleProcess implements Callable<String>{
  long pTime=0;
  
  ParticleProcess(){
    
  }
  
  String call(){pTime=System.currentTimeMillis();
    ArrayList<Particle>nextParticles=new ArrayList<Particle>();
    for(Particle p:Particles){
      p.update();
      if(!p.isDead)nextParticles.add(p);
    }
    Particles=nextParticles;
    println("sub",System.currentTimeMillis()-pTime);
    return "";
  }
}

class EnemyProcess implements Callable<String>{
  long pTime=0;
  
  EnemyProcess(){
    
  }
  
  String call(){pTime=System.currentTimeMillis();
    player.update();
    ArrayList<Enemy>nextEnemies=new ArrayList<Enemy>();
    for(Enemy e:Enemies){
      e.update();
      if(!e.isDead)nextEnemies.add(e);
    }
    Enemies=nextEnemies;
    ArrayList<Bullet>nextBullets=new ArrayList<Bullet>();
    for(Bullet b:Bullets){
      if(b.isDead)continue;
      b.update();
      if(!b.isDead)nextBullets.add(b);
    }
    Bullets=nextBullets;
    ArrayList<Bullet>nextEneBullets=new ArrayList<Bullet>();
    for(Bullet b:eneBullets){
      if(b.isDead)continue;
      b.update();
      if(!b.isDead)nextEneBullets.add(b);
    }
    eneBullets=nextEneBullets;
    println("ene",System.currentTimeMillis()-pTime);
    return "";
  }
  
  String call(int start,int end){
    if(start==0)player.update();
    int E=start;
    for(int i=start;E<end+1;i++){
      Enemies.get(i).update();
      if(Enemies.get(i).isDead){
        Enemies.remove(i);
        i--;
      }
      E++;
    }
    int B=start;
    for(int i=start;B<end+1;i++){
      if(Bullets.get(i).isDead){
        B++;
        continue;
      }
      Bullets.get(i).update();
      if(Bullets.get(i).isDead){
        Bullets.remove(i);
        i--;
      }
      B++;
    }
    int EB=start;
    for(int i=start;EB<end+1;i++){
      if(eneBullets.get(i).isDead){
        EB++;
        continue;
      }
      eneBullets.get(i).update();
      if(eneBullets.get(i).isDead){
        eneBullets.remove(i);
        i--;
      }
      EB++;
    }
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
