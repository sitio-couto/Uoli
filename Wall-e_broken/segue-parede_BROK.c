#include "api_robot2.h"
#define MARGIN 200    // Define a margem de erro aceitada entre os sonares monitorados
#define AVG_DIST 652  //  Define a distanica media de inicio do segue parede
#define COLLISION_DIST 1000 // Define uma distancia de colisao
#define COLLISION_SONAR 3
#define LFS 1   // Define o sonar esquerdo frontar a ser monitorado
#define LRS 14   // Define o sonar esquerdo traseiro a ser monitorado
#define FORWARD_SPEED 20
#define TURN_SPEED 3

void encontra_parede(void);
void segue_parede(void);
void take_left(void);
void take_right(void);
void name(void);
void imminent_colision(void);


int main(void){
  encontra_parede();   // Vai reto ate achar uma parede
  segue_parede();   // Segue a parade baseado na distancia media definida
}

void encontra_parede(void){
    motor_cfg_t m0, m1;
    int sonarLF, sonarLR;
    // Anda em linha reta
    m0.id = 0;
    m0.speed = FORWARD_SPEED;
    m1.id = 1;
    m1.speed = FORWARD_SPEED;
    set_motors_speed(&m0, &m1);

    // Em loop ate encontrar uma parede em sua frente
    while((read_sonar(3) > (AVG_DIST + MARGIN))&&(read_sonar(4) > (AVG_DIST+ MARGIN))){}

    // Vira para direita
    m0.speed = 0;
    m1.speed = 10;
    set_motors_speed(&m0, &m1);

    // Em loop ate alinhar o lado esquerdo com a parede
    do{
      sonarLF = read_sonar(LFS);
      sonarLR = read_sonar(LRS);
    }while(sonarLR > sonarLF);

    // Inicia a trajetoria pela parede
    m0.speed = FORWARD_SPEED;
    m1.speed = FORWARD_SPEED;
    set_motors_speed(&m0, &m1);

    return;
}

void segue_parede(void){
    int sonar0, sonar3;
    register_proximity_callback(COLLISION_SONAR, COLLISION_DIST, imminent_colision);


    while(1){
      sonar0 = read_sonar(0);
      if (sonar0 >= (AVG_DIST + MARGIN)){
          take_left();
      }else if (sonar0 <= (AVG_DIST - MARGIN)){
          take_right();
      }
    }
}

void take_left(void){
    int sonarLF, sonarLR;
    motor_cfg_t m0, m1;
    m0.id = 0;
    m0.speed = TURN_SPEED;
    m1.id = 1;
    m1.speed = 0;

    set_motors_speed(&m0, &m1); // Gira o Uoli para a esquerda

    // Loop para esperar o Uoli ajustar a angulacao
    do{
      sonarLR = read_sonar(0);
      sonarLF = read_sonar(LFS);
    }while(sonarLR < (sonarLF+ MARGIN));

    // Continua a trajetoria
    m0.speed = FORWARD_SPEED;
    m1.speed = FORWARD_SPEED;
    set_motors_speed(&m0, &m1);

    return;
}

void take_right(void){
    int sonarLF, sonarLR;
    motor_cfg_t m0, m1;
    m0.id = 0;
    m0.speed = 0;
    m1.id = 1;
    m1.speed = TURN_SPEED;

    set_motors_speed(&m0, &m1); // Gira o Uoli para a direita

    // Loop para esperar o Uoli ajustar a angulacao
    do{
      sonarLR = read_sonar(LRS);
      sonarLF = read_sonar(0);
    }while(sonarLF < (sonarLR + MARGIN));

    // Continua a trajetoria
    m0.speed = FORWARD_SPEED;
    m1.speed = FORWARD_SPEED;
    set_motors_speed(&m0, &m1);

    return;
}

void imminent_colision(void){
  int sonarLF;
  motor_cfg_t m0, m1;
  m0.id = 0;
  m0.speed = 0;
  m1.id = 1;
  m1.speed = TURN_SPEED;

  set_motors_speed(&m0, &m1); // Gira o Uoli para a direita

  // Loop para esperar o Uoli ajustar a angulacao
  do{
    sonarLF = read_sonar(COLLISION_SONAR);
  }while(sonarLF < (AVG_DIST));

  register_proximity_callback(COLLISION_SONAR, COLLISION_DIST, imminent_colision);

  // Continua a trajetoria
  m0.speed = FORWARD_SPEED;
  m1.speed = FORWARD_SPEED;
  set_motors_speed(&m0, &m1);

  return;
}







// #include "api_robot2.h"
// #define MARGIN 200
// #define AVG_DIST 500
//
// void encontra_parede(void);
// void segue_parede(void);
// void get_close(void);
// void get_away(void);
//
//
// int main(void){
//   encontra_parede();   // Vai reto ate achar uma parede
//   segue_parede();   // Segue a parade baseado na distancia media definida
// }
//
// void encontra_parede(void){
//     motor_cfg_t m0, m1;
//
//     // Anda em linha reta
//     m0.id = 0;
//     m0.speed = 60;
//     m1.id = 1;
//     m1.speed = 60;
//     set_motors_speed(&m0, &m1);
//
//     // Em loop ate encontrar uma parede em sua frente
//     while((read_sonar(TURN_SPEED) > AVG_DIST)&&(read_sonar(4) > AVG_DIST)){}
//
//     // Vira para direita
//     m0.speed = 0;
//     m1.speed = 10;
//     set_motors_speed(&m0, &m1);
//
//     // Em loop ate alinhar o lado esquerdo com a parede
//     while(read_sonar(0) > AVG_DIST){}
//
//     // Inicia a trajetoria pela parede
//     m0.speed = FORWARD_SPEED;
//     m1.speed = 30;
//     set_motors_speed(&m0, &m1);
//
//     return;
// }
//
// void segue_parede(void){
//     motor_cfg_t m0, m1;
//     int diff;
//
//     while(1){
//       diff = read_sonar(0) - AVG_DIST;
//       if(diff > MARGIN){
//         get_close();
//       }if(diff < (-MARGIN)){
//         get_away();
//       }
//     }
// }
//
// void get_close(void){
//     int turningTime = 0;
//     int leftSonars[2] = {0, 0}; // Espaco para armazenar os sonares 13, 14, 1 e 2
//     motor_cfg_t m0, m1;
//     m0.id = 0;
//     m0.speed = 5;
//     m1.id = 1;
//     m1.speed = 0;
//
//     set_motors_speed(&m0, &m1); // Gira o Uoli de frente para parede
//     // set_time(0);  // Zera o tempo para cronometrar o tempo de rotacao
//
//     // Loop para esperar o Uoli ajustar a angulacao
//     do{
//       leftSonars[0] = read_sonar(14);
//       leftSonars[1] = read_sonar(1);
//     }while(leftSonars[0] <= (leftSonars[1] - MARGIN));
//
//     // Aproxima-se lentamente da parede
//     m0.speed = 10;
//     m1.speed = 10;
//     set_motors_speed(&m0, &m1);
//
//     // Alinha-se com a parede do lado esquerdo
//     do{
//       leftSonars[0] = read_sonar(0);  // Pega os sonares 13 e 14
//     }while(leftSonars[0] > AVG_DIST - (MARGIN/2) );
//
//     // Retoma trajetoria
//     m0.speed = 20;
//     m1.speed = 20;
//     set_motors_speed(&m0, &m1);
//
//     return;
// }
//
// void get_away(void){
//   return;
// }
