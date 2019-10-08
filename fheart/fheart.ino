/*
  MP3 Shield Trigger
  by: Jim Lindblom
      SparkFun Electronics
  date: September 23, 2013

  This is an example MP3 trigger sketch for the SparkFun MP3 Shield.
  Pins 0, 1, 5, 10, A0, A1, A2, A3, and A4 are setup to trigger tracks
  "track001.mp3", "track002.mp3", etc. on an SD card loaded into
  the shield. Whenever any of those pins are shorted to ground,
  their respective track will start playing.

  When a new pin is triggered, any track currently playing will
  stop, and the new one will start.

  A5 is setup to globally STOP playing a track when triggered.

  If you need more triggers, the shield's jumpers on pins 3 and 4 
  (MIDI-IN and GPIO1) can be cut open and used as additional
  trigger pins. Also, because pins 0 and 1 are used as triggers
  Serial is not available for debugging. Disable those as
  triggers if you want to use serial.

  Much of this code was grabbed from the FilePlayer example
  included with the SFEMP3Shield library. Major thanks to Bill
  Porter and Michael Flaga, again, for this amazing library!
*/

#include <SPI.h>           // SPI library
#include <SdFat.h>         // SDFat Library
//#include <SdFatUtil.h>     // SDFat Util Library
#include <SFEMP3Shield.h>  // Mp3 Shield Library

SdFat sd; // Create object to handle SD functions

SFEMP3Shield MP3player; // Create Mp3 library object
// These variables are used in the MP3 initialization to set up
// some stereo options:
const uint8_t volume = 20; // MP3 Player volume 0=max, 255=lowest (off)
const uint16_t monoMode = 1;  // Mono setting 0=off, 3=max
#define ARRAYSIZE 5
String farts[ARRAYSIZE] = { "track001.mp3", "track002.mp3", "track003.mp3", "track004.mp3" , "track005.mp3" };
int fartDuration[ARRAYSIZE] = { 5000, 9000, 4000, 5000, 6000 };
/* Pin setup */
#define TRIGGER_COUNT 9
int triggerPins[TRIGGER_COUNT] = {0, 1, 5, 10, A0, A1, A2, A3, A4};
int stopPin = A5; // This pin triggers a track stop.
int lastTrigger = 0; // This variable keeps track of which tune is playing
int micPin = A0;

int boringTimer = 0;
int tenseTimer = 0;
int tenseMomentCounter = 0;
int excitingTimer = 0;
int awkwardTimer = 0;
long sum = 0;
int backgroundNoise = 0;
bool isExciting = false;
bool isAwkward = false;
bool isTense = false;
bool defaultValueCalculated = false;
bool highVolume = false;
void setup()
{

  pinMode(3, OUTPUT);
  /* Set up all trigger pins as inputs, with pull-ups activated: */
  for (int i=0; i<TRIGGER_COUNT; i++)
  {
    pinMode(triggerPins[i], INPUT_PULLUP);
  }
  pinMode(stopPin, INPUT_PULLUP);
Serial.begin(115200);

  initSD();  // Initialize the SD card
  initMP3Player(); // Initialize the MP3 Shield
}


void loop()
{
  if (!defaultValueCalculated){
    backgroundNoise = setBackgroundVolume();
    defaultValueCalculated = true;
  }
  
  sum = analogRead(micPin) - backgroundNoise;

  if (sum > 100){
    Serial.println("nicve");
    boringTimer = 0;
  }
 
  if (sum > 200 && !isExciting && !highVolume) {
    highVolume = true;
    Serial.println("High <<volume");
    delay(50);
  }
   
  if (highVolume && sum < 50 && !isExciting) {
    isExciting = true;
    isAwkward = true;
    Serial.println("Exciting");
  }
  
  if (isExciting){
    excitingTimer++;
    if (sum > 100){
      tenseMomentCounter++;
      Serial.println(tenseMomentCounter);
    }
    if (tenseMomentCounter == 10){
      isAwkward = false;
    }
    if (tenseMomentCounter > 50){
excitingTimer += 1000;
      isTense = true;
    }
    if (excitingTimer > 1000){
      if (isAwkward){
        Serial.println("Playing: AwkwardFart");
        playFart("track002.mp3", 9000);
      }else if (isTense){
        Serial.println("Playing: TenseFart");
        playFart("track005.mp3", 6000);
      }
      reset();
      Serial.println("Exited");
      delay(250);
    }
  }
  else if (sum < 10 && sum > 0){
    boringTimer++;
    Serial.println(boringTimer);
  }
  if (boringTimer > 1000){
    playFart("track003.mp3", 4000);
    reset();
  }
  delay(10);
}

void reset(){
  isExciting = false;
  isTense = false;
  isAwkward = false;
  highVolume = false;
  tenseMomentCounter = 0;
  boringTimer = 0;
  excitingTimer = 0;
}

int setBackgroundVolume(){
  int allSum = 0;
  for(int i = 0; i < 25; i++){
    allSum += analogRead(micPin);
    delay(10);
  }
  return allSum/25;
}

void playFart(String fartTrackName, int fartDuration) {
  char currentFart[13];
  fartTrackName.toCharArray(currentFart, 13); 
  Serial.println(fartTrackName);
  MP3player.playMP3(currentFart);
  if (MP3player.isPlaying()) {
    digitalWrite(3, HIGH);
    delay(fartDuration);
    MP3player.stopTrack();
    digitalWrite(3, LOW);
  }
  delay(5000);
}
  
// initSD() initializes the SD card and checks for an error.
void initSD()
{

  //Initialize the SdCard.
  if(!sd.begin(SD_SEL, SPI_HALF_SPEED))
    sd.initErrorHalt();
  if(!sd.chdir("/")) 
    sd.errorHalt("sd.chdir");
}

// initMP3Player() sets up all of the initialization for the
// MP3 Player Shield. It runs the begin() function, checks
// for errors, applies a patch if found, and sets the volume/
// stero mode.
void initMP3Player()
{
  uint8_t result = MP3player.begin(); // init the mp3 player shield
  if(result != 0) // check result, see readme for error codes.
  {
    Serial.println("oops");
  }
  MP3player.setVolume(volume, volume);
  MP3player.setMonoMode(monoMode);
}
