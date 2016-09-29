#!/bin/bash
INFILE=$1
OUTFILE=$2

echo "
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

void loop(){
}

void setup(){
	DigiKeyboard.update();
	if (iterationCounter == 0) {
		// this is generally not necessary but with some older systems it seems to
		// prevent missing the first character after a delay:
		DigiKeyboard.sendKeyStroke(0);

		// It's better to use DigiKeyboard.delay() over the regular Arduino delay()
		// if doing keyboard stuff because it keeps talking to the computer to make
		// sure the computer knows the keyboard is alive and connected
		DigiKeyboard.delay(KEYSTROKE_DELAY);

" > $OUTFILE
while read -r
do
  COMMAND=`echo -E "$REPLY" | sed -e 's/ .*$//g'`
  OPTIONS=`echo -E "$REPLY" | sed -s 's/^[^ ]* //g'`
  MODIFIERS="0";
  KEY1="0";
  KEY2="0";

  if [ "$COMMAND" = "REM" ] 
  then echo "  // $OPTIONS" >> $OUTFILE
  elif [ "$COMMAND" = "STRING" ] 
  then 
    OPTIONS=`echo "$OPTIONS" | sed -e 's/\\\\/\\\\\\\\/g' -e 's/"/\\\"/g'`
    IFS=" "
    echo "	DigiKeyboard.print(\"$OPTIONS\");" >> $OUTFILE
  elif [ "$COMMAND" = "DELAY" ]
  then DELAY=$(( $OPTIONS * 10 )); echo "  DigiKeyboard.delay(${DELAY});" >> $OUTFILE
  else
    for TOKEN in $REPLY
    do KEY=""
      if [ "$TOKEN" = "GUI" -o "$TOKEN" = "WINDOWS" ]
        then MODIFIERS="$MODIFIERS | KEY_MODIFIER_LEFT_GUI";
      elif [ "$TOKEN" = "SHIFT" ]
        then MODIFIERS="$MODIFIERS | KEY_MODIFIER_LEFT_SHIFT";
      elif [ "$TOKEN" = "ALT" ]
        then MODIFIERS="$MODIFIERS | KEY_MODIFIER_LEFT_ALT";
      elif [ "$TOKEN" = "CONTROL" -o "$TOKEN" = "CTRL" ]
        then MODIFIERS="$MODIFIERS | KEY_MODIFIER_LEFT_CTRL";
      elif [ "$TOKEN" = "MENU" -o "$TOKEN" = "APP" ]
        then KEY="PROPS"
      elif [ "$TOKEN" = "LEFTARROW" ]
        then KEY="LEFT"
      elif [ "$TOKEN" = "RIGHTARROW" ]
        then KEY="RIGHT"
      elif [ "$TOKEN" = "UPARROW" ]
        then KEY="UP"
      elif [ "$TOKEN" = "DOWNARROW" ]
        then KEY="DOWN"
      elif [ "$TOKEN" = "ESCAPE" ]
        then KEY="ESC"
      else KEY=$TOKEN
      fi
      if [ "$KEY" != "" ]
      then KEY=`echo $KEY | tr [a-z] [A-Z]`
        if [ "$KEY1" = "0" ]
        then KEY1="KEY_$KEY";
        else KEY2="KEY_$KEY";
        fi
      fi
    done
    echo "  DigiKeyboard.sendKeyStroke(${KEY1}, ${KEY2}, ${MODIFIERS});" >> $OUTFILE
  fi
done < $INFILE
echo "	}" >> $OUTFILE
echo "	delay(1000);" >> $OUTFILE
echo "	iterationCounter++;" >> $OUTFILE
echo "}" >> $OUTFILE

