import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;
import processing.video.*;

String id = "12t";
String fileName = "12.mp4";


//CONTROLLER VARIABLES
ControlIO control;
Configuration config;
ControlDevice gpad;

float slider1;
float slider2;
float videoPos;

boolean reset_s;
boolean ppy;
boolean ppa;
boolean finish;
PImage manikin;

boolean useGamepad = true;

boolean isInPause;

float startingValenceValue;
float startingArousalValue;
//LABEL MANIKIN: http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0148037

//MOVIE VARIABLES
Movie movie;
int frame = 60;
int nFrames;

int frameCounter;

int[] valenceBuff;
int[] arousalBuff;

int[] valenceBuffTemp;
int[] arousalBuffTemp;

PrintWriter output;


int barY = 100;
int barX = 20;
int r;
int g;
int b;

int[] gameStatus;

int yellowPix = 10;
boolean findYellow = false;

void setup() {
  size(1800, 900);
  frameRate(frame);
  //SPACES
  fill(0, 0, 255);
  rect(0, 0, width, height-200);
  VideoSetup();
  manikin = loadImage("ArousalValenceScheme.png");
  SetValenceArousalSlider();

  frameCounter = 0;

  //Control setup
  if (useGamepad) {
    control = ControlIO.getInstance(this);
    gpad = control.getMatchedDevice("slider2");
    if (gpad==null) {
      println("No device configured");
      System.exit(-1);
    }
  }





  //Video setup

  smooth(20);
  valenceBuff = new int[nFrames];
  arousalBuff = new int[nFrames];

  gameStatus = new int[nFrames];

  valenceBuffTemp = new int[1000];
  arousalBuffTemp = new int[1000];

  for (int i = 0; i < nFrames; i++) {
    valenceBuff[i] = -1;
    arousalBuff[i] = -1;
  }

  for (int i = 0; i < valenceBuffTemp.length; i++) {
    valenceBuffTemp[i] = -1;
    arousalBuffTemp[i] = -1;
  } 
  arousalBuff[0] = 50;
  valenceBuff[0] = 50;
  startingValenceValue = 50;
  startingArousalValue = 50;
}


void VideoSetup() {
  movie = new Movie(this, fileName);
  movie.play();

  nFrames = (int) (frame * movie.duration());
  // println(frame * movie.duration());
  movie.pause();
  isInPause= true;
}

int oldPosition = 0;

void movieEvent(Movie m) {
  m.read();
  frameCounter++;
  println("1");
  valenceBuff[frameCounter] = (int)startingValenceValue;
  arousalBuff[frameCounter] = (int)startingArousalValue;
  println("2");
  int pixelColor = movie.pixels[yellowPix];
  r = (pixelColor >> 16) & 0xff;
  g = (pixelColor >> 8) & 0xff;
  b = pixelColor & 0xff;
  println("3");
  if (frameCounter < gameStatus.length) {
    if (r>230 && g>230) {
      println("yellow");
    }
    if (r>230 && g<100) {
      println("red");
    }
    if (r<100 && g>230) {
      gameStatus[frameCounter] = 1;
      println("green");
    } else
    {
      gameStatus[frameCounter] = 0;
    }


    println("4");

    if (yellowPix < (movie.width*movie.height) - movie.width - 100) {
      if (!findYellow) {
        int pixelColor2 = movie.pixels[yellowPix];

        r = (pixelColor2 >> 16) & 0xff;
        g = (pixelColor2 >> 8) & 0xff;
        b = pixelColor2 & 0xff;
  //      println("RGB2: "+r+","+g+","+b);
        if (r>240 && g>240 && b < 100) {
          println("Find Yellow at "+pixelColor2);
          findYellow = true;
        } else {
          yellowPix += movie.width;
          println("NOT FOUND, now pix is "+yellowPix);
        }
      }
    } else {
      println("Yellow PIX NOT FOUND");
    }
  }

  if (frameCounter%100 == 0 || frameCounter == valenceBuff.length - 1) {
    String[] toSave = new String[0]; 
    for (int i = oldPosition; i < frameCounter; i++) {
      toSave = append(toSave, i+", "+arousalBuff[i]+", "+valenceBuff[i]+", "+gameStatus[i]);
    }
    saveStrings(id+"/"+oldPosition+".csv", toSave);
    oldPosition = frameCounter;
  }



  //  println("write on "+frameCounter);
}

void draw() {
  background(230);

  if (useGamepad) SetUserInput();
  MovieController();
  image(movie, 0, 0, width, height-200);
  SetProgressionBar();
  SetValenceArousalSlider();


}



void SetValenceArousalSlider() {
  fill(230);
  rect(0, height-199, width, 0);
  line(width/2, height, width/2, height - 199);
  image(manikin, 0, height-199, width, 200);
  SetValenceSlider();
  SetArousalSlider();
}

void SetValenceSlider() {

  fill(125);
  triangle(width/4, height - 100, 50, height - 120, 50, height - 80);
  triangle(width/4, height - 100, width/2 - 50, height - 120, width/2 - 50, height - 80);
  DefineValenceValue();
  fill(0, 255, 0);
  rectMode(CENTER);
  rect((startingValenceValue / 100 ) * (width/2 - 100) + 50, height - 100, 10, 40);
  fill(0, 255, 0, 50);
  rect((startingValenceValue / 100 ) * (width/2 - 100) + 50, height - 180, 50, 50);
}

void DefineValenceValue() {

  if (startingValenceValue >= 0) {
    if (slider2 < 40 && slider2 >= 25) {
      startingValenceValue--;
    }
    if (slider2 < 25) {
      startingValenceValue--;
    }
  }
  if (startingValenceValue <= 100) {
    if (slider2 > 60 && slider2 <= 85) {
      startingValenceValue++;
    }
    if (slider2 > 85) {
      startingValenceValue++;
    }
  }


  if (startingValenceValue < 0) startingValenceValue = 0;
  if (startingValenceValue > 100) startingValenceValue = 100;
}

void SetArousalSlider() {

  fill(125);
  triangle((width/4)*3, height - 100, width/2 + 50, height - 120, width/2 +  50, height - 80);
  triangle((width/4)*3, height - 100, width - 50, height - 120, width - 50, height - 80);
  DefineArousalValue();
  fill(255, 0, 0);
  //  rectMode(CENTER);

  float tempValue = (startingArousalValue / 100 * (width/2 - 100))   + (width/2 + 50);
  rect(tempValue, height - 100, 10, 40);

  fill(255, 0, 0, 50);
  rect(tempValue, height - 180, 50, 50);
}

void DefineArousalValue() {

  if (startingArousalValue >= 0) {
    if (slider1 < 40 && slider1 >= 25) {
      startingArousalValue--;
    }
    if (slider1 < 25) {
      startingArousalValue--;
    }
  }
  if (startingArousalValue <= 100) {
    if (slider1 > 60 && slider1 <= 85) {
      startingArousalValue++;
    }
    if (slider1 > 85) {
      startingArousalValue++;
    }
  }


  if (startingArousalValue < 0) startingArousalValue = 0;
  if (startingArousalValue > 100) startingArousalValue = 100;
}


void SetProgressionBar() {
  strokeWeight(4);
  stroke(0);
  line(0, height - 200, width, height - 200);
  stroke(255, 0, 0);
  line(0, height - 200, ((movie.time() / movie.duration())*width), height - 200);
  stroke(0);
  strokeWeight(1);
  textAlign(CENTER);
  textSize(12);
  fill(255, 0, 0);
  text(round(movie.time())+ "s on "+round(movie.duration())+"s", ((movie.time() / movie.duration())*width), height - 215);
}

void MovieController() {

  //GoBack
  // println(videoPos);
  if (videoPos < 0.96) {
    int myVal = round( (1-videoPos) * 3);
    movie.jump(movie.time()-myVal);
    frameCounter = (int)( movie.time() * frame);
    if (frameCounter >= arousalBuff.length) frameCounter = arousalBuff.length - 1;
    startingArousalValue = arousalBuff[frameCounter];
    startingValenceValue = valenceBuff[frameCounter];
    if (!isInPause) ppy = true;
  }
  //PausePlay
  if (ppy || ppa) {
    // while(ppy){println("b");} //wait the released
    if (isInPause) {
      isInPause = false;
      movie.play();
    } else {
      isInPause = true;
      movie.pause();
    }
    delay(500);
    if (frameCounter >= arousalBuff.length) frameCounter = arousalBuff.length - 1;
    startingArousalValue = arousalBuff[frameCounter];
    startingValenceValue = valenceBuff[frameCounter];
  }

  //Reset
  if (reset_s) {
    println("RESET");
    VideoSetup();
    movie.jump(0);
    frameCounter=0;
    if (frameCounter >= arousalBuff.length) frameCounter = arousalBuff.length - 1;
    startingArousalValue = arousalBuff[frameCounter];
    startingValenceValue = valenceBuff[frameCounter];
    if (isInPause) {
      movie.play();
      movie.pause();
    }
    delay(500);
  }

  //RESET FUNCTION
  if (videoPos > 1.05) {
    //Uncomment to implement the video forward. NB: the data skipped will not be recorded
    /*
            int i = 0;
     while ((valenceBuff[i] != -1 || arousalBuff[i] != -1) && i < arousalBuff.length - 1) {
     i++;
     }
     movie.jump(i/movie.duration());
     frameCounter = (int)(movie.time() * frame);
     if (frameCounter >= arousalBuff.length) frameCounter = arousalBuff.length - 1;
     startingArousalValue = arousalBuff[frameCounter];
     startingValenceValue = valenceBuff[frameCounter];
     */
     
    //comment if you want to use the video forward modality 
    startingArousalValue = 50;
    startingValenceValue = 50;
  }

  //finish
  if (finish) {
    int where = -1;    
    for (int i = 0; i < arousalBuff.length; i++) {
      if (arousalBuff[i] == -1 || valenceBuff[i] == -1) {
        where = i;
      }
    }
    if (where == -1) {
      WriteAndClose("endData");
      println("FINISH");
    } else {
      WriteAndClose("endData");
      println("Miss value in frame "+where+", second "+where/movie.duration()+" on "+ movie.duration());
    }
    delay(500);
  }
}

void WriteAndClose(String fileName) {

  String[] toWrite = new String[arousalBuff.length];
  for (int i = 0; i < arousalBuff.length; i++) {
    println(i+"- A: "+arousalBuff[i]+" V: "+valenceBuff[i]);
    toWrite[i] = i+", "+arousalBuff[i]+", "+valenceBuff[i]+", "+gameStatus[i];
  }
  saveStrings(id+"/"+fileName+".csv", toWrite);
}

void SetUserInput() {
  slider1 = map(gpad.getSlider("RX").getValue(), -1, 1, 0, 100);
  slider2 = map(gpad.getSlider("LX").getValue(), -1, 1, 0, 100);
  videoPos = map(gpad.getSlider("BX").getValue(), -1, 1, 0, 2);
  videoPos = videoPos * (-1) + 2;
  reset_s = gpad.getButton("RS").pressed();
  ppy = gpad.getButton("PPY").pressed();
  ppa = gpad.getButton("PPA").pressed();
  finish = gpad.getButton("FS").pressed();
}

//Some keyboard functions
void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) startingArousalValue--;
    if (keyCode == DOWN) startingArousalValue++;
    if (keyCode == ENTER) finish = true;
    if (keyCode == BACKSPACE) reset_s = true;
  } else {
    if (key == 'a') startingValenceValue--;
    if (key == 'd') startingValenceValue++;
    if (key == ' ') ppy = true;
    if (key == 'r') reset_s = true;
    if (key == 's' || key == 'S') {
      output.flush(); // Writes the remaining data to the file
      output.close(); // Finishes the file
    }
  }
}
