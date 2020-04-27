// ****************************************************************************
// ****************************************************************************
//
//		Name:		espvideo.cpp
//		Purpose:	HTML Downloader
//		Created:	27th April 2020
//		Author:		Paul Robson (paul@robsons.org.uk)
//					based on code by Fabrizio Di Vittorio
//
// ****************************************************************************
// ****************************************************************************

#include "espinclude.h"

static WORD16 _HWDownloadCopyFile(HTTPClient &http,char *target);
static WORD16 _HWConnectWifi(char *ssid,char *password);

// ****************************************************************************
//
//							Download URL to target
//
// ****************************************************************************

WORD16 HWDownloadHandler(char *url,char *target,char *ssid,char *password) {
	WORD16 errorCode = 3;
	HTTPClient http;
	fabgl::suspendInterrupts();
	if (_HWConnectWifi(ssid,password)) {
		Serial.print("Accessing ");Serial.println(url);
		http.begin(url);
		int httpCode = http.GET();
		errorCode = 3;
		if (httpCode == HTTP_CODE_OK) {
			errorCode = _HWDownloadCopyFile(http,target);
		}
	}	
	fabgl::resumeInterrupts();
	Serial.print("Return code ");Serial.println(errorCode);
	return errorCode;
}

// ****************************************************************************
//
//						Physically download the file
//
// ****************************************************************************

static WORD16 _HWDownloadCopyFile(HTTPClient &http,char *target) {
	int errorCode = 4;
	char buf[128];
	sprintf(buf,"/%s",target);
	Serial.print("Opening ");Serial.println(buf);
	File file = SPIFFS.open(buf,FILE_WRITE);					// Open to write
	if (file) {
		Serial.println("File opened");
		int len = http.getSize();
		WiFiClient * stream = http.getStreamPtr();
		int dsize = 0;
		while (http.connected() && (len > 0 || len == -1)) {
			size_t size = stream->available();
			if (size) {
				int c = stream->readBytes(buf, fabgl::imin(sizeof(buf), size));
				Serial.print("Read bytes ");Serial.println(c);
				for (int i = 0;i < c;i++) file.write(buf[i]);
				dsize += c;
				if (len > 0) len -= c;
			}
		}
		file.close();
		errorCode = (len == 0 || (len == -1 && dsize > 0)) ? 0 : 2;
	}
	return errorCode;
}

// ****************************************************************************
//
//								Wifi connection
//
// ****************************************************************************

static WORD16 _HWConnectWifi(char *ssid,char *password) {
	char temp[64];
	sprintf(temp,"; Connecting to %s password %s",ssid,password);
	Serial.println(temp);
	WiFi.begin(ssid, password);
	for (int i = 0; i < 12 && WiFi.status() != WL_CONNECTED; ++i) {
		delay(500);    
	}    
	sprintf(temp,"; Connected ? %d",WiFi.status() == WL_CONNECTED);
	Serial.println(temp);
	return WiFi.status() == WL_CONNECTED;
}
