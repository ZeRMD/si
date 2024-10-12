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

#include<vector>
#include<string>

#include <nlohmann/json.hpp>

using json = nlohmann::json;

#include<chrono>
#include<thread>
bool MqttSystemIsRunning = true;

extern bool MqttSystemIsRunning;

#define MQTT_BROKER_URL  (const char *) "tcp://localhost:1883"

void onMqttActuatorsConnectFailure(void* context, MQTTAsync_failureData* response)
{
    printf("Mqtt Actuators connect FAILURE, rc = %d\n", response->code);

}

/*
void onMqttActuatorsConnectSuccess(void* context, MQTTAsync_successData* response)
{
    printf("Mqtt Actuators connect SUCCESS\n");
    MqttClientManager* client = (MqttClientManager*)context;
    std::vector<std::string> topics = { "menu_keyboard" };
    client->subscribe(topics, QOS_1, onMqttActuatorsConnectionLost, onMqttActuatorsMessageArrived, NULL);
}
*/

void onMqttActuatorsConnectSuccess(void* context, MQTTAsync_successData* response)
{
    printf("Mqtt Actuators connect SUCCESS\n");
    MqttClientManager* client = (MqttClientManager*)context;
    std::vector<std::string> topics = { "menu_keyboard", "actuator" };
    client->subscribe(topics, QOS_1, onMqttActuatorsConnectionLost, onMqttActuatorsMessageArrived, NULL);
}

void startMQTTActuatorsOperation() {
    // the static specifier below is to avoid the variable 
    // being declared in the stack, which is volatile. 
    static MqttClientManager mqttActuators;
    // it can be any unique identifier
    mqttActuators.create("actuators_client_id_1", MQTT_BROKER_URL);
    mqttActuators.connect(onMqttActuatorsConnectSuccess, onMqttActuatorsConnectFailure);
}

//**************************//
//Handlers
//**************************//

void onMqttActuatorsConnectionLost(void* context, char* cause) {
    printf("\nConnection lost\n");
    printf("     cause: %s\n", cause);
}

/*
int onMqttActuatorsMessageArrived(void* context, char* topicName, int messageLen, MQTTAsync_message* message)
{
    char* payload = (char*)message->payload;
    printf("\n received topic=%s, message=%s", topicName, (char*)(message->payload));

    if (strcmp(topicName, "menu_keyboard") == 0) {
        // mosquitto_pub -h localhost -p 1883 -t "menu_keyboard" -m "a"
        int key_command = payload[0];  // consider only the first character
        executeLocalControl(key_command);
    }
    return 1;
}
*/

//**************************//
// Atuadores
//**************************//

int onMqttActuatorsMessageArrived(void* context, char* topicName, int messageLen, MQTTAsync_message* message)
{
    char* payload = (char*)message->payload;

    if (strcmp(topicName, "menu_keyboard") == 0) {
        // mosquitto_pub -h localhost -p 1883 -t "menu_keyboard" -m "a"
        int key_command = payload[0];  // consider only the first character
        executeLocalControl(key_command);
    }
    else if (strcmp(topicName, "actuator") == 0) {
        try {
            json jsonMessage = json::parse(payload);

            printf(payload);

            std::string name = jsonMessage["name"];
            std::string value = jsonMessage["value"];

            printf("\nParsed JSON - name: %s, value: %s", name.c_str(), value.c_str());

            //*****************************************//
            // Control logic for the actuator motor_x
            //*****************************************//

            if (name == "motor_x") { // the class string has got operator ==
                int direction = std::stoi(value);  // Convert value to an integer
                if (direction == 0) { stopX(); } // if 
                if (direction == 1) { moveXRight(); } // else if
                if (direction == -1) { moveXLeft(); } // else if
            }

            //*****************************************//
            // Control logic for the actuator motor_y
            //*****************************************//

            if (name == "motor_y") { // the class string has got operator ==
                int direction = std::stoi(value);  // Convert value to an integer
                if (direction == 0) { stopY(); } // if 
                if (direction == 1) { moveYInside(); } // else if
                if (direction == -1) { moveYOutside(); } // else if
            }

            //*****************************************//
            // Control logic for the actuator motor_z
            //*****************************************//

            if (name == "motor_z") { // the class string has got operator ==
                int direction = std::stoi(value);  // Convert value to an integer
                if (direction == 0) { stopZ(); } // if 
                if (direction == 1) { moveZUp(); } // else if
                if (direction == -1) { moveZDown(); } // else if
            }

            //*****************************************//
            // Control logic for the actuator left station
            //*****************************************//

            if (name == "motor_ls") { // the class string has got operator ==
                int direction = std::stoi(value);  // Convert value to an integer
                if (direction == 0) { stopLeftStation(); } // if 
                if (direction == 1) { moveLeftStationInside(); } // else if
                if (direction == -1) { moveLeftStationOutside(); } // else if
            }

            //*****************************************//
            // Control logic for the actuator right station
            //*****************************************//

            if (name == "motor_rs") { // the class string has got operator ==
                int direction = std::stoi(value);  // Convert value to an integer
                if (direction == 0) { stopRightStation(); } // if 
                if (direction == 1) { moveRightStationInside(); } // else if
                if (direction == -1) { moveRightStationOutside(); } // else if
            }
            
        }
        catch (json::exception& e) {
            // Catch any errors during JSON parsing
            printf("\nError parsing JSON: %s", e.what());
        }
    }
    return 1;
}

//**************************//
// Sensores
//**************************//

void startMQTTSensorsOperation() {
    std::thread t([]() {
        printf("\nmonitoring sensors started...");
        MqttClientManager mqttMonitoring;
        mqttMonitoring.create("sensors_client_id_1", MQTT_BROKER_URL);
        mqttMonitoring.connect(NULL, NULL);

        // here, instead of doing this code after success connection handle 
        // we wait till successful connection
        // the program does not freeze here, because this is a new thread.
        printf("\nWaiting for mqtt monitoring_client_1 connection...");
        while (mqttMonitoring.isConnected() == false) {
            putchar('.');
            Sleep(1000);
        }
        while (MqttSystemIsRunning) {

            //**************************//
            // Monitoring de tudo
            //**************************//

            monitorXAxis(mqttMonitoring);
            monitorYAxis(mqttMonitoring);
            monitorZAxis(mqttMonitoring);
            monitorLeftStation(mqttMonitoring);
            monitorRightStation(mqttMonitoring);
            monitorCage(mqttMonitoring);
        }
        mqttMonitoring.disconnect();
        printf("\nmonitoring finishing...");
        });
    t.detach();
}

void monitorXAxis(MqttClientManager& mqttClientManager) {
    static auto lastTime = std::chrono::system_clock::now();
    auto currentTime = std::chrono::system_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - lastTime).count();

    static int previous_axis_position = -1, previous_axis_moving = -9999;

    //**************************//
    // Monitoring de x
    //**************************//
    int axisPosition = getXPosition();
    int axisMoving = getXDirection();

    char message[128] = "";
    // publish the x position info when: the position has changed, the movement has changed, and every 10 seconds.
    if ((axisPosition != previous_axis_position) || (axisMoving != previous_axis_moving) || (duration > 10000)) {
        sprintf(message, "{\"name\": \"x_is_at\", \"value\": \"%d\"}", axisPosition);
        previous_axis_position = axisPosition;
        lastTime = currentTime;
        mqttClientManager.publish(message, "sensor", QOS_1, NULL, NULL);
        sprintf(message, "{\"name\": \"x_moving\", \"value\": \"%d\"}", axisMoving);
        mqttClientManager.publish(message, "sensor", QOS_1, NULL, NULL);
        previous_axis_moving = axisMoving;
    }
}

void monitorYAxis(MqttClientManager& mqttClientManager) {
    static auto lastTime = std::chrono::system_clock::now();
    auto currentTime = std::chrono::system_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - lastTime).count();

    static int previous_axis_position = -1, previous_axis_moving = -9999;

    //**************************//
    // Monitoring de Y
    //**************************//
    int axisPosition = getYPosition();
    int axisMoving = getYDirection();

    char message[128] = "";
    // publish the y position info when: the position has changed, the movement has changed, and every 10 seconds.
    if ((axisPosition != previous_axis_position) || (axisMoving != previous_axis_moving) || (duration > 10000)) {
        sprintf(message, "{\"name\": \"y_is_at\", \"value\": \"%d\"}", axisPosition);
        previous_axis_position = axisPosition;
        lastTime = currentTime;
        mqttClientManager.publish(message, "sensor", QOS_1, NULL, NULL);
        sprintf(message, "{\"name\": \"y_moving\", \"value\": \"%d\"}", axisMoving);
        mqttClientManager.publish(message, "sensor", QOS_1, NULL, NULL);
        previous_axis_moving = axisMoving;
    }
}

void monitorZAxis(MqttClientManager& mqttClientManager) {
    static auto lastTime = std::chrono::system_clock::now();
    auto currentTime = std::chrono::system_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - lastTime).count();

    static float previous_axis_position = -1;
    static int previous_axis_moving = -9999;

    //**************************//
    // Monitoring de Z
    //**************************//
    float axisPosition = getZPosition();
    int axisMoving = getZDirection();

    char message[128] = "";
    // publish the z position info when: the position has changed, the movement has changed, and every 10 seconds.
    if ((axisPosition != previous_axis_position) || (axisMoving != previous_axis_moving) || (duration > 10000)) {
        sprintf(message, "{\"name\": \"z_is_at\", \"value\": \"%f\"}", axisPosition);
        previous_axis_position = axisPosition;
        lastTime = currentTime;
        mqttClientManager.publish(message, "sensor", QOS_1, NULL, NULL);
        sprintf(message, "{\"name\": \"z_moving\", \"value\": \"%d\"}", axisMoving);
        mqttClientManager.publish(message, "sensor", QOS_1, NULL, NULL);
        previous_axis_moving = axisMoving;
    }
}

void monitorLeftStation(MqttClientManager& mqttClientManager) {
    static auto lastTime = std::chrono::system_clock::now();
    auto currentTime = std::chrono::system_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - lastTime).count();

    static int previous_station_position = -1, previous_station_moving = -9999;

    //**************************//
    // Monitoring de Left Station
    //**************************//
    int stationPosition = isPartOnLeftStation();
    int stationMoving = getLeftStationDirection();

    char message[128] = "";
    // publish the y position info when: the position has changed, the movement has changed, and every 10 seconds.
    if ((stationPosition != previous_station_position) || (stationMoving != previous_station_moving) || (duration > 10000)) {
        sprintf(message, "{\"name\": \"ls_has_part\", \"value\": \"%d\"}", stationPosition);
        previous_station_position = stationPosition;
        lastTime = currentTime;
        mqttClientManager.publish(message, "sensor", QOS_1, NULL, NULL);
        sprintf(message, "{\"name\": \"ls_moving\", \"value\": \"%d\"}", stationMoving);
        mqttClientManager.publish(message, "sensor", QOS_1, NULL, NULL);
        previous_station_moving = stationMoving;
    }
}

void monitorRightStation(MqttClientManager& mqttClientManager) {
    static auto lastTime = std::chrono::system_clock::now();
    auto currentTime = std::chrono::system_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - lastTime).count();

    static int previous_station_position = -1, previous_station_moving = -9999;

    //**************************//
    // Monitoring de Right Station
    //**************************//
    int stationPosition = isPartOnRightStation();
    int stationMoving = getRightStationDirection();

    char message[128] = "";
    // publish the y position info when: the position has changed, the movement has changed, and every 10 seconds.
    if ((stationPosition != previous_station_position) || (stationMoving != previous_station_moving) || (duration > 10000)) {
        sprintf(message, "{\"name\": \"rs_has_part\", \"value\": \"%d\"}", stationPosition);
        previous_station_position = stationPosition;
        lastTime = currentTime;
        mqttClientManager.publish(message, "sensor", QOS_1, NULL, NULL);
        sprintf(message, "{\"name\": \"rs_moving\", \"value\": \"%d\"}", stationMoving);
        mqttClientManager.publish(message, "sensor", QOS_1, NULL, NULL);
        previous_station_moving = stationMoving;
    }
}

void monitorCage(MqttClientManager& mqttClientManager) {
    static auto lastTime = std::chrono::system_clock::now();
    auto currentTime = std::chrono::system_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(currentTime - lastTime).count();

    static bool previous_cage_location = false;

    //**************************//
    // Monitoring de Cage
    //**************************//
    bool cageLocation = isPartInCage();

    char message[128] = "";
    // publish the cage ocupancy info when: the ocupancy has changed, and every 10 seconds.
    if ((cageLocation != previous_cage_location) || (duration > 10000)) {
        sprintf(message, "{\"name\": \"part_in_cage\", \"value\": \"%d\"}", cageLocation);
        previous_cage_location = cageLocation;
        lastTime = currentTime;
        mqttClientManager.publish(message, "sensor", QOS_1, NULL, NULL);
    }
}
