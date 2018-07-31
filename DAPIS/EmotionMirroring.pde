//USED FOR TRAINING FUNCTION. Place the images in the Data in jpg format
//Replace the file names of the "files" array with your custom file names

PImage[] emotions;
String[] files = new String[]{"base","angry", "disgust", "fear", "happy", "sad", "surprised"};


int waitingTimeBeforeRecordImage = 3;
int staticWaitingTime = waitingTimeBeforeRecordImage;


void StartEmotionMirror() {

  CreateImageArrays();
}

void CreateImageArrays() {
  //FILL THE ARRAY OF IMAGES
  emotions = new PImage[files.length];
  for (int i = 0; i < emotions.length; i++) emotions[i] = loadImage(files[i]+".jpg");
}

void ShowImage(int i) {
  //background(255);
  imageMode(CENTER);
  image(emotions[i], width/2, height/2);
}

boolean CountDown() {
  if (waitingTimeBeforeRecordImage >= 0) {
    textSize(32);
    textAlign(CENTER);   
    stroke(0);
    fill(BLUE);
    rect(0, height/2 - 50, 100, 100);
    fill(0);
    text(waitingTimeBeforeRecordImage, 50, height/2); 
    delay(1000);
  } 
  if (waitingTimeBeforeRecordImage == 0) { 
    waitingTimeBeforeRecordImage = staticWaitingTime;
    return true;
  } else {
    
    waitingTimeBeforeRecordImage--;
    return false;
  }
}

void SaveEmotion(int wich) {

  String dateTimeStr = getDateTime();
  String fileToSave = id+"/emotion."+files[wich]+dateTimeStr+".txt";

  saveStrings(fileToSave, myData);
}
