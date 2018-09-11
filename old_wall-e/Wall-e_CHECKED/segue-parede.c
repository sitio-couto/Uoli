#include "api_robot2.h"
#define MARGIN 200
#define AVG_DIST 800

void encontra_parede(void);
void segue_parede(void);
void get_close(void);
void get_away(void);


int main(void){
  encontra_parede();   // Vai reto ate achar uma parede
  segue_parede();   // Segue a parade baseado na distancia media definida
}

void encontra_parede(void){
    motor_cfg_t m0, m1;

    // Anda em linha reta
    m0.id = 0;
    m0.speed = 60;
    m1.id = 1;
    m1.speed = 60;
    set_motors_speed(&m0, &m1);

    // Em loop ate encontrar uma parede em sua frente
    while((read_sonar(3) > AVG_DIST)&&(read_sonar(4) > AVG_DIST)){}

    // Vira para direita
    m0.speed = 0;
    m1.speed = 10;
    set_motors_speed(&m0, &m1);

    // Em loop ate alinhar o lado esquerdo com a parede
    while(read_sonar(0) > AVG_DIST){}

    // Inicia a trajetoria pela parede
    m0.speed = 30;
    m1.speed = 30;
    set_motors_speed(&m0, &m1);

    return;
}

void segue_parede(void){
    motor_cfg_t m0, m1;
    int diff;

    while(1){
      diff = read_sonar(0) - AVG_DIST;
      if(diff > MARGIN){
        get_close();
      }if(diff < (-MARGIN)){
        get_away();
      }
    }
}

void get_close(void){
    int turningTime = 0;
    int leftSonars[4] = {0, 0, 0, 0}; // Espaco para armazenar os sonares 13, 14, 1 e 2
    motor_cfg_t m0, m1;
    m0.id = 0;
    m0.speed = 5;
    m1.id = 1;
    m1.speed = 0;

    set_motors_speed(&m0, &m1); // Gira o Uoli de frente para parede
    // set_time(0);  // Zera o tempo para cronometrar o tempo de rotacao

    // Loop para esperar o Uoli ajustar a angulacao
    do{
      read_sonars(13, 14, leftSonars);  // Pega os sonares 13 e 14
      read_sonars(1, 2, &(leftSonars[2]));  // Pega os sonares 1 e 2
    }while((leftSonars[0] <= leftSonars[3])||(leftSonars[1] <= leftSonars[2]));

    // Aproxima-se lentamente da parede
    m0.speed = 10;
    m1.speed = 10;
    set_motors_speed(&m0, &m1);

    // Alinha-se com a parede do lado esquerdo
    do{
      read_sonars(0, 0, leftSonars);  // Pega os sonares 13 e 14
    }while(leftSonars[0] <= AVG_DIST );

    // Retoma trajetoria
    m0.speed = 20;
    m1.speed = 20;
    set_motors_speed(&m0, &m1);

    return;
}

void get_away(void){
  return;
}
