################################################################################
# ----------------------------------------
# Disciplina: MC404 - 1o semestre de 2015
# Professor: Edson Borin
#
# Descrição: Makefile para o segundo trabalho 
# ----------------------------------------

# ----------------------------------
# SOUL object files -- Add your SOUL object files here 
SOUL_OBJS=soul.o 

# ----------------------------------
# Compiling/Assembling/Linking Tools and flags
AS=arm-eabi-as
AS_FLAGS=-g

CC=arm-eabi-gcc
CC_FLAGS=-g

LD=arm-eabi-ld
LD_FLAGS=-g

USER_PRG=ronda.o

# ----------------------------------
# Default rule
all: disk.img

# ----------------------------------
# Generic Rules
%.o: %.s
	$(AS) $(AS_FLAGS) $< -o $@

%.o: %.c
	$(CC) $(CC_FLAGS) -c $< -o $@

# ----------------------------------
# Specific Rules
SOUL.x: $(SOUL_OBJS)
	$(LD) $^ -o $@ $(LD_FLAGS) --section-start=.iv=0x778005e0 -Ttext=0x77800700 -Tdata=0x77801800 -e 0x778005e0

LOCO.x: $(USER_PRG) bico.o
	$(LD) $^ -o $@ $(LD_FLAGS) -Ttext=0x77812000

disk.img: SOUL.x LOCO.x
	mksd.sh --so SOUL.x --user LOCO.x

clean:
	rm -f SOUL.x LOCO.x disk.img *.o


###############################################################################
sdacb:
	# Para deletar execucoes antigas
	rm -f soul.o soul testeACB.o testeACB
	# Para compilar e ligar o seu programa.
	arm-eabi-as -g soul.s -o soul.o
	arm-eabi-as -g testeACB.s -o testeACB.o
	arm-eabi-ld soul.o -o soul -g --section-start=.iv=0x778005e0 -Ttext=0x77800700 -Tdata=0x77801800 -e 0x778005e0
	arm-eabi-ld testeACB.o -o testeACB -Ttext=0x77812000 -Tdata=0x77813000
	# Monte a imagem do cartão SD: (seu programa eh o SO)
	mksd.sh --so soul --user testeACB



sdpcb:
	# Para deletar execucoes antigas
	rm -f soul.o soul testePCB.o testePCB
	# Para compilar e ligar o seu programa.
	arm-eabi-as -g soul.s -o soul.o
	arm-eabi-as -g testePCB.s -o testePCB.o
	arm-eabi-ld soul.o -o soul -g --section-start=.iv=0x778005e0 -Ttext=0x77800700 -Tdata=0x77801800 -e 0x778005e0
	arm-eabi-ld testePCB.o -o testePCB -Ttext=0x77812000 -Tdata=0x77813000
	# Monte a imagem do cartão SD: (seu programa eh o SO)
	mksd.sh --so soul --user testePCB



sddesvio:
	# Para deletar execucoes antigas
	rm -f soul.o soul testeDesvio.o testeDesvio
	# Para compilar e ligar o seu programa.
	arm-eabi-as -g soul.s -o soul.o
	arm-eabi-as -g testeDesvio.s -o testeDesvio.o
	arm-eabi-ld soul.o -o soul -g --section-start=.iv=0x778005e0 -Ttext=0x77800700 -Tdata=0x77801800 -e 0x778005e0
	arm-eabi-ld testeDesvio.o -o testeDesvio -Ttext=0x77812000 -Tdata=0x77813000
	# Monte a imagem do cartão SD: (seu programa eh o SO)
	mksd.sh --so soul --user testeDesvio



sdsonar:
	# Para deletar execucoes antigas
	rm -f soul.o soul testeSonar.o testeSonar
	# Para compilar e ligar o seu programa.
	arm-eabi-as -g soul.s -o soul.o
	arm-eabi-as -g testeSonar.s -o testeSonar.o
	arm-eabi-ld soul.o -o soul -g --section-start=.iv=0x778005e0 -Ttext=0x77800700 -Tdata=0x77801800 -e 0x778005e0
	arm-eabi-ld testeSonar.o -o testeSonar -Ttext=0x77812000 -Tdata=0x77813000
	# Monte a imagem do cartão SD: (seu programa eh o SO)
	mksd.sh --so soul --user testeSonar

sdtempo:
	# Para deletar execucoes antigas
	rm -f soul.o soul testeTempo.o testeTempo
	# Para compilar e ligar o seu programa.
	arm-eabi-as -g soul.s -o soul.o
	arm-eabi-as -g testeTempo.s -o testeTempo.o
	arm-eabi-ld soul.o -o soul -g --section-start=.iv=0x778005e0 -Ttext=0x77800700 -Tdata=0x77801800 -e 0x778005e0
	arm-eabi-ld testeTempo.o -o testeTempo -Ttext=0x77812000 -Tdata=0x77813000
	# Monte a imagem do cartão SD: (seu programa eh o SO)
	mksd.sh --so soul --user testeTempo

sdmotor:
	# Para deletar execucoes antigas
	rm -f soul.o soul testeMotor.o testeMotor
	# Para compilar e ligar o seu programa.
	arm-eabi-as -g soul.s -o soul.o
	arm-eabi-as -g testeMotor.s -o testeMotor.o
	arm-eabi-ld soul.o -o soul -g --section-start=.iv=0x778005e0 -Ttext=0x77800700 -Tdata=0x77801800 -e 0x778005e0
	arm-eabi-ld testeMotor.o -o testeMotor -Ttext=0x77812000 -Tdata=0x77813000
	# Monte a imagem do cartão SD: (seu programa eh o SO)
	mksd.sh --so soul --user testeMotor
player:
	# Antes de iniciar o simulador, você precisa abrir uma sessão do Player em outro terminal (faca o source aqui tambem)
	player /home/specg12-1/mc404/simulador/simulador_player/worlds_mc404/simple.cfg
mainrun:
	# Abra o simulador armsim_player com suporte ao GDB no primeiro terminal
	armsim_player --rom=/home/specg12-1/mc404/simulador/simulador_player/bin/dumboot.bin --sd=disk.img -g

gdbrun:
	# No terceiro terminal, conecte no simulador utilizando o GDB (faca source aqui tambem)
	arm-eabi-gdb soul




#(gdb) target remote localhost:5000       # conecte no simulador
#(gdb) b raXXXXXX.s:<linha>               # substitua <linha> por uma linha dentro de IRQ_HANDLER 
#(gdb) c                                  # execute ate encontrar um breakpoint
#(gdb) p *(int)0x77801800                 # quando parar no tratador de interrupcoes, imprima o conteudo do contador
#(gdb) c
#(gdb) ...


