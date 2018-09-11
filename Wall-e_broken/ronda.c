#include "api_robot2.h"

#define COLLIDE_DIST 800
#define COLLID_SPEED 20
#define TURN_TIMER 5000

void turn(void);
void turn_radar_3(void);
void turn_radar_4(void);
void turn_alarm(void);

int increasing_time = 3;

int main(void){
  motor_cfg_t m0, m1;
  m0.id = 0;
  m1.id = 1;
  m1.speed = 63;
  m0.speed = 63;
  // Registra callbacks para evitar colisao
  register_proximity_callback(3, COLLIDE_DIST, turn_radar_3);
  register_proximity_callback(4, COLLIDE_DIST, turn_radar_4);
  add_alarm(turn_alarm, increasing_time);

  set_motors_speed(&m0, &m1);

  while(1){}  // Mantem um loop enquanto as callbacks cuidam do resto
}

void turn_radar_3(void){
  turn();
  register_proximity_callback(3, COLLIDE_DIST, turn_radar_3);
  set_time(0);
}

void turn_radar_4(void){
  turn();
  register_proximity_callback(4, COLLIDE_DIST, turn_radar_4);
  set_time(0);
}

void turn_alarm(){
  turn();
  set_time(0);
  add_alarm(turn_alarm, ++increasing_time);
}


void turn(void){
  int current_time = 0;
  int desired_time = TURN_TIMER;
  motor_cfg_t m0, m1;
  m0.id = 0;
  m0.speed = 0;
  m1.id = 1;
  m1.speed = 63;

  set_motors_speed(&m0, &m1);
  set_time(0);

  while(1){
    get_time(&current_time);

    if(current_time >= desired_time){
      break;
    }
  }

  m0.id = 0;
  m0.speed = 36;
  m1.id = 1;
  m1.speed = 36;
  set_motors_speed(&m0, &m1);


  return;
}
