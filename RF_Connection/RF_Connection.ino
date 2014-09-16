#include <RFduinoBLE.h>

// shows when the RFduino is advertising or not
int sending_led = 3;

// goes on when the RFduino has a connection, off on disconnect
int connection_led = 2;

void setup()
{
  // led used to indicate that the RFduino is advertising
  pinMode(sending_led, OUTPUT);
  //digitalWrite(sending_led, HIGH);
  
  // led used to indicate that the RFduino is connected
  pinMode(connection_led, OUTPUT);
  //digitalWrite(connection_led, HIGH);
  
  // start the BLE stack
  RFduinoBLE.begin();

    // switch to lower power mode
  RFduino_ULPDelay(INFINITE);
}

void loop() 
{
}

void RFduinoBLE_onAdvertisement(bool start)
{
}

void RFduinoBLE_onReceive(char *data, int len) {
  
  char buf[5] = {'h', 'e', 'l', 'l', 'o' };
  RFduinoBLE.send(buf, 5);
  
  digitalWrite(sending_led, HIGH);
  delay(500);
  digitalWrite(sending_led, LOW);
}

void RFduinoBLE_onConnect()
{
  digitalWrite(connection_led, HIGH);

}

void RFduinoBLE_onDisconnect()
{
  digitalWrite(connection_led, LOW);
}
