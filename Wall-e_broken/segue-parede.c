#include "api_robot2.h"
#define MARGIN 200    // Define a margem de erro aceitada entre os sonares monitorados
#define AVG_DIST 600  //  Define a distanica media de inicio do segue parede
#define COLIDE_DIST 1400  // Define distancia para a callback de colisao
#define LFS 1   // Define o sonar esquerdo dianteiros a ser monitorado
#define LRS 14   // Define o sonar esquerdo traseiro a ser monitorado
#define FORWARD_SPEED 20  // Define a velocidade com que se desloca para frente
#define TURN_SPEED 6  // Define a velocidade de faz curvas

void encontra_parede(void);
void segue_parede(void);
void take_left(void);           // Vira para a parede
void take_right(void);          // Vira para longe da parede
void imminent_collision(void);  // Trata possiveis colisoes


int main(void){
  encontra_parede();   // Vai reto ate achar uma parede
  segue_parede();      // Segue a parade baseado na distancia media definida
}

void encontra_parede(void){
    motor_cfg_t m0, m1;
    int sonar0;
    // Anda em linha reta
    m0.id = 0;
    m0.speed = FORWARD_SPEED;
    m1.id = 1;
    m1.speed = FORWARD_SPEED;
    set_motors_speed(&m0, &m1);

    // Em loop ate encontrar uma parede em sua frente
    while((read_sonar(3) > AVG_DIST)&&(read_sonar(4) > AVG_DIST)){}

    // Vira para direita
    m0.speed = 0;
    m1.speed = 10;
    set_motors_speed(&m0, &m1);

    // Em loop ate alinhar o lado esquerdo com a parede
    do{
      sonar0 = read_sonar(0);
    }while(sonar0 > AVG_DIST);

    // Inicia a trajetoria pela parede
    m0.speed = FORWARD_SPEED;
    m1.speed = FORWARD_SPEED;
    set_motors_speed(&m0, &m1);

    return;
}

void segue_parede(void){
    // register_proximity_callback(COLIDE_SONAR, COLIDE_DIST, imminent_collision);
    int sonar0, sonar_front;

    while(1){
      sonar_front = read_sonar(3);
      sonar0 = read_sonar(0);

      if(sonar_front <= COLIDE_DIST){
          imminent_collision();
      }else if (sonar0 >= (AVG_DIST + MARGIN)){
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
      sonarLR = read_sonar(LRS);
      sonarLF = read_sonar(LFS);
    }while(sonarLF > (sonarLR + (MARGIN)));

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
      sonarLF = read_sonar(LFS);
    }while(sonarLR > (sonarLF - (MARGIN)));

    // Continua a trajetoria
    m0.speed = FORWARD_SPEED;
    m1.speed = FORWARD_SPEED;
    set_motors_speed(&m0, &m1);

    return;
}

void imminent_collision(void){
  int sonarLF;
  motor_cfg_t m0, m1;
  m0.id = 0;
  m0.speed = 0;
  m1.id = 1;
  m1.speed = 5;

  set_motors_speed(&m0, &m1); // Gira o Uoli para a direita

  // Loop para esperar o Uoli ajustar a angulacao
  do{
    sonarLF = read_sonar(3);
  }while(sonarLF < (COLIDE_DIST + MARGIN));

  // Continua a trajetoria
  m0.speed = FORWARD_SPEED;
  m1.speed = FORWARD_SPEED;
  set_motors_speed(&m0, &m1);

  return;
}
