/*
  author:0x4C
*/

import processing.awt.*;
import processing.awt.PSurfaceAWT.*;

import java.awt.*;
import java.awt.event.*;

import javax.swing.*;
import javax.swing.event.*;

import java.util.concurrent.*;

import com.jogamp.newt.opengl.*;
import com.jogamp.newt.event.*;

Myself player;

ExecutorService exec=Executors.newCachedThreadPool();
Future<?> execFuture;
ParticleProcess particleTask=new ParticleProcess();

ComponentSet starts=new ComponentSet();
ComponentSet configs=new ComponentSet();

Fields field=new Fields();

PImage Map;
PImage Mask;
ArrayList<Particle>Particles=new ArrayList<Particle>();
ArrayList<String>PressedKey=new ArrayList<String>();
ArrayList<Bullet>eneBullets=new ArrayList<Bullet>();
ArrayList<Bullet>Bullets=new ArrayList<Bullet>();
ArrayList<Enemy>Enemies=new ArrayList<Enemy>();
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
static final String ShaderPath=".\\data\\shaders\\";

void setup(){
  size(1280,720,P2D);
  surface.setResizable(true);
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
      t=new PImage(width,height,PImage.ARGB,displayDensity());
    }
  });
  PFont font=createFont("SansSerif.plain",50);
  textFont(font);
  t=new PImage(width,height,PImage.ARGB,displayDensity());
  View=loadShader(ShaderPath+"View.glsl");
  colorInv=loadShader(ShaderPath+"ColorInv.glsl");
  blendMode(ADD);
  scroll=new PVector(0,0);
  pscreen=new PVector(width,height);
  pTime=System.currentTimeMillis();
  TileSize=field.tileSize;
}

void draw(){
  background(0);
  switch(scene){
    case 0:Menu();break;
    case 1:Field();break;
    case 2:Stage();break;
  }
  eventProcess();
  try{
    execFuture.get();
  }catch(InterruptedException|ExecutionException e){
  }catch(NullPointerException f){
  }
  printFPS();
  Shader();
  updatePreValue();
  updateFPS();
  TileSize=field.tileSize;
  println(System.currentTimeMillis()-pTime);
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

void Field(){
  
}

void Stage(){
  if(changeScene){
    field.loadMap("Field02.lfdf");
    player=new Myself();
    Enemies.add(new Turret(new PVector(300,300)));
  }
  field.displayMap();
  drawShape();
  updateShape();
}

void updateShape(){
  try{
  execFuture=exec.submit(particleTask);
  }catch(Exception e){
    e.printStackTrace();
  }
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

boolean qDist(PVector s,PVector e,float d){
  return ((s.x-e.x)*(s.x-e.x)+(s.y-e.y)*(s.y-e.y))<d*d;
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
  return new PVector(e.x-s.x,e.y-s.y);
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
  if (t1+0.00001<0||t1-0.00001>1||t2+0.00001<0||t2-0.00001>1) {
    return false;
  }
  return true;
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
