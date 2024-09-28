#pragma once

#include <stdio.h>
#include <conio.h>
#include <stdio.h>
#include <windows.h>
#include<vector>
#include<string>
#include<thread>

#include <interface.h>
#include<warehouseWebServer.h>
#include<localControl.h>

#include <MqttClientManager.h>

#include <MQTT_client.h>

void startMQTTActuatorsOperation();
//void startMqttSensorsOperation();
void startMQTTSensorsOperation();
void monitorXAxis(MqttClientManager& mqttClientManager);
void monitorYAxis(MqttClientManager& mqttClientManager);
void monitorZAxis(MqttClientManager& mqttClientManager);
void monitorLeftStation(MqttClientManager& mqttClientManager);
void monitorRightStation(MqttClientManager& mqttClientManager);
void monitorCage(MqttClientManager& mqttClientManager);

///////////
// Handlers
void onMqttActuatorsConnectionLost(void* context, char* cause);
int onMqttActuatorsMessageArrived(void* context, char* topicName, int messageLen, MQTTAsync_message* message);