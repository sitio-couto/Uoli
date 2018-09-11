#include "api_robot2.h"

// Constantes para facilitar a alteracao de valores
#define COLLIDE_DIST 1200   // Define distancia minima para evitar colisoes frontais
#define COLLIDE_SPEED 10    // Define velocidade de curva quando ajusta curso devido a possivel colisao
#define FORWARD_SPEED 30    // Define velocidade em linhas retas
#define TURN_SPEED 32       // Define velocidade para a cuva do alarme
#define TURN_TIME 350       // Define o intervalo de tempo da curva do alarme
#define TURN_SAFE_DIST 700  // Define uma distancia minima para evitar colisoes durante a curva de alarme

void turn(void);
void turn_radar_3(void);
void turn_radar_4(void);
void turn_alarm(void);
void avoid_collision(void);

int increasing_time = 1;    // Aumenta o tempo que leva para realizar cada curva

int main(void){
    motor_cfg_t m0, m1;
    m0.id = 0;
    m1.id = 1;
    m1.speed = FORWARD_SPEED;
    m0.speed = FORWARD_SPEED;

    // Registra callbacks para evitar colisao
    register_proximity_callback(3, COLLIDE_DIST, turn_radar_3);
    register_proximity_callback(4, COLLIDE_DIST, turn_radar_4);

    // Adiciona o alarme responsavel pelas curvas em tempo crescente
    add_alarm(turn_alarm, increasing_time);

    set_motors_speed(&m0, &m1);

    while(1){}  // Mantem um loop enquanto as callbacks cuidam do resto
}

// Funcao intermediaria para callbacks
void turn_radar_3(void){
    avoid_collision();
    register_proximity_callback(3, COLLIDE_DIST, turn_radar_3);
}

// Funcao intermediaria para callbacks pelo sonar 4 (reseta a proximity_callbacks do sonar 4)
void turn_radar_4(void){
    avoid_collision();
    register_proximity_callback(4, COLLIDE_DIST, turn_radar_4);
}

// Funcao intermediaria para callbacks (rseta o alarme e incrementa o temporizador)
void turn_alarm(){
    turn();
    set_time(0);

    // Dado que o tempo eh sempre incrementado na chamada do alarme, ele sempre
    // passa por 50.  Quando 50, subtrai-se 49 para voltar a 1.
    if(increasing_time >= 50){
        increasing_time -= 49;
    }

    add_alarm(turn_alarm, ++increasing_time);
}

// Funcao para realizar uma curva cronometrada proxima de 90 graus
void turn(void){
    int current_time = 0; // Recupera o tempo atual
    int desired_time = TURN_TIME; // Define o tempo para realizar a curva
    motor_cfg_t m0, m1;

    // Configura velocidades para realizar a curva
    m0.id = 0;
    m0.speed = 0;
    m1.id = 1;
    m1.speed = 63;

    // Antes da curva, verifica se ha espaco para realiza-la, se nao,, retorna
    if(read_sonar(7) < TURN_SAFE_DIST){
      return;
    }

    set_motors_speed(&m0, &m1); // Inicia a curva
    set_time(0);  // Zera o tempo para a cronometragem

    // Mantem a curva pelo tempo definido
    while(1){
      get_time(&current_time);

      if(current_time >= desired_time){
        break;
      }
    }

    // Finaliza a curva e volta a andar reto
    m0.id = 0;
    m0.speed = FORWARD_SPEED;
    m1.id = 1;
    m1.speed = FORWARD_SPEED;

    set_motors_speed(&m0, &m1);

    return;
}

// Funcao para evitar colisoes frontais
void avoid_collision(void){
    int sonar3, sonar4;
    motor_cfg_t m0, m1;

    // Desvia para a direita
    m0.id = 0;
    m0.speed = 0;
    m1.id = 1;
    m1.speed = COLLIDE_SPEED;

    set_motors_speed(&m0, &m1);

    // Vira ate nao houver mais obstrucoes a frente
    do{
      sonar3 = read_sonar(3);
      sonar4 = read_sonar(4);
    }while((sonar3 < COLLIDE_DIST)||(sonar4 < COLLIDE_DIST));

    // Volta a andar reto
    m0.speed = FORWARD_SPEED;
    m1.speed = FORWARD_SPEED;

    set_motors_speed(&m0, &m1);

    return;
}
