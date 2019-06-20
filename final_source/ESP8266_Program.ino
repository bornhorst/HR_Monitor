/*	ESP8266 Application
	ECE-540 Winter 2019
	By: Alex Olson, Andrew Capatina, Ryan Bentz, and Ryan Bornhorst
	
	The program handles the ESP8266 interface with the FPGA. The FPGA
	is connected to the ESP8266 via a 2-wire serial connection. The FPGA
	drives the clock signal and sends data out 1 bit at a time.
	The ESP8266 program listens for the rising edge of the clock line and
	records the bit state. Once 16 bits are transferred, the program splits
	the 16-bit word into two bytes. The first byte is a tag byte that identifies
	the appropriate member in the Firebase to update and the second is the
	data to update.
	
	This program makes use of the following libraries:
	- 	ESP8266 Core for Arduino
		https://github.com/esp8266/Arduino
		
	-	Firebase Arduino
		https://github.com/FirebaseExtended/firebase-arduino
		
	-	ArduinoJSON JSON library for Arduino and IoT
		https://github.com/bblanchon/ArduinoJson
		
*/
#include <WiFiServerSecure.h>
#include <BearSSLHelpers.h>
#include <ESP8266WiFiScan.h>
#include <WiFiUdp.h>
#include <WiFiServerSecureAxTLS.h>
#include <ESP8266WiFiSTA.h>
#include <ESP8266WiFiGeneric.h>
#include <ESP8266WiFi.h>
#include <ESP8266WiFiType.h>
#include <CertStoreBearSSL.h>
#include <ESP8266WiFiMulti.h>
#include <WiFiServer.h>
#include <WiFiClientSecureAxTLS.h>
#include <ESP8266WiFiAP.h>
#include <WiFiServerSecureBearSSL.h>
#include <WiFiClientSecureBearSSL.h>
#include <WiFiClientSecure.h>
#include <WiFiClient.h>

#include <FirebaseError.h>
#include <FirebaseArduino.h>
#include <Firebase.h>
#include <FirebaseObject.h>
#include <FirebaseHttpClient.h>
#include <FirebaseCloudMessaging.h>


#define FIREBASE_HOST "finalproject-b0a5c.firebaseio.com"
#define FIREBASE_AUTH ""

#define WIFI_SSID_HOME "Lando's Wifi"
#define WIFI_PASSWORD_HOME "blahblah"

#define WIFI_SSID_MOBILE "Galaxy S5 8370"
#define WIFI_PASSWORD_MOBILE "kpjc3158"

#define PATH_HRATE "rate"
#define PATH_CurrentBPM "currentBPM"
#define PATH_MaxBPM "maxBPM"
#define PATH_MinBPM "minBPM"
#define PATH_realBEAT "realBeat"

#define PIN_CLK D1      // D0
#define PIN_DATA D0     // D1
#define PIN_LED D2      // D2
#define INT_LED D3     // D3
#define PIN_DATA D4    // D4


#define TAG_CUR 3
#define TAG_MAX 2
#define TAG_MIN 1
#define TAG_REAL 0

// Class objects
FirebaseArduino fb;

// Global data members
int currentBPM;
int maxBPM;
int minBPM;
int realBeat;
int heartRate;

volatile short data;
volatile byte bitCount;
volatile byte ledState;


// PROGRAM SETUP
void setup() {
  
	// Set up Serial port for debugging
	Serial.begin(9600);
	delay(500);

	// Initialize GPIO pins
	pinMode(PIN_LED, OUTPUT);
	pinMode(INT_LED, OUTPUT);
	pinMode(PIN_CLK, INPUT);
	pinMode(PIN_DATA, INPUT);

	// Connect to local WIFI
	//WiFi.begin(WIFI_SSID_HOME, WIFI_PASSWORD);
	WiFi.begin(WIFI_SSID_MOBILE, WIFI_PASSWORD_MOBILE);
	Serial.print("connecting");
	while (WiFi.status() != WL_CONNECTED) {
		Serial.print(".");
		delay(250);
	}
	Serial.println();
	Serial.print("connected: ");
	Serial.println(WiFi.localIP());

	// Firebase Connection Initialize
	Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);

	// Setup interrupt for clock pin
	// Pin:	PIN_CLK
	// ISR: readBits
	// Trigger: Rising Edge
	attachInterrupt(PIN_CLK, readBits, RISING);

	// Setup bitCount on startup
	bitCount = 0;
	ledState = 0;

	// Initialize beat flag in Firebase
	realBeat = 0;
	Firebase.setInt(PATH_realBEAT, realBeat);
	if (Firebase.failed())
	{
	  Serial.print("Write failed.");
	  Serial.println(Firebase.error());
	}
}


// MAIN CONTROL
void loop() {

	char tagByte;
	char dataByte;

	// Perpetually wait for the counter to reach the limit before we serve the data
	while (bitCount < 16) {};
	bitCount = 0;

	// We have read in 16 bits, now process the data
	tagByte = (data >> 8) & 0xFF;
	dataByte = data & 0xFF;

	// Toggle the LED to indicate data was recieved
	if (ledState)
	{
		digitalWrite(INT_LED, HIGH);
		ledState = 0;
	}
	else
	{
		digitalWrite(INT_LED, LOW);
		ledState = 1;
	}
	
	// Debug print
	Serial.print(tagByte);
	Serial.print(dataByte);

	// Write Current BPM
	if (tagByte == TAG_CUR)
	{
		Firebase.setInt(PATH_CurrentBPM, 0);
		if (Firebase.failed())
		{
			Serial.print("Write failed.");
			Serial.println(Firebase.error());
		}
	}
	
	// Write Max BPM
	else if (tagByte == TAG_MAX)
	{
		Firebase.setInt(PATH_MaxBPM, 0);
		if (Firebase.failed())
		{
		  Serial.print("Write failed.");
		  Serial.println(Firebase.error());
		}
	}
	
	// Write Min BPM
	else if (tagByte == TAG_MIN)
	{
		Firebase.setInt(PATH_MinBPM, 0);
		if (Firebase.failed())
		{
		  Serial.print("Write failed.");
		  Serial.println(Firebase.error());
		}
	}
	
	// Write Real Beat
	else if (tagByte == TAG_REAL)
	{
		Firebase.setInt(PATH_realBEAT, 0);
		if (Firebase.failed())
		{
		  Serial.print("Write failed.");
		  Serial.println(Firebase.error());
		}
	}
 
}

// Interrupt Service Routine for clock pin
// Read the bit from the Master on every rising clock edge
void readBits(){

	// shift the received bits and OR the new bit off
	// the data line into the word
	data = (data << 1) | digitalRead(PIN_DATA);
	bitCount++;
}


// Blink LED on receiving a word
void blinkLED(){
	static int state = 0;

	if (state)
	{
		digitalWrite(PIN_LED, HIGH);
		state = 0;
	}
	else
	{
		digitalWrite(PIN_LED, LOW);
		state = 1;
	}
}
