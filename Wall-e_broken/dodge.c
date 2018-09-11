#include "api_robot2.h"

void loop_teste(void);
void stop_definitive(void);
void stop(void);
void stop_radar_3(void);
void stop_radar_4(void);

int main(void){
  int dist_front;

  motor_cfg_t m0, m1;
  m0.id = 0;
  m0.speed = 63;
  m1.id = 1;
  m1.speed = 63;

  set_motors_speed(&m0, &m1);

  // add_alarm(stop_definitive, 100);
  register_proximity_callback(3, 1000, stop_radar_3);
  register_proximity_callback(4, 1000, stop_radar_4);
  // register_proximity_callback(3, 1000, loop_teste);


  while(1){

  }
}

void stop_radar_3(void){
  stop();
  register_proximity_callback(3, 1000, stop_radar_3);
}

void stop_radar_4(void){
  stop();
  register_proximity_callback(4, 1000, stop_radar_4);
}

void stop(void){
  motor_cfg_t m0, m1;
  m0.id = 0;
  m1.id = 1;

  if(read_sonar(1) > read_sonar(6)){
    m1.speed = 0;
    m0.speed = 20;
  }else{
    m1.speed = 20;
    m0.speed = 0;
  }

  set_motors_speed(&m0, &m1);

  while((read_sonar(3) < 1200)||(read_sonar(4) < 1200) ){

  }

  m0.id = 0;
  m0.speed = 36;
  m1.id = 1;
  m1.speed = 36;

  set_motors_speed(&m0, &m1);

  return;
}


void stop_definitive(void){
  motor_cfg_t m0, m1;
  m0.id = 0;
  m1.id = 1;
  m1.speed = 0;
  m0.speed = 0;

  set_motors_speed(&m0, &m1);

  while(1){

  }
}

void loop_teste(void){
  motor_cfg_t m0, m1;
  m0.id = 0;
  m1.id = 1;
  m1.speed = 63;
  m0.speed = 0;

  set_motors_speed(&m0, &m1);

  while(1){}
}


// void turn(void){
//       motor_cfg_t temp_m0, temp_m1;
//
//       temp_m0.id = 0;
//       temp_m0.speed = 15;
//       temp_m1.id = 1;
//       temp_m1.speed = 0;
//
//       set_motors_speed(&temp_m0, &temp_m1);
//
//       int dist_front = 1000;
//
//       while (dist_front <= 1000) {
//           dist_front = read_sonar(3);
//       }
//
//       temp_m0.speed = 15;
//       temp_m1.speed = 15;
//
//       set_motors_speed(&temp_m0, &temp_m1);
//
//       return;
// }
