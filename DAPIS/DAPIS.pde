import processing.serial.*;
import controlP5.*;
import java.io.*;
import java.util.*;

import processing.video.*;

//REPLACE the variable id with your custom path
String id = "MY/PATH";


String[] videoEvents = new String[0];

PGraphics lines;


int emotionCounter = 0;

Serial port;
PrintWriter output;

ControlP5 cp5;
Textarea valueFld;
Textlabel logFld;

color rectColor = color(255, 255, 0);

PFont font;
final int fntSize = 11;
final int menuBarW = 65;
color gray = color(0, 160, 100);

String[] data;
String fileName;

String portName;
int baudRate;
int[] baud = {9600, 14400, 19200, 28800, 38400, 57600, 115200, 210000, 250000, 256000,921600};

int itemSelected;

boolean debug = false;
int index = 0;
int counter = 0;
int count = 0;
int inByte = 0;
long longCounter = 0;

float yIn;
float x1, y1, x2, y2;
float x3, y3, x4, y4;

color BLUE = color(12, 16, 255);

boolean connected = false;
boolean showGraph = false;
boolean showText = false;

int[] y = new int[0];

boolean sync = false;
int[] dataBuff = new int[20]; 
int dataCounter = 0;
int value = 0;
color[] myCol;
String[] myData = new String[0];

int camRecCounter;
boolean stopRecord = false;

int divide[];
int center[];

int errCounter = 0;
boolean firstData = true; 
int keypad = 0;
void setup() {
  size(1200, 1000);


  center = new int[dataBuff.length];
  divide = new int[dataBuff.length];

  for(int i = 0; i < dataBuff.length; i++){
    center[i] = 2000;
    divide[i] = 1;
  }

  if (frame != null) {
    surface.setResizable(true);
  }
  background(BLUE);
  myCol = new color[9];
  myCol[0] = color(255);
  myCol[1] = color(0, 255, 0);
  myCol[2] = color(255, 0, 0);
  myCol[3] = color(255, 255, 0);
  myCol[4] = color(255, 0, 255);
  myCol[5] = color(0, 255, 255);
  myCol[6] = color(125, 255, 125);
  myCol[7] = color(255, 125, 125);
  myCol[7] = color(150);

  cp5 = new ControlP5(this);
  font = createFont("SourceCodePro-Regular.tif", fntSize);
  String[] ports = Serial.list();
  List p = Arrays.asList(ports);

  lines = createGraphics(width, height);

  cp5.addScrollableList("SerialPorts")
    .setPosition(10, 3)
    .setSize(230, 90)
    .setCaptionLabel("Serial Ports")
    .setBarHeight(18)
    .setItemHeight(18)
    .setFont(font)
    .addItems(p);

  List b = Arrays.asList("9600", "14400", "19200", "28800", "38400", "57600", "115200","230400", "250000","256000","921600");      
  cp5.addScrollableList("Baud")    
    .setPosition(250, 3)
    .setSize(60, 90)
    .setBarHeight(18)
    .setItemHeight(18)
    .setFont(font)
    .addItems(b); 

  cp5.addButton("Connect")
    .setPosition(320, 3)
    .setFont(font)
    .setSize(85, 19);

  cp5.addButton("Disconnect")
    .setPosition(320, 23)
    .setFont(font)
    .setSize(85, 19);

  cp5.addButton("Save")
    .setPosition(415, 3)
    .setFont(font)
    .setSize(70, 19)
    .setCaptionLabel("Save Data");

  cp5.addButton("Open")
    .setPosition(415, 23)
    .setFont(font)
    .setSize(70, 19)
    .setCaptionLabel("Open File");

  cp5.addButton("ScreenShot")
    .setPosition(495, 3)
    .setFont(font)
    .setSize(80, 19);

  cp5.addButton("ClrScrn")
    .setPosition(495, 23)
    .setFont(font)
    .setSize(80, 19)
    .setCaptionLabel("Clr Screen");

  cp5.addButton("Replay")
    .setPosition(585, 3)
    .setFont(font)
    .setSize(90, 19)
    .setCaptionLabel("Replay Data");

  cp5.addButton("ETrain")
    .setPosition(885, 3)
    .setFont(font)
    .setSize(90, 19)
    .setCaptionLabel("Emotion Train");

  cp5.addButton("BaseLine")
    .setPosition(885, 23)
    .setFont(font)
    .setSize(90, 19)
    .setCaptionLabel("Base Line");

  cp5.addButton("RescanPorts")
    .setPosition(585, 23)
    .setFont(font)
    .setSize(90, 19)
    .setCaptionLabel("Rescan Ports");

  cp5.addTextlabel("Label")
    .setText("Display:")
    .setPosition(680, 3)
    .setColorValue(255)
    .setFont(font);

  cp5.addRadioButton("Radio")
    .setPosition(685, 25)
    .setFont(font)
    .setSize(15, 15)
    .setItemsPerRow(3)
    .setSpacingColumn(34)
    .addItem("Graph", 0)
    .addItem("Text", 1)
    .setColorLabel(color(255))
    .activate(0);
  showGraph = true;

  valueFld = cp5.addTextarea("Value")
    .setPosition(780, 3)
    .setSize(50, menuBarW - 6)
    .setColorBackground(0)
    .setFont(font)
    .setLineHeight(14);

  logFld = cp5.addTextlabel("Log")
    .setPosition(320, 45)
    .setSize(360, 18)
    .setFont(font)
    .setLineHeight(14);

  cp5.addButton("Quit")
    .setPosition(width-60, 3)
    .setFont(font)
    .setSize(50, 19);

  StartCamtasia();

  myTime = millis();
}


long myTime = 0;
int loop = 0;
long infiniteLoop = 0;
PImage save;

boolean firstRecording=true;
void draw() {


  if (millis() - myTime > 1000) {
    if (connected) {
      valueFld.append(infiniteLoop+" cicle \n");
    }
    myTime = millis();
    loop = 0;
  }

  if (!inTraining) {
    stroke(0);
    //line(width-645, 70, width - 645, height);
    // **** Menu Bar **** // 
    fill(128);
    rect(0, 0, width-1, menuBarW);
    // **** Graph of data from serial connection **** //
    if (connected && showGraph) {
      if (count > width ) {
        count = 0;
        background(BLUE);
      }  
      if (count == 0) {
        x1 = count;
        y1 = yIn;
      }  
      if (count > 0) {
        x2 = count;
        y2 = yIn;
        //  println(y2);
        stroke(myCol[value]);

        line(x1, y1, x2, y2);
        x1 = x2;
        y1 = y2;
      } 
      count++;
    } else { 
      // **** Graph of saved file with comma separated values **** // 
      if (data != null) {
        if (index < data.length) {
          String[] pieces = split(data[index], ",");   
          if (counter > width) {
            counter = 0;
            background(BLUE);
          }
          if (counter == 0) {
            x3 = 0;
            y3 = height - float(pieces[0]);
          } 
          if (counter > 0) {
            // println("["+index+"] "+pieces[0]);   
            x4 = counter;
            y4 = height - float(pieces[0]);
            stroke(255);
            line(x3, y3, x4, y4);
            x3 = x4;
            y3 = y4;
          }
          index++;
          counter++;
        }
      }
    }
  } else {
    StartEmotionMirror();
    if (emotionCounter < emotions.length) {
      ShowImage(emotionCounter);
      if (CountDown()) {
        println("RECORD");
        Save();
        EmptyArray();
        delay(10000);
        SaveEmotion(emotionCounter);
        emotionCounter++;
      }
    } else {
      delay(500);
      inTraining = false;
      emotionCounter = 0;
      errCounter++;
      println("err number "+errCounter);
      ClrScrn();
    }
  }
  
  noStroke();
  fill(rectColor);
  rect(0,50,width,75);
  rect(0,height-75,width,75);
}

void ChangeGraph() {
  if (value < (dataBuff.length  / 2 )- 2) value++; 
  else value = 0;   
  ClrScrn();
  println(value);
}

// **** Byte data sent without frame markers **** //
// **** Commas added if data displayed and/or saved to file. **** //
void serialEvent (Serial port) {
  while (port.available()>0) {
    longCounter++;
    if (sync) {
      if (dataCounter < dataBuff.length) {
        Debug("fill");
        if (firstRecording) {
          
          for (int i = 0; i <30; i++) {
            println("#"); 
            firstRecording = false; 
            startingMillis = millis();
          }
        } else
          FillTheBuffer();
      } else {
        firstData = true;
        Debug("SetY");
        SetYValue();
      }
    } else {
      firstData = true;
      println("error on sample "+sample);
      println("error num " + errCounter);
      Debug("FindEnd", false);
      FindEndData();
    }
  }
}


boolean stop = false;
boolean canClose = false;




void Debug(String s) {
  if (debug) println(s);
}

void Debug(String s, boolean b) {
  if (b) println(s);
}

void ETrain() {
  if (connected) inTraining = true;
}

void BaseLine() {
  if (connected) {
    
  }
}


boolean inTraining = false;
void keyPressed() {
  println("keypressed");
  if (key == ' ') {
    ChangeGraph();
  }
  if (key == 's' || key == 'S') {
    stopRecord = !stopRecord;
    println("stop");
  }
  
  if (key == 'z'){
     keyPadPressed = 14; 
  }
  if (key == 'x'){
     keyPadPressed = 15; 
  }
  if (keyCode == UP){
    center[value] += 250;
    println("center value = " + center);
  }
  if (keyCode == DOWN){
    center[value] -=250;
    println("center value = " + center);
}
  if (keyCode == LEFT && divide[value] > 0.5){
    divide[value] -= 0.5;
        println("divide value = " + divide);
  }
  if (keyCode == RIGHT){
    divide[value] += 0.5;
        println("divide value = " + divide);
  }
}
