#include <OneWire.h>
#include <DallasTemperature.h>

//FOR TEMPERATURE
// Data wire is plugged into port 2 on the Arduino
#define ONE_WIRE_BUS 2
// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);
// Pass our oneWire reference to Dallas Temperature.
DallasTemperature sensors(&oneWire);
DeviceAddress tempDeviceAddress;
int  resolution = 10;
unsigned long lastTempRequest = 0;
int  delayInMillis = 0;
float temperature = 0.0;

//In my personal case, it is impossible to receive an value bigger the the composition of this two byte
int delimiter1 = 254;
int delimiter2 = 255;

int counter = 0; //It will define the sample frequency
int dataLength = 8; //How many data I have to read
// The array of byte will be with this structure
// Data1HighByte,Data1LowByte,..,DataNLowByte,delimiter1,delimiter2
int arrayLength = (dataLength) * 2 + 2;
byte buff[20];
int val = 0;


String dataString = "";
int c;
long myTime = 0; //it is used in order to define the sampleFrequency
char receivedByte;


//KEYPAD
#include <Keypad.h>

const byte numRows = 4; //number of rows on the keypad
const byte numCols = 4; //number of columns on the keypad

//keymap defines the key pressed according to the row and columns just as appears on the keypad
char keymap[numRows][numCols] =
{
  {'1', '2', '3', 'A'},
  {'4', '5', '6', 'B'},
  {'7', '8', '9', 'C'},
  {'*', '0', '#', 'D'}
};

//Code that shows the the keypad connections to the arduino terminals
byte rowPins[numRows] = {22, 24, 26, 28}; //Rows 0 to 3
byte colPins[numCols] = {30, 32, 34, 36}; //Columns 0 to 3

//initializes an instance of the Keypad class
Keypad myKeypad = Keypad(makeKeymap(keymap), rowPins, colPins, numRows, numCols);



void setup() {
  // put your setup code here, to run once:
  Serial.begin(250000, SERIAL_8N1);
  //Serial1.begin(250000, SERIAL_8N1);
  //Serial2.begin(250000, SERIAL_8N1);
  //SerialUSB.begin(57600, SERIAL_8N1);
  for (int i = 0; i < sizeof(buff) - 2; i++) buff[i] = 0;

  counter = 0;
  myTime = millis();
  // noInterrupts();
  val = 0;
  analogReadResolution(12);
  sensors.begin();
  sensors.getAddress(tempDeviceAddress, 0);
  sensors.setResolution(tempDeviceAddress, resolution);

  sensors.setWaitForConversion(false);
 // sensors.requestTemperatures();
  delayInMillis = 750 / (1 << (12 - resolution));
  lastTempRequest = millis();
  digitalWrite(12, HIGH);
  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);
  //noInterrupts();

  //while(Serial.available() == 0){}

}

void loop() {
	

 //fill the buffer
  for (c = 0; c < 6; c++) {
    val = analogRead(c);

    buff[c * 2 + 0] = (byte)((val & 0xFF00) >> 8);
    buff[c * 2 + 1] = ((byte)(val & 0x00FF));
  }
  val = analogRead(10); //GSR
  buff[c * 2 + 0] = (byte)((val & 0xFF00) >> 8);
  buff[c * 2 + 1] = ((byte)(val & 0x00FF));
  c++;
  val = analogRead(11); //Lux
  buff[c * 2 + 0] = (byte)((val & 0xFF00) >> 8);
  buff[c * 2 + 1] = ((byte)(val & 0x00FF));

  c++;
  
  //DEPRECATED. Used to acquire the temperature data from digital sensor
 
/*
  SetTemperature(); 
  if (temperature >= 0) {
    val = (int)(temperature * 100);
  }
  else {
    val = 6000;
  }
  buff[c * 2 + 0] = (byte)((val & 0xFF00) >> 8);
  buff[c * 2 + 1] = ((byte)(val & 0x00FF));
*/

 //temperature
  val = analogRead(9); 
  buff[c * 2 + 0] = (byte)((val & 0xFF00) >> 8);
  buff[c * 2 + 1] = ((byte)(val & 0x00FF));

  buff[sizeof(buff) - 2] = delimiter1;
  buff[sizeof(buff) - 1] = delimiter2;


  //write the content on serial
  dataString = MyKeyPad();
  for (int i = 0; i < sizeof(buff); i++) {
    Serial.write(buff[i]);
  }

  counter++;
  if (delimiter1 == 252 || delimiter2 == 253) {
    delimiter1 = 254;
    delimiter2 = 255;
  }
  if ( millis()  - myTime >= 1000) { //if is passed 1 sec, the counter will be reset
    counter = 0;
    myTime = millis();
    delimiter1 = 252; //This identify the sample frequency
    delimiter2 = 253;
  }
}


//The following code identify the value of event flag
String MyKeyPad() {

  char keypressed = myKeypad.getKey();
  if (keypressed != NO_KEY)
  {
    digitalWrite(13, HIGH);

    if (keypressed == '1') {
      Serial.write((byte)1);
      return "1";
    }
    if (keypressed == '2') {
      Serial.write((byte)2);
      return "2";
    }
    if (keypressed == '3') {
      Serial.write((byte)3);
      return "3";
    }
    if (keypressed == '4') {
      Serial.write((byte)4);
      return "4";
    }
    if (keypressed == '5') {
      Serial.write((byte)5);
      return "5";
    }
    if (keypressed == '6') {
      Serial.write((byte)6);
      return "6";
    }
    if (keypressed == '7') {
      Serial.write((byte)7);
      return "7";
    }
    if (keypressed == '8') {
      Serial.write((byte)8);
      return "8";
    }
    if (keypressed == '9') {
      Serial.write((byte)9);
      return "9";
    }
    if (keypressed == '0') {
      Serial.write((byte)0);
      return "0";
    }

    if (keypressed == '*') {
      Serial.write((byte)10);
      return "10";
    }
    if (keypressed == '#') {
      Serial.write((byte)11);
      return "11";
    }
    if (keypressed == 'A') {
      Serial.write((byte)12);
      return "12";
    }
    if (keypressed == 'B') {
      Serial.write((byte)13);
      return "13";
    }
    if (keypressed == 'C') {
      Serial.write((byte)14);
      return "14";
    }
    if (keypressed == 'D') {
      Serial.write((byte)15);
      return "15";
    }

  }
  else
  {
    Serial.write((byte)16);

    digitalWrite(13, LOW);
    return "16";
  }
}

//DEPRECATED. Used for digital temperature
void SetTemperature() {

  if (millis() - lastTempRequest >= delayInMillis) // waited long enough??
  {
    temperature = sensors.getTempCByIndex(0);
    sensors.requestTemperatures();
    delayInMillis = 750 / (1 << (12 - resolution));
    lastTempRequest = millis();
  }

}

