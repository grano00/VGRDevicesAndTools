//SET true if you have a licence of CAMTASIA. Otherwise, you can use any software to record the computer monitor (start it before run this application)
boolean videoRecord = false;
long startingMillis;


String camtasiaPath = "\"C:\\Program Files (x86)\\TechSmith\\Camtasia Studio 9\\CamRecorder.exe\"";
void StartCamtasia() {
  if (videoRecord) {
    noLoop();
    background(255);
    myData = append(myData, "start at "+getDateTime());
    try {
      Runtime.getRuntime().exec("cmd /c "+camtasiaPath+" /record");
      delay(10000);
    }
    catch(IOException ioe) {
      println(ioe);
    }
    loop();
  }
}

void StopCamtasia() { 
  if (videoRecord) {
    noLoop();
    background(255);
    delay(1000);
    myData = append(myData, "stop at "+getDateTime());
    try {
      Runtime.getRuntime().exec("cmd /c "+camtasiaPath+" /stop");
    }
    catch(IOException ioe) { 
      println(ioe);
      loop();
    }
    delay(1000);
  }
}
