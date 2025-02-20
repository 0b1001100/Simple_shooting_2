/*
  author : 0x4C
  LICENSE : GNU General Public License v3.0
*/

import processing.awt.*;
import processing.awt.PSurfaceAWT.*;

import java.awt.*;
import java.awt.event.*;

import java.nio.FloatBuffer;

import javax.swing.*;
import javax.swing.event.*;

import java.util.*;
import java.util.concurrent.*;

import com.jogamp.newt.opengl.*;
import com.jogamp.newt.event.*;

Simple_shooting_2 CopyApplet=this;

GameProcess main;

Myself player;

ExecutorService exec=Executors.newCachedThreadPool();
Future<Fields> loadFuture;
Future<?> particleFuture;
Future<?> enemyFuture;
Future<?> bulletFuture;

LoadProcess loadTask;
ParticleProcess particleTask=new ParticleProcess();
EnemyProcess enemyTask=new EnemyProcess();
BulletProcess bulletTask=new BulletProcess();

ComponentSet starts=new ComponentSet();
ComponentSet configs=new ComponentSet();
ComponentSet loads=new ComponentSet();

Fields field=new Fields();

ItemTable MastarTable;

PImage Map;
PImage Mask;
java.util.List<Particle>Particles=Collections.synchronizedList(new ArrayList<Particle>());
java.util.List<Bullet>eneBullets=Collections.synchronizedList(new ArrayList<Bullet>());
java.util.List<Bullet>Bullets=Collections.synchronizedList(new ArrayList<Bullet>());
java.util.List<Enemy>Enemies=Collections.synchronizedList(new ArrayList<Enemy>());
ArrayList<String>PressedKey=new ArrayList<String>();
ArrayList<Long>Times=new ArrayList<Long>();
PVector scroll;
PVector localMouse;
PVector pscreen;
PShader colorInv;
PShader View;
boolean pmousePress=false;
boolean mousePress=false;
boolean pkeyPress=false;
boolean keyPress=false;
boolean changeScene=true;
boolean ColorInv=false;
String nowPressedKey;
String nowMenu="Main";
String pMenu="Main";
float vectorMagnification=1;
long pTime=0;
int TileSize;
int nowPressedKeyCode;
int ModifierKey=0;
int dimension=0;
int pscene=0;
int scene=0;
int menu=0;

static final String UIPath=".\\data\\images\\UI\\";
static final String ButtonPath=".\\data\\images\\Button\\";
static final String MapPath=".\\data\\maps\\";
static final String ResourcePath=".\\data\\resources\\";
static final String ShaderPath=".\\data\\shaders\\";

void setup(){
  size(1280,720,P2D);
  ((GLWindow)surface.getNative()).addWindowListener(new com.jogamp.newt.event.WindowListener(){
    void windowDestroyed(com.jogamp.newt.event.WindowEvent e){}
    
    void windowDestroyNotify(com.jogamp.newt.event.WindowEvent e){}
    
    void windowGainedFocus(com.jogamp.newt.event.WindowEvent e){}
    
    void windowLostFocus(com.jogamp.newt.event.WindowEvent e){}
    
    void  windowMoved(com.jogamp.newt.event.WindowEvent e){}
    
    void windowRepaint(WindowUpdateEvent e){}
    
    @Override
    void windowResized(com.jogamp.newt.event.WindowEvent e){
      GLWindow w=(GLWindow)surface.getNative();
      pscreen.sub(w.getWidth(),w.getHeight()).div(2);
      scroll.sub(pscreen);
      pscreen=new PVector(w.getWidth(),w.getHeight());
    }
  });
  PFont font=createFont("SansSerif.plain",15);
  textFont(font);
  View=loadShader(ShaderPath+"View.glsl");
  colorInv=loadShader(ShaderPath+"ColorInv.glsl");
  blendMode(ADD);
  scroll=new PVector(0,0);
  pscreen=new PVector(width,height);
  pTime=System.currentTimeMillis();
  TileSize=field.tileSize;
}

void draw(){println((Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory())/1024/1024+"MB",player!=null?player.Speed:0);
  switch(scene){
    case 0:Menu();break;
    case 1:Load();break;
    case 2:Field();break;
  }
  eventProcess();
  try{
    enemyFuture.get();
    bulletFuture.get();
    particleFuture.get();
  }catch(ConcurrentModificationException e){
    e.printStackTrace();
  }catch(InterruptedException|ExecutionException f){
  }catch(NullPointerException g){
  }
  printFPS();
  Shader();
  updatePreValue();
  updateFPS();
  TileSize=field.tileSize;
  println(System.currentTimeMillis()-pTime);
}

void stop(){
  exec.shutdownNow();
}

void eventProcess(){
  if(!pmousePress&&mousePressed){
    mousePress=true;
  }else{
    mousePress=false;
  }
  if(!pkeyPress&&keyPressed){
    keyPress=true;
  }else{
    keyPress=false;
  }
  if(scene!=pscene){
    changeScene=true;
  }else if(!nowMenu.equals(pMenu)){
    changeScene=true;
  }else{
    changeScene=false;
  }
}

void updateFPS(){
  Times.add(System.currentTimeMillis()-pTime);
  while(Times.size()>60){
    Times.remove(0);
  }
  pTime=System.currentTimeMillis();
  vectorMagnification=60f/(1000f/Times.get(Times.size()-1));println(vectorMagnification);
}

void updatePreValue(){
  pmousePress=mousePressed;
  pkeyPress=keyPressed;
  pscene=scene;
  pMenu=nowMenu;
}

void Load(){
  if(changeScene){
    loadTask=new LoadProcess(field,"largeField.lfdf",true);
    loadFuture=exec.submit(loadTask);
    ProgressBar loadp=new ProgressBar();
    loadp.setBounds(width-205,height-20,200,12);
    loadp.setProgress(loadTask.progress);
    ProgressBar loadup=new ProgressBar();
    loadup.setBounds(width-30,30,35,35);
    loadup.isUnknown(true);
    loads.add(loadp);
    loads.add(loadup);
  }
  if(loadTask.done){
    try{
    field=loadFuture.get();
    }catch(ExecutionException|InterruptedException e){
    }
    scene=2;
  }else{
    background(0);
    fill(250);
    stroke(250);
    textAlign(RIGHT);
    textSize(15);
    text(loadTask.progress.intValue()+"%  Loading...",width-5,height-31);
    loads.display();
  }
}

void Field(){
  if(changeScene){
    main=new GameProcess();
  }
  main.process();
}

boolean onMouse(float x,float y,float dx,float dy){
  return x<=mouseX&mouseX<=x+dx&y<=mouseY&mouseY<=y+dy;
}

PVector Project(float winX, float winY){
  PMatrix3D mat = getMatrixLocalToWindow();
  
  float[] in = {winX, winY, 1.0f, 1.0f};
  float[] out = new float[4];
  mat.mult(in, out);  // Do not use PMatrix3D.mult(PVector, PVector)
  
  if (out[3] == 0 ) {
    return null;
  }
  
  PVector result = new PVector(out[0]/out[3], out[1]/out[3], out[2]/out[3]);  
  return result;
}

PVector unProject(float winX, float winY) {
  PMatrix3D mat = getMatrixLocalToWindow();  
  mat.invert();
  
  float[] in = {winX, winY, 1.0f, 1.0f};
  float[] out = new float[4];
  mat.mult(in, out);  // Do not use PMatrix3D.mult(PVector, PVector)
  
  if (out[3] == 0 ) {
    return null;
  }
  
  PVector result = new PVector(out[0]/out[3], out[1]/out[3], out[2]/out[3]);  
  return result;
}

PMatrix3D getMatrixLocalToWindow() {
  PMatrix3D projection = ((PGraphics2D)g).projection; // プロジェクション行列
  PMatrix3D modelview = ((PGraphics2D)g).modelview;   // モデルビュー行列
  
  // ビューポート変換行列
  PMatrix3D viewport = new PMatrix3D();
  viewport.m00 = viewport.m03 = width/2;
  viewport.m11 = -height/2;
  viewport.m13 =  height/2;

  // ローカル座標系からウィンドウ座標系への変換行列を計算  
  viewport.apply(projection);
  viewport.apply(modelview);
  return viewport;
}

float Sigmoid(float t){
  return 1f/(1+pow(2.7182818,-t));
}

float ESigmoid(float t){
  return pow(2.718281828,5-t)/pow(pow(2.718281828,5-t)+1,2);
}

int sign(float f){
  return f==0?0:f>0?1:-1;
}

float dist(PVector a,PVector b){
  return dist(a.x,a.y,b.x,b.y);
}

boolean qDist(PVector s,PVector e,float d){
  return ((s.x-e.x)*(s.x-e.x)+(s.y-e.y)*(s.y-e.y))<=d*d;
}

boolean qDist(PVector s1,PVector e1,PVector s2,PVector e2){
  return ((s1.x-e1.x)*(s1.x-e1.x)+(s1.y-e1.y)*(s1.y-e1.y))<=((s2.x-e2.x)*(s2.x-e2.x)+(s2.y-e2.y)*(s2.y-e2.y));
}

float cross(PVector v1,PVector v2){
  return v1.x*v2.y-v2.x*v1.y;
}

float dot(PVector v1,PVector v2){
  return v1.x*v2.x+v1.y*v2.y;
}

PVector normalize(PVector s,PVector e){
  float f=s.dist(e);
  return new PVector((e.x-s.x)/f,(e.y-s.y)/f);
}

PVector normalize(PVector v){
  float f=sqrt(sq(v.x)+sq(v.y));
  return new PVector(v.x/f,v.y/f);
}

PVector createVector(PVector s,PVector e){
  return e.copy().sub(s);
}

boolean SegmentCollision(PVector s1,PVector v1,PVector s2,PVector v2){
  PVector v=new PVector(s2.x-s1.x,s2.y-s1.y);
  float crs_v1_v2=cross(v1,v2);
  if(crs_v1_v2==0){
    return false;
  }
  float crs_v_v1=cross(v,v1);
  float crs_v_v2=cross(v,v2);
  float t1 = crs_v_v2/crs_v1_v2;
  float t2 = crs_v_v1/crs_v1_v2;
  if (t1+0.000000000001<0||t1-0.000000000001>1||t2+0.000000000001<0||t2-0.000000000001>1) {
    return false;
  }
  return true;
}

boolean LineCollision(PVector s1,PVector v1,PVector l2,PVector v2){
  PVector v=new PVector(l2.x-s1.x,l2.y-s1.y);
  float crs_v1_v2=cross(v1,v2);
  if(crs_v1_v2==0){
    return false;
  }
  float t=cross(v,v1);
  if (t+0.00001<0|1<t-0.00001) {
    return false;
  }
  return true;
}

PVector SegmentCrossPoint(PVector s1,PVector v1,PVector s2,PVector v2){
  PVector v=new PVector(s2.x-s1.x,s2.y-s1.y);
  float crs_v1_v2=cross(v1,v2);
  if(crs_v1_v2==0){
    return null;
  }
  float crs_v_v1=cross(v,v1);
  float crs_v_v2=cross(v,v2);
  float t1 = crs_v_v2/crs_v1_v2;
  float t2 = crs_v_v1/crs_v1_v2;
  if (t1+0.000000000001<0||t1-0.000000000001>1||t2+0.000000000001<0||t2-0.000000000001>1) {
    return null;
  }
  return s1.add(v1.copy().mult(t1));
}

PVector LineCrossPoint(PVector s1,PVector v1,PVector l2,PVector v2){
  PVector v=new PVector(l2.x-s1.x,l2.y-s1.y);
  float crs_v1_v2=cross(v1,v2);
  if(crs_v1_v2==0){
    return null;
  }
  float t=cross(v,v1);
  if (t+0.000000000001<0||t-0.000000000001>1) {
    return null;
  }
  return s1.add(v1.copy().mult(t));
}

color toColor(Color c){
  return color(c.getRed(),c.getGreen(),c.getBlue(),c.getAlpha());
}

color toRGB(Color c){
  return color(c.getRed(),c.getGreen(),c.getBlue(),255);
}

void keyPressed(processing.event.KeyEvent e){
  ModifierKey=e.getKeyCode();
  PressedKey.add(str(key));
  nowPressedKey=str(key);
  nowPressedKeyCode=keyCode;
}

void keyReleased(processing.event.KeyEvent e){
  ModifierKey=-1;
  PressedKey.remove(str(key));
}
