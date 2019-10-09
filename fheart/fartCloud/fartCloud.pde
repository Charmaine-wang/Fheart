import processing.serial.*;
static final int PORT_INDEX = 3, BAUDS = 115200;

String myString = "";
int sum;
float[] history = new float[1];
float mappedValue;
String str;
float prevX = 0;
int fartBubble = 0;
int windowWidth = 640;
int windowHeight = windowWidth;
int lAlign = -windowWidth;
int cAlign = -windowWidth / 2;
float speed = 0;

boolean fartZone = false;

Bubble boringBubble;
Bubble awkwardBubble;
Bubble tenseBubble;

void setup() {
  size(640, 640);
  noLoop();
  final String[] ports = Serial.list();
  fill(255);
  new Serial(this, ports[PORT_INDEX], BAUDS).bufferUntil(ENTER);
  boringBubble = new Bubble(-500, 270, "Boring", 600);
  tenseBubble = new Bubble(-300, 270, "Tense", 28);
  awkwardBubble = new Bubble(-100, 270, "Awkward", 600);
}
 
void draw() {
  str = "";
  background(243);
  translate(windowWidth, windowHeight/2);
  noFill();
  strokeWeight(2);
  
  push();
  stroke(0);
  line(lAlign + 95, 0, 0, 0);
  textSize(20);
  fill(0);
  textAlign(LEFT);
  text("FartZone", lAlign+5, 6);
  pop();
  
  if (!myString.contains("track")) {
    sum = int(myString);
    //Integer.parseInt(myString);
  }
  
  if (myString.contains("track")) {
    
    if (myString.contains("002")) { stroke(255,0,0); println(awkwardBubble.size); str = "Awkward";}
    if (myString.contains("005")) { stroke(0,255,0); println(tenseBubble.size); str = "Tense";}
    if (myString.contains("003")) { stroke(0,0,255); boringBubble.reset(); str = "Boring";}
    text(str, cAlign, -200);
  }
  if (myString.contains("Exit")){
    fartZone = false;
  }
  if (sum < 0) { sum = 0;}
  if (sum > 200) {
    println("Entering FartZone");
    fartZone = true;
    
  }
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
    awkwardBubble.deflate();
    tenseBubble.deflate();
  }
  
  
  

  mappedValue = map(sum, 0, 350, -100, 100 );
     
  

  history = append(history, mappedValue); 
  
  boringBubble.show();
  awkwardBubble.show();
  tenseBubble.show();
  
  
  // Drawing the graph
  translate(-history.length,0);
  beginShape(); 
  for (int i = 0; i < history.length; i++) {
    prevX = -history[i]*2;
    vertex(i-50, -history[i]*2);
  } 
  endShape();
  
  
  
  
    
  
}

void serialEvent(final Serial s) {
  myString = s.readString().trim();
  redraw = true;
}


class Bubble {
  int x, y, textSize = 20;
  float maxSize = 50;
  float growth;
  float size = 1;
  String name;
  
  Bubble(int x, int y, String name, float time){
    this.x = x;
    this.y = y;
    this.name = name;
    this.growth = this.maxSize/time;
  }
 
  void show(){
    textAlign(CENTER);
    textSize(this.textSize);
    text(this.name, this.x, this.y-40);
    circle(this.x, this.y, this.size);
  }
  void grow() {
    this.size += this.growth;
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
