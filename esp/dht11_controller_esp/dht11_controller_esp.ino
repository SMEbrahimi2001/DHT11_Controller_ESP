#include <WiFi.h>
#include <WebServer.h>
#include <DHT.h>

// *** Difine DHT Variables ***
#define DHTPIN 2
#define DHTTYPE DHT11

DHT dht(DHTPIN, DHTTYPE);
// *** ***

// *** Wifi Controll ***
const char* ssid = "S.M.E";
const char* password = "@Sme2001";

WebServer server(80);
// *** ***

// *** Relay Variable ***
int relayPin = 13;
bool relayStatus = false;
// *** ***

void getStatus() {

  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();

  // if (isnan(temperature) || isnan(humidity)) {

  //   server.send(
  //     500,
  //     "application/json",
  //     "{\"error\":\"DHT read failed\"}"
  //   );

  //   return;
  // }

  String json = "{";

  json += "\"relay\":";
  json += relayStatus ? "true" : "false";
  json += ",";
  if(isnan(temperature)) {
    json += "\"temperature\":";
    json += String(00.0,1);
    json += ",";
  } else {
    json += "\"temperature\":";
    json += String(temperature, 1);
    json += ",";
  }
  
  if(isnan(humidity)) {
    json += "\"humidity\":";
    json += String(00.0,1);
  } else {
    json += "\"humidity\":";
    json += String(humidity, 1);
  }
  json += "}";

  server.send(
    200,
    "application/json",
    json
  );
}

void turnOnRelay (){
  relayStatus = true;

  digitalWrite(relayPin, LOW);

  server.send(200, "text/plain", "Relay ON");
}

void turnOffRelay() {
  relayStatus = false;

  digitalWrite(relayPin, HIGH);

  server.send(200, "text/plain", "Relay OFF");
}


void setup() {
  Serial.begin(115200);

  // # difine variables ***
  pinMode(relayPin, OUTPUT);

  // *** ***

  dht.begin();

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }

  Serial.println(WiFi.localIP());

  server.on("/status", getStatus);
  server.on("/relay/on", turnOnRelay);
  server.on("/relay/off", turnOffRelay);

  server.begin();
}

void loop() {
  server.handleClient();
}