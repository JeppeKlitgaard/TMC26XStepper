/**
 * ControlP5 Slider. Horizontal and vertical sliders, 
 * with and without tick marks and snap-to-tick.
 * by andreas schlegel, 2010
 */

import controlP5.*;
import processing.serial.*;

ControlP5 controlP5;

Serial arduinoPort;

//TODO comde up with a nice color scheme
color activeColor = #22aaee;
color foreGroundColor = #1a6699; //Stil to use 1a334c
color labelColor = #f0f0f0;
color valueColor = #f0f0f0;
color graphBackgroundColor = #131313;
color stallGuardColor = #991a1a;
color positionColor = #1a6699; //still to use #8c7f26
color goodStatusColor = labelColor;
color badStatusColor = stallGuardColor;

Slider constantOffSlider;
Slider blankTimeSlider;
Toggle randomOffTimeToggle;
RadioButton ChopperModeButtons;
//for constant off time chopeer
Slider fastDecaySlider;
Slider sineWaveOffsetSlider;
Toggle currentComparatorToggle;
//for spread chopper
Range hysteresisRange;
RadioButton hysteresisDecrementButtons;

Slider speedSlider;
Toggle runToggle;
RadioButton directionButtons;
Toggle enabledToggle;
RadioButton microsteppingButtons;
Slider sgtSlider;
Button sgtPlus;
Button sgtMinus;
Toggle sgFilterToggle;
Slider currentSlider;

Tab configureTab;
Tab runTab;
Tab activeTab;

boolean settingStatus=false;

boolean running = false;


void setup() {
  size(1000, 800);
  //load the font
  controlP5 = new ControlP5(this);
  runTab = controlP5.addTab("run");
  configureTab=controlP5.getTab("default");
  //customize the tabs a bit
  configureTab.setLabel("configure");
  activeTab = configureTab;
  controlP5.setTabEventsActive(true);
  configureTab.activateEvent(true);
  runTab.activateEvent(true);

  //configuring the general UI l&f
  //the configuration UI

  setupRunConfig();
  setupChooperConfig();

  //configure the serial connection
  // List all the available serial ports:
  println(Serial.list());

  /*  I know that the first port in the serial list on my mac
   	is always my  Keyspan adaptor, so I open Serial.list()[0].
   	Open whatever port is the one you're using.
   	*/
  arduinoPort = new Serial(this, Serial.list()[0], 115200);
  smooth();
  setupData();
}

void draw() {
  background(graphBackgroundColor);
  drawData();
  decodeSerial();
}


void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup() && !settingStatus) {
    if ("microstepping".equals(theEvent.group().name())) { 
      microstepping((int)theEvent.group().value());
    } else 
    if ("direction".equals(theEvent.group().name())) {
      setDirection((int)theEvent.group().value());
    } else if ("decrement".equals(theEvent.group().name())) {
      setHysteresisDecrement((int)theEvent.group().value());
    }
  } 
  else if (theEvent.isTab()) {
    activeTab = theEvent.tab();
    println("Tab: "+activeTab.name());
  } 
  else if (theEvent.controller().name().equals("hysteresisrange")) {
    // min and max values are stored in an array.
    // access this array with controller().arrayValue().
    // min is at index 0, max is at index 1.
    setHysteresis(int(theEvent.controller().arrayValue()[0]), int(theEvent.controller().arrayValue()[1]));
  }
}

