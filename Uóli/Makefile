#source /home/specg12-1/mc404/simulador/set_path_player.sh

makes:
	arm-eabi-as motors.s -o motors.o
	arm-eabi-ld motors.o -o motors  -Ttext=0x77802000
	mksd.sh --so /home/specg12-1/mc404/simulador/simulador_player/bin/knrl --user motors

player:
	player /home/specg12-1/mc404/simulador/simulador_player/worlds_mc404/simple.cfg

run:
	armsim_player --rom=/home/specg12-1/mc404/simulador/simulador_player/bin/dumboot.bin --sd=disk.img
