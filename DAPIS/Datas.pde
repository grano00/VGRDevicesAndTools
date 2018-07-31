boolean firstTime = true;
void SetYValue() {
  dataCounter = 0;
  String s="";
  for (int i=0; i<dataBuff.length; i++) s+=dataBuff[i]+",";
  Debug(s);
  if ((dataBuff[dataBuff.length - 2] == 254 && dataBuff[dataBuff.length - 1] == 255) || (dataBuff[dataBuff.length - 2] == 252 && dataBuff[dataBuff.length - 1] == 253)) {  
    Debug("Wow, it is a correct array!");
    if (dataBuff[dataBuff.length - 2] == 252 && dataBuff[dataBuff.length - 1] == 253) {
      CheckKeyPad();
    }
    inByte = GetIntFromByte();
    Debug("My Data is "+inByte);
    if (!firstTime || (dataBuff[dataBuff.length - 2] == 252 && dataBuff[dataBuff.length - 1] == 253)) {
      if (firstTime) for (int i = 0; i < 20; i++) println("******************");

      firstTime = false;

      y = append(y, inByte);
      myData = append(myData, GetStringFromArray(dataBuff));
      if (inTraining) println("Data on -> " +emotionCounter);
      if (myData.length > 100000) {
        Save();
        EmptyArray();
      }
      String inStr = str(inByte)+",\n";
      yIn = height - inByte;
      if (showText == true) {
        valueFld.append(inStr);
      }
    }
  } else {
    Debug("ERROR: " +s, true);
    Debug("DataBuff: " + dataBuff[dataBuff.length - 2] + "-"+ dataBuff[dataBuff.length - 1],true); 
    sync = false;
    step = 0;
  }
}  

int sample =0;
String GetStringFromArray(int[] data) {
  if (tempKeypad == 14 || tempKeypad == 15) {
    println("AT SECOND "+data[data.length-1]+" ASSIGN "+tempKeypad); 
    keypad = tempKeypad; 
    tempKeypad = -1;
  }
  String s= keypad+",";
  
  for (int i = 0; i < (data.length - 2) / 2; i++) {
    s+=GetIntFromByte(data, i)+",";
  }
 // println("string to write: "+s);
  if (data[data.length-1] == 253) {
    if (sample < 900) print("##################");
    println("revealed "+sample+" n of sample at second "+infiniteLoop);
    sample = 0;
    loop++;
    infiniteLoop++;
  } else {
    sample++;
  }
  s+=sample;
  Debug("DATA: "+s,false);

  return s;
}


int GetIntFromByte(int i) {
  int data = (dataBuff[i*2] << 8) | (dataBuff[i*2+1] & 0xFF);
  return data;
}

int GetIntFromByte(int[] outData, int i) {
  int data = (outData[i*2] << 8) | (outData[i*2+1] & 0xFF);
  return data;
}
int GetIntFromByte() {
  int data = (dataBuff[value*2] << 8) | (dataBuff[value*2+1] & 0xFF);
 // if (value != 8) { 
    //data = data / 8;
    data = (data - center[value]); // divide[value];
//  }
  if (value == 8) { 
    //data = data - 2500 ;

    println(((float)(data + 2500)) / 100);
  }
  return data;
}

int keyPadPressed = -1;
int gameCounter = 0;
void FillTheBuffer() {
  if (firstData) {
    keypad = port.read();
    if (keypad != 16)  Debug("keypad: "+keypad, true);
    firstData = false;
    //HERE IS SET THE VIDEO EVENT
    if (keypad == 13) {
      ChangeGraph();
    }
    //C START THE GAME
    //D STOP THE GAME
    if (keypad == 1 || keypad == 14) {
      //START THE GAME
      keyPadPressed = 14;
      keypad = 16;
    }
    if (keypad == 2 || keypad == 15) {
      //END THE GAME
      keyPadPressed = 15;
      keypad = 16;
    }
  } else {
    Debug("readD");
    dataBuff[dataCounter] = port.read();
    Debug("data["+dataCounter+"]: "+dataBuff[dataCounter]);
    dataCounter++;
  }
}

int tempKeypad = -1;
void CheckKeyPad() {
  if (keyPadPressed == 15) {
    Save(getDateTime()+"AfterThisStopGame_"+gameCounter);
    EmptyArray();
    gameCounter++;
    videoEvents = append(videoEvents, "stop,"+(millis()-startingMillis));
    rectColor = color(255, 0, 0);
   
    keyPadPressed = -1;
    println("ASSING TK = 15");
    tempKeypad = 15;
  }
  else if (keyPadPressed == 14) {
    Save(getDateTime()+"AfterThisStartGame"+gameCounter);
    EmptyArray();
    videoEvents = append(videoEvents, "start,"+(millis()-startingMillis));
    rectColor= color(0, 255, 0);
    keyPadPressed = -1;
    println("ASSING TK = 14");
    tempKeypad = 14;
  }
}

int step = 0;
void FindEndData() {
  inByte = port.read();
  Debug("STEP "+step+" and Byte "+ inByte + " hence "+ (step == 0 && inByte == 254), true);
  if (step == 0 && inByte == 254) {
    step++;
  } else { 
    if (step == 1 && inByte == 255) {
      println("FindEND");
      sync = true;
      dataCounter = 0;
    } else {
      step = 0;
    }
  }
}