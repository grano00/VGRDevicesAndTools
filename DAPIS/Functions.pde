//Utility functions

void Connect() {
  // **** Zero out data array **** //
  background(255);
  delay(3000);
  EmptyArray();
  port = new Serial(this, portName, baudRate);
  connected = true;
  logFld.setText("Connect btn was hit.");
  count = width + 1;

}

void Disconnect() {
  port.stop();
  yIn = 0;
  count = 0;
  connected = false;
  logFld.setText("Disconnect button was hit.");
  stop = true;
}



void Save() {
  Save(getDateTime());
}


void Save(String fileName) {

  String fileToSave = id+"/"+fileName+".txt";
  int[] yTemp = y;
  String[] data = new String[yTemp.length];
  for (int i = 0; i < yTemp.length; i++) {
    data[i] = yTemp[i]+",";
  }
  


  fileToSave = id+"/"+fileName+"Complete.csv";

  saveStrings(fileToSave, myData);


  logFld.setText("Data was saved to a file in app folder.");
}

void EmptyArray() {
  y = new int[0];
  myData = new String[0];
}



void ScreenShot() {
  String dateTimeStr = getDateTime();
  String imageOut = dateTimeStr+".png";
  save(imageOut);
  logFld.setText("Screenshot was saved to app folder.");
}

void RescanPorts() {
  logFld.setText("Rescan ports.");
  cp5.get(ScrollableList.class, "SerialPorts").clear();
  String[] ports = Serial.list();
  List p = Arrays.asList(ports);
  cp5.get(ScrollableList.class, "SerialPorts").addItems(p);
}

void fileSelected(File selection) {
  if (selection != null) {
    // reset required for multiple selections 
    index = 0;
    counter = 0;
    fileName = selection.getAbsolutePath(); 
    logFld.setText("File selected: " + fileName);
    data = loadStrings(selection.getAbsolutePath());
  }
}


void ClrScrn() {
  background(BLUE);
}

void SerialPorts(int n ) {
  /* request selected item from Map based on index n */
  portName = cp5.get(ScrollableList.class, "SerialPorts").getItem(n).get("name").toString();
  logFld.setText("portSelected: "+portName);
  background(BLUE);
}

void Baud(int n ) {
  baudRate = baud[n];
  logFld.setText("baudRate: "+baudRate);
  background(BLUE);
}



void Open() {
  selectInput("Select a file to process:", "fileSelected");
}

void Replay() {
  if (fileName == null) {
    logFld.setText("There is no file selected.");
    // To avoid null pointer exception
    return;
  } else {
    background(BLUE);
    data = loadStrings(fileName);
    index = 0;
    counter = 0;
  }
}

void Radio(int radioID) {
  switch(radioID) {
    case(0):
    logFld.setText("Graph selected as output.");
    showGraph = true;
    showText = false;
    break;
    case(1):
    logFld.setText("Text selected as output.");
    showGraph = false;
    showText = true;
    break;
  }
} 

void Quit() {
  if (videoRecord) {
    StopCamtasia();
  }
  println("ERROR COUNTER = "+errCounter);
  SaveVideoEvents();
  delay(1000);
  Disconnect();
  //  while(!canClose){}
  Save();
  delay(1000);
  exit();
}

void SaveVideoEvents() {
  println("SAVE VIDEO EVENT");
  String dateTimeStr = getDateTime();
  String fileToSave = id+"/videoEvent/"+dateTimeStr+"-VideoEvents.csv";
  saveStrings(fileToSave, videoEvents);
}

String getDateTime()
{
  int s = second();
  int m = minute();
  int h = hour();
  int day = day();
  int mo = month();
  int yr = year();

  // Avoid slashes which create folders
  String date = nf(mo, 2)+nf(day, 2)+yr+"_";
  String time = nf(h, 2)+nf(m, 2)+nf(s, 2);
  String dateTime = date+time;
  return dateTime;
}
