/*Put your SSID & Password*/

#include <WiFi.h>
#include <HTTPClient.h>
 
const char* ssid = "EE-Hub-S6sd";  // Enter SSID here
const char* password = "Jane1970";  //Enter Password here
 
void setup() {
 
  Serial.begin(115200);
  WiFi.begin(ssid, password);
 
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi..");
  }
  Serial.println("Connected to the WiFi network");
}
 
void loop() {
 
  if ((WiFi.status() == WL_CONNECTED)) { //Check the current connection status
 
    HTTPClient http;
 
    http.begin("http://www.studio2.org.uk/scrollmusic.com/made-with-appgamekit.png"); //Specify the URL
    int httpCode = http.GET();                                        //Make the request
 
    if (httpCode > 0) { //Check for the returning code
      char buffer[32];
      int len = http.getSize();
      WiFiClient * stream = http.getStreamPtr();
      Serial.println("Size");
      Serial.println(len);
      while(http.connected() && len > 0) {
         // get available data size
        size_t size = stream->available();

        if(size) {
          // read up to 128 byte
          int c = stream->readBytes(buffer, (size > sizeof(buffer)) ? sizeof(buffer) : size);
          for (int i = 0;i < c;i++) {
            Serial.print((int(buffer[i])) & 0xFF);
            Serial.print(",");
          }
          Serial.println();

          if(len > 0) {
              len -= c;
          }
        }
        delay(1);
      }
    }
    else {
      Serial.println("Error on HTTP request");
    }
 
    http.end(); //Free the resources
  }
 
  delay(10000);
 
}