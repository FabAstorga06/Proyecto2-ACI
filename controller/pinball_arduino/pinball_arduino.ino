#include <SoftwareSerial.h>

/********************************************************/
SoftwareSerial bluetooth(10, 11); // RX, TX

//Señales analogicas
const int reset = 12;
const int trasmitter = A2;
const int hit_sensor2 = A1;
const int hit_sensor1 = A0;

//Variables
bool loser_flag = false;
int reset_data, trasmitter_data, hit_data1, hit_data2; 

/********************************************************/
void setup() {
  pinMode(reset, INPUT);
  bluetooth.begin(9600);   
}

/********************************************************/
void loop() {  

  /* Se capturan valores de los sensores */
  reset_data = digitalRead(reset);
  trasmitter_data = analogRead(trasmitter);
  hit_data1 = analogRead(hit_sensor1);
  hit_data2 = analogRead(hit_sensor2);  
  sendDataToApp(); 
  
}

/********************************************************/

//Verifica si existen cambios en los sensores para enviar datos
void sendDataToApp() {
      //Si se resetea el juego por boton
     if (reset_data == 1) {
         sendmsg(3);
     } 
    //Si cambia el valor del infrarrojo
     if (trasmitter_data > 100) sendmsg(2);
  
     //Si cambia el valor del sensor golpe 1
     if (hit_data1 >= 250) sendmsg(hit_data1);
          
     //Si cambia el valor del sensor golpe 2
     if (hit_data2 >= 350) sendmsg(0);
}

//Envia datos a la aplicacion en processing
void sendmsg(int pdata) {
    bluetooth.write(pdata);
    delay(500); 
  
}

