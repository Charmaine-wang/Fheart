import processing.serial.*;
static final int PORT_INDEX = 3, BAUDS = 115200;

String myString = "";
int sum;
float[] history = new float[1];
float mappedValue;
float procentageValue;
String str;
float prevX = 0;
int fartBubble = 0;
int windowWidth = 1280;
int windowHeight = 800;
int screenWidth = 880;
int screenHeight = 480;
int aFarts = 0;
int bFarts = 0;
int tFarts = 0;
int fartsAverted = 0;
float speed = 0;
boolean fartZone = false;
float circleGrowth = 0;

Bubble boringBubble;
Bubble awkwardBubble;
Bubble tenseBubble;
PImage frame;
PImage screen;
void setup() {
  frame = loadImage("MonitorFrame.png");
  screen = loadImage("MonitorScreen.png");
  frameRate(50);
  size(1280 , 800);
  noLoop();
  final String[] ports = Serial.list();
  fill(255);
  new Serial(this, ports[PORT_INDEX], BAUDS).bufferUntil(ENTER);
  boringBubble = new Bubble(screenWidth/2 - 120, -screenHeight/2 + 40, "B", 800);
  tenseBubble = new Bubble(screenWidth/2 - 120,  -screenHeight/2 + 90, "T", 50);
  awkwardBubble = new Bubble(screenWidth/2 - 120, -screenHeight/2 + 140, "A", 350);
}
 
void draw() {
  
  background(0);
  stroke(150);
  translate(windowWidth/2, windowHeight/2);
  
  // rects all over the place
  line(screenWidth/2-150, -screenHeight/2-20, screenWidth/2-150, -20);
  line(-screenWidth/2+100, -screenHeight/2-20, -screenWidth/2+100, -20);
  line(-screenWidth/2+100, -screenHeight/2+15, screenWidth/2-150, -screenHeight/2+15);
  //rect(screenWidth/2-150,-screenHeight/2-20,140,screenHeight/2-20);
  




  // GRIDS AND SUCH
  textSize(24);
  fill(150, 250, 0);
  rect(-screenWidth/2+100, -screenHeight/2-20, 70, 35);
  fill(0, 255, 255);
  rect(-screenWidth/2+170, -screenHeight/2-20, 70, 35);
  fill(255, 255, 0);
  rect(-screenWidth/2+240, -screenHeight/2-20, 70, 35);
  fill(0);
  textAlign(CENTER);
  text(bFarts, -screenWidth/2+ 135, -screenHeight/2+6);
  text(tFarts, -screenWidth/2+ 205, -screenHeight/2+6);
  text(aFarts, -screenWidth/2+ 275, -screenHeight/2+6);
  
  // 
  fill(255);
  textAlign(LEFT);
  text("SCANNING PROXIMITY AREA", -screenWidth/2+ 350, -screenHeight/2+6);
  fill(150, 250, 0);
  noStroke();
  circle(screenWidth/2- 175, -screenHeight/2-1, 7);
  stroke(150, 250, 0);
  strokeWeight(3);
  noFill();
  if (circleGrowth > 27){
    circleGrowth = 0;
  }
  circleGrowth += 0.3;
  circle(screenWidth/2- 175, -screenHeight/2-1, circleGrowth);
  strokeWeight(2);
  
  noFill();
  stroke(150,255,0);
  // fartzone (text + line)
  push();
  stroke(255);
  line(-screenWidth/2, -20, screenWidth/2, -20);
  textSize(20);
  fill(255);
  textAlign(LEFT);
  
  text("FartZone", -screenWidth/2 + 10, -34);
  pop();
  int rectWidth = 5;
  int rectHeight = 35;
  noStroke();

  
  
  for (int i = 0; i < screenWidth; i+=rectWidth+2) {
    fill(255, 150, 0, 100);
    rect(-screenWidth/2 + i, -20 - rectHeight, rectWidth, rectHeight);
    fill(150, 255, 0, 100);
    rect(-screenWidth/2 + i, -20, rectWidth, rectHeight);
    fill(255, 255, 0, 100);
    rect(-screenWidth/2 + i, -20 + rectHeight, rectWidth, rectHeight);
    
  }
  
  // Playing fart
  if (myString.contains("track")) {
    str = "";
    println(myString);
    if (myString.contains("002")) { aFarts++; str = "AWKWARD/SILENCE/DETECTED:release";}
    if (myString.contains("005")) { tFarts++; str = "TENSION/TENSE/DETECTED:release";}
    if (myString.contains("003")) { bFarts++; str = "BORING/DETECTED:release";}
    textAlign(CENTER);
    textSize(20);
    text(str, 0, -200);
  }
  if (myString.contains("fartzone")) {
    println(myString);
    
    fartZone = true;
  }
  
  if (myString.contains("averted")){
    fartsAverted++;
  }
    if (myString.contains("exit")){
    fartZone = false;
    
    println(myString);
  }
  if (myString.contains("reset")){
    println(myString);
    fartZone = false;
    awkwardBubble.reset();
    tenseBubble.reset();
    boringBubble.reset();
  }
  
  sum = int(myString);
  
  if (sum < -10) { sum = 0;}
  
  if (sum > 100 && fartZone){
    tenseBubble.grow();
  }
 
  if (fartZone){
    boringBubble.deflate();
    awkwardBubble.grow();
  }else{
    if(sum < 10 && sum > 0) {
    boringBubble.grow();
   }    
    awkwardBubble.reset();
    tenseBubble.reset();
  }
  
  mappedValue = map(sum, 0, 350, -100, 100 );
  procentageValue = map(sum, 0, 350, 0, 1);
  history = append(history, mappedValue);
  
  //Display Bubbles
  fill(150, 250, 0);
  stroke(150, 250, 0);
  boringBubble.show(bFarts);
  fill(0, 255, 255);
  stroke(0, 255, 255);
  awkwardBubble.show(aFarts);
  fill(255, 255, 0);
  stroke(255, 255, 0);
  tenseBubble.show(tFarts);
  
  // Volume + Bar
  push();
  textSize(12);
  textLeading(12);
  fill(255);
  textAlign(LEFT);
  text("V\nO\nL\nU\nM\nE", -screenWidth/2 + 25, -250);
  stroke(150, 255*procentageValue, 0);
  fill(150, 255*procentageValue, 0);
  rect(-screenWidth/2 + 13, -190, 10, (-60*procentageValue)-5);
  fill(0,255,0);
  textSize(24);
  text("F/AV:" + str(fartsAverted), -screenWidth/2+15, -150);
  pop();
 
  // Drawing the graph
  push();
  translate(-history.length * 3 + 580,0);
  stroke(150, 255, 0);
  strokeWeight(2);
  beginShape(); 
  for (int i = 0; i < history.length; i++) {
    prevX = -history[i]*2;
    vertex((i-50) * 3, -history[i]*2 -20);
  } 
  endShape();
  stroke(0,255,255);
  beginShape(); 
  for (int i = 0; i < history.length; i++) {
    if (i%5 == 0){
    vertex((i-25) * 3, (-history[i]) + 20);
    }
  } 
  endShape();
  stroke(255,50,0);
    beginShape(); 
  for (int i = 0; i < history.length; i++) {
    if (i%2 == 0){
    vertex((i) * 3, ((history[i]) +230) * 0.5);
    }
  } 
  endShape();
  pop();
  image(frame,-windowWidth/2 ,-windowHeight/2);
  image(screen, -windowWidth/2 ,-windowHeight/2); 
  
  
  
}
 
void serialEvent(final Serial s) {
  myString = s.readString().trim();
  redraw = true;
}


class Bubble {
  int x, y, textSize = 20;
  float maxSize = 40;
  float growth;
  float size = 1;
  String name;
  
  Bubble(int x, int y, String name, float time){
    this.x = x;
    this.y = y;
    this.name = name;
    this.growth = this.maxSize/time;
  }
 
  void show(int count){
    rect(this.x, this.y + 10, 20, -this.size);
    noFill();
    rect(this.x, this.y + 10, 20, -this.maxSize);
    fill(255);
    textAlign(LEFT);
    textSize(this.textSize);
    text(this.name, this.x +80, this.y);
    textSize(this.textSize-7);
    textAlign(RIGHT);
    text(this.size, this.x +75, this.y);
    textSize(this.textSize-3);
    textAlign(LEFT);
    text(count, this.x -20, this.y);
    
    
    noFill();
  }
  void grow() {
    this.size += this.growth;
    if (this.size > this.maxSize){
      this.size = this.maxSize;
    }
  }
  
  void deflate() {
    if (this.size > 0){
      this.size -= 1.5;
    }
  }
  void reset(){
    this.size = 1;
  }
}
