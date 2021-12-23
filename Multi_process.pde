class ParticleProcess implements Callable<String>{
  long pTime=0;
  
  ParticleProcess(){
    
  }
  
  String call(){pTime=System.currentTimeMillis();
    player.update();
    for(Enemy e:Enemies){
      e.update();
    }
    ArrayList<Bullet>nextBullets=new ArrayList<Bullet>();
    for(Bullet b:Bullets){
      b.update();
      if(!b.isDead)nextBullets.add(b);
    }
    ArrayList<Bullet>nextEneBullets=new ArrayList<Bullet>();
    for(Bullet b:eneBullets){
      b.update();
      if(!b.isDead)nextEneBullets.add(b);
    }
    eneBullets=nextEneBullets;
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
