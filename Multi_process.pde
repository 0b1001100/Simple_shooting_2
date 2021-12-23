class ParticleProcess implements Callable<String>{
  boolean end=true;
  long pTime=0;
  
  ParticleProcess(){
    
  }
  
  String call(){pTime=System.currentTimeMillis();
    player.update();
    end=false;
    ArrayList<Bullet>nextBullets=new ArrayList<Bullet>();
    for(Bullet b:Bullets){
      b.update();
      if(!b.isDead)nextBullets.add(b);
    }
    Bullets=nextBullets;
    ArrayList<Particle>nextParticles=new ArrayList<Particle>();
    for(Particle p:Particles){
      p.update();
      if(!p.isDead)nextParticles.add(p);
    }
    Particles=nextParticles;
    end=true;println("sub",System.currentTimeMillis()-pTime);
    return "";
  }
  
  boolean isEnd(){
    return end;
  }
}
