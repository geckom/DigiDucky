#include "DigiKeyboard.h"

// Delay between keystrokes
#define KEYSTROKE_DELAY 1000

#define  KEY_ESC         0x29  // Escape
#define KEY_MODIFIER_LEFT_GUI 0x08

int iterationCounter = 0;

void setup() {
  
  // initialize the digital pin as an output.
  pinMode(0, OUTPUT); //LED on Model B
  pinMode(1, OUTPUT); //LED on Model A     
  digitalWrite(0, LOW);    // turn the LED off by making the voltage LOW
  digitalWrite(1, LOW); 
  // don't need to set anything up to use DigiKeyboard
}


void loop() {
  
  DigiKeyboard.update();

  if (iterationCounter == 0) {
    // this is generally not necessary but with some older systems it seems to
    // prevent missing the first character after a delay:
    DigiKeyboard.sendKeyStroke(0);
  
  
    // It's better to use DigiKeyboard.delay() over the regular Arduino delay()
    // if doing keyboard stuff because it keeps talking to the computer to make
    // sure the computer knows the keyboard is alive and connected
    DigiKeyboard.delay(KEYSTROKE_DELAY);
  
  
    DigiKeyboard.sendKeyStroke(KEY_ESC, KEY_MODIFIER_LEFT_GUI);
    DigiKeyboard.delay(KEYSTROKE_DELAY);
    DigiKeyboard.print("https://www.youtube.com/watch?v=dQw4w9WgXcQ");
    DigiKeyboard.delay(KEYSTROKE_DELAY);
    DigiKeyboard.sendKeyStroke(KEY_ENTER);
    DigiKeyboard.delay(KEYSTROKE_DELAY);
    

  }

  delay(1000);
  
  iterationCounter++;
}

