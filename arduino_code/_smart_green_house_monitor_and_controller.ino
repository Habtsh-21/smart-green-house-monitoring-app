
#include <SoftwareSerial.h>
#include <DHT.h>
#define DHTPIN 2
#define DHTTYPE DHT11
#define STATE_PIN 9

int moistureSensorPin = A0;
int moistureSensorValue = 0;
int tempratureValue = 0;
int humidityValue = 0;
int lightSensorPin = A1;
int lightSensorValue = 0;

int pump = 3;
int fan = 4;
int bulb = 5;


SoftwareSerial BTSerial(10, 11);  // RX, TX pins for Bluetooth
DHT dht(DHTPIN, DHTTYPE);


String receivedData = "";
String isItManual = "NO";




void autoControl() {
  moistureSensorValue = analogRead(moistureSensorPin);
  Serial.print("Moisture Level: ");
  Serial.println(moistureSensorValue);
  if (moistureSensorValue > 800) {
    digitalWrite(pump, HIGH);
  } else {
    digitalWrite(pump, LOW);
  }

  lightSensorValue = analogRead(lightSensorPin);
  Serial.print("Light Level: ");
  Serial.println(lightSensorValue);
  if (lightSensorValue < 100) {
    digitalWrite(bulb, HIGH);
  } else {
    digitalWrite(bulb, LOW);
  }

  float tempC = dht.readTemperature();
  float humidity = dht.readHumidity();

  if (isnan(tempC) || isnan(humidity)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  } else {

    Serial.print("Temperature: ");
    Serial.print(tempC);
    Serial.print(" °C / ");
    Serial.print("Humidity: ");
    Serial.print(humidity);
    Serial.println(" %");
    if (tempC > 30) {
      digitalWrite(fan, HIGH);
    } else {
      digitalWrite(fan, LOW);
    }
  }
}
String filterAlphabetic(String str) {
  String result = "";
  for (int i = 0; i < str.length(); i++) {
    if (isAlpha(str[i])) {
      result += str[i];
    }
  }
  return result;
}


void setup() {

  Serial.begin(9600);
  BTSerial.begin(9600);
  dht.begin();
  Serial.println("Arduino is Ready!");
  pinMode(STATE_PIN, INPUT);
  pinMode(moistureSensorPin, INPUT);
  pinMode(lightSensorPin, INPUT);
  pinMode(pump, OUTPUT);
  pinMode(fan, OUTPUT);
  pinMode(bulb, OUTPUT);
}



void loop() {

  if (digitalRead(STATE_PIN) == HIGH) {

    if (BTSerial.available()) {
      char receivedChar = BTSerial.read();
      if (receivedChar == '\n') {
        Serial.print("Received from Device: ");
        Serial.println(receivedData);
        receivedData = filterAlphabetic(receivedData);
        Serial.println(receivedData);

        if (receivedData == "YES") {
          isItManual = "YES";
        } else if (receivedData == "NO") {
          isItManual = "NO";
        } else {
          if (isItManual == "YES") {
            if (receivedData == "TemperatureON") {
              digitalWrite(fan, HIGH);
              Serial.println("high");
            } else if (receivedData == "TemperatureOFF") {
              digitalWrite(fan, LOW);
              Serial.println("low");
            } else if (receivedData == "MoistureON") {
              digitalWrite(pump, HIGH);
              Serial.println("high");
            } else if (receivedData == "MoistureOFF") {
              digitalWrite(pump, LOW);
              Serial.println("low");
            } else if (receivedData == "LightON") {
              digitalWrite(bulb, HIGH);
              Serial.println("high");
            } else if (receivedData == "LightOFF") {
              digitalWrite(bulb, LOW);
              Serial.println("low");
            }
          }
        }
        receivedData = "";
      } else {
        if (isAlpha(receivedChar)) {
          receivedData += receivedChar;
        }
      }
    }

  } else {
    autoControl();
    delay(1000);
  }
}
