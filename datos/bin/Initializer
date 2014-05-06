#!/bin/sh

#poner hipotesis si hay una interrupcion o salgo por exit mirar los logs

DIRACTUAL=`pwd`
ENCONTRADO=0

while [ $ENCONTRADO = 0 ]
do
	for dir in `ls`
	do
		if [ $dir =  "conf" ]
		then
			ENCONTRADO=1
		fi
	done
	if [ $ENCONTRADO = 0 ]
	then
		cd ..
	fi
done

PATHTP=`pwd`
CONFDIR=$PATHTP/conf
INIT="false"

#compruebo que exista el archivo conf
if [ ! -f "$CONFDIR/Installer.conf" ]
then
	touch "./ErrorInicializacion.txt"
	echo "No esta creado el archivo de configuracion" >> ./ErrorInicializacion.txt
	exit 1
fi

#Busco variables en conf
CANTLOGDIR=`grep -c '^LOGDIR.*$' $CONFDIR/Installer.conf`
if [ CANTLOGDIR > 0 ]
then 
	LOGDIR=`grep '^LOGDIR.*$' $CONFDIR/Installer.conf | sed s-'^[^=]\+=\([^=]\+\)=.*$-\1-'`
	LOGDIR="$PATHTP/$LOGDIR"
else
	touch "./ErrorInicializacion.txt"
	echo "No esta fijado el directorio de logs" >> ./ErrorInicializacion.txt
	exit 1
fi

CANTNOVEDIR=`grep -c '^NOVEDIR.*$' $CONFDIR/Installer.conf`
if [ CANTNOVEDIR > 0 ]
then 
	NOVEDIR=`grep '^NOVEDIR.*$' $CONFDIR/Installer.conf | sed s-'^[^=]\+=\([^=]\+\)=.*$-\1-'`
	NOVEDIR="$PATHTP/$NOVEDIR"
else
	touch "./ErrorInicializacion.txt"
	echo "No esta fijado el directorio de recepcion de novedades" >> ./ErrorInicializacion.txt
	exit 1
fi

CANTRECHDIR=`grep -c '^RECHDIR.*$' $CONFDIR/Installer.conf`
if [ CANTRECHDIR > 0 ]
then 
	RECHDIR=`grep '^RECHDIR.*$' $CONFDIR/Installer.conf | sed s-'^[^=]\+=\([^=]\+\)=.*$-\1-'`
	RECHDIR="$PATHTP/$RECHDIR"
else
	touch "./ErrorInicializacion.txt"
	echo "No esta fijado el directorio de rechazados" >> ./ErrorInicializacion.txt
	exit 1
fi

CANTBINDIR=`grep -c '^BINDIR.*$' $CONFDIR/Installer.conf`
if [ CANTBINDIR > 0 ]
then 
	BINDIR=`grep '^BINDIR.*$' $CONFDIR/Installer.conf | sed s-'^[^=]\+=\([^=]\+\)=.*$-\1-'`
	BINDIR="$PATHTP/$BINDIR"
else
	touch "./ErrorInicializacion.txt"
	echo "No esta fijado el directorio de binarios" >> ./ErrorInicializacion.txt
	exit 1
fi

CANTMAEDIR=`grep -c '^MAEDIR.*$' $CONFDIR/Installer.conf`
if [ CANTMAEDIR > 0 ]
then 
	MAEDIR=`grep '^MAEDIR.*$' $CONFDIR/Installer.conf | sed s-'^[^=]\+=\([^=]\+\)=.*$-\1-'`
	MAEDIR="$PATHTP/$MAEDIR"
else
	touch "./ErrorInicializacion.txt"
	echo "No esta fijado el directorio de maestros" >> ./ErrorInicializacion.txt
	exit 1
fi

CANTINFODIR=`grep -c '^INFODIR.*$' $CONFDIR/Installer.conf`
if [ CANTINFODIR > 0 ]
then 
	INFODIR=`grep '^INFODIR.*$' $CONFDIR/Installer.conf | sed s-'^[^=]\+=\([^=]\+\)=.*$-\1-'`
	INFODIR="$PATHTP/$INFODIR"
else
	touch "./ErrorInicializacion.txt"
	echo "No esta fijado el directorio de informes" >> ./ErrorInicializacion.txt
	exit 1
fi

CANTLOGEXT=`grep -c '^LOGEXT.*$' $CONFDIR/Installer.conf`
if [ CANTLOGEXT > 0 ]
then 
	LOGEXT=`grep '^LOGEXT.*$' $CONFDIR/Installer.conf | sed s-'^[^=]\+=\([^=]\+\)=.*$-\1-'`
else
	touch "./ErrorInicializacion.txt"
	echo "No esta fijada la extension de los logs" >> ./ErrorInicializacion.txt
	exit 1
fi

CANTACEPDIR=`grep -c '^ACEPDIR.*$' $CONFDIR/Installer.conf`
if [ CANTACEPDIR > 0 ]
then 
	ACEPDIR=`grep '^ACEPDIR.*$' $CONFDIR/Installer.conf | sed s-'^[^=]\+=\([^=]\+\)=.*$-\1-'`
	ACEPDIR="$PATHTP/$ACEPDIR"
else
	touch "./ErrorInicializacion.txt"
	echo "No esta fijado el directorio de aceptados" >> ./ErrorInicializacion.txt
	exit 1
fi

CANTLOGSIZE=`grep -c '^LOGSIZE.*$' $CONFDIR/Installer.conf`
if [ CANTLOGSIZE > 0 ]
then 
	LOGSIZE=`grep '^LOGSIZE.*$' $CONFDIR/Installer.conf | sed s-'^[^=]\+=\([^=]\+\)=.*$-\1-'`
else
	touch "./ErrorInicializacion.txt"
	echo "No esta fijado el tamanio de logging" >> ./ErrorInicializacion.txt
	exit 1
fi

CANTGRUPO=`grep -c '^GRUPO.*$' $CONFDIR/Installer.conf`
if [ CANTGRUPO > 0 ]
then 
	GRUPO=`grep '^GRUPO.*$' $CONFDIR/Installer.conf | sed s-'^[^=]\+=\([^=]\+\)=.*$-\1-'`
else
	touch "./ErrorInicializacion.txt"
	echo "No esta fijado el grupo" >> ./ErrorInicializacion.txt
	exit 1
fi

#checkeo instalacion
if [ ! -f "$BINDIR/Logging" ]
then
	touch "./ErrorInicializacion.txt"
	echo "No existe el script de logging" >> ./ErrorInicializacion.txt
	exit 1
fi

if [ ! -x "$BINDIR/Logging" ]
then
	touch "./ErrorInicializacion.txt"
	echo "el script de logging no tenia permisos de ejecucion, se setean los mismos" >> ./ErrorInicializacion.txt
	chmod +x $BINDIR/Logging
fi

#creo archivos de log
touch "$LOGDIR/Initializer.log"
touch "$LOGDIR/Listener.log"
touch "$LOGDIR/MasterList.log"
touch "$LOGDIR/Rating.log"
touch "$LOGDIR/Reporting.log"

#exporto las variables que usa el logging
export LOGDIR
export LOGEXT
export LOGSIZE

#inicializo el archivo de log del Initializer
$BINDIR/Logging Initializer "Comando Initializer inicio de ejecucion" INFO
$BINDIR/Logging Initializer "Las variables del installer.conf estan seteadas" INFO

if [ ! -f "$BINDIR/Listener.sh" ]
then
	$BINDIR/Logging Initializer "No existe el script de Listener" INFO
	exit 1
fi

if [ ! -f "$BINDIR/Masterlist.sh" ]
then
	$BINDIR/Logging Initializer "No existe el script de Masterlist" INFO
	exit 1
fi

if [ ! -f "$BINDIR/Rating.sh" ]
then
	$BINDIR/Logging Initializer "No existe el script de Rating" INFO
	exit 1
fi

if [ ! -f "$BINDIR/reporting.pl" ]
then
	$BINDIR/Logging Initializer "No existe el script de reporting" INFO
	exit 1
fi

if [ ! -f "$BINDIR/Start" ]
then
	$BINDIR/Logging Initializer "No existe el script de Start" INFO
	exit 1
fi

if [ ! -f "$BINDIR/Stop" ]
then
	$BINDIR/Logging Initializer "No existe el script de Stop" INFO
	exit 1
fi

if [ ! -f "$BINDIR/Mover" ]
then
	$BINDIR/Logging Initializer "No existe el script de Mover" INFO
	exit 1
fi

#me fijo si existen los archivos en MAEDIR um.tab, asociados.mae y super.mae
if [ ! -f "$MAEDIR/um.tab" ]
then
	$BINDIR/Logging Initializer "el archivo um.tab no existe" INFO
	exit 1
fi
if [ ! -f "$MAEDIR/asociados.mae" ]
then
	$BINDIR/Logging Initializer "el archivo asociados.mae no existe" INFO
	exit 1
fi
if [ ! -f "$MAEDIR/super.mae" ]
then
	$BINDIR/Logging Initializer "el archivo super.mae no existe" INFO
	exit 1
fi

$BINDIR/Logging Initializer "La instalacion fue completa" INFO

#Creo archivo maestro de precios que usa el Mastelist
touch "$MAEDIR/precios.mae"

#me fijo si el ambiente ya fue inicializado
if [ "$INIT" = "true" ]
then 
	$BINDIR/Logging Initializer "El ambiente ya se encuentra inicializado, si quiere reiniciar termine su sesion e ingrese nuevamente"
	exit 1
else
	#seteo variables de ambiente	
	export PATHTP
	export GRUPO
	export LOGDIR
	export BINDIR
	export INFODIR
	export LOGEXT
	export LOGSIZE
	export MAEDIR
	export ACEPDIR
	export NOVEDIR
	export RECHDIR
	export INIT=true

	#checkeo permisos de archivos FALTA PERMISO DE EJECUCION PARA LOS SCRIPTS

	if [ ! -x "$BINDIR/Start" ]
	then
		$BINDIR/Logging Initializer "el script de start no tenia permisos de ejecucion, se setean los mismos" INFO
		chmod +x $BINDIR/Start
	fi

	if [ ! -x "$BINDIR/Stop" ]
	then
		$BINDIR/Logging Initializer "el script de stop no tenia permisos de ejecucion, se setean los mismos" INFO
		chmod +x $BINDIR/Stop
	fi

	if [ ! -x "$BINDIR/Mover" ]
	then
		$BINDIR/Logging Initializer "el script de mover no tenia permisos de ejecucion, se setean los mismos" INFO
		chmod +x $BINDIR/Mover
	fi

	if [ ! -x "$BINDIR/Masterlist.sh" ]
	then
		$BINDIR/Logging Initializer "el script de masterlist no tenia permisos de ejecucion, se setean los mismos" INFO
		chmod +x $BINDIR/Masterlist.sh
	fi

	if [ ! -x "$BINDIR/Rating.sh" ]
	then
		$BINDIR/Logging Initializer "el script de rating no tenia permisos de ejecucion, se setean los mismos" INFO
		chmod +x $BINDIR/Rating.sh
	fi

	if [ ! -x "$BINDIR/Listener.sh" ]
	then
		$BINDIR/Logging Initializer "el script de listener no tenia permisos de ejecucion, se setean los mismos" INFO
		chmod +x $BINDIR/Listener.sh
	fi

	if [ ! -x "$BINDIR/reporting.pl" ]
	then
		$BINDIR/Logging Initializer "el script de reporting no tenia permisos de ejecucion, se setean los mismos" INFO
		chmod +x $BINDIR/reporting.pl
	fi

	if [ ! -r "$MAEDIR/um.tab" ]
	then
		$BINDIR/Logging Initializer "el archivo um.tab no tenia permisos de lectura, se setean los mismos" INFO
		chmod +r $MAEDIR/um.tab
	fi
	if [ ! -r "$MAEDIR/asociados.mae" ]
	then
		$BINDIR/Logging Initializer "el archivo asociados.mae no tenia permisos de lectura, se setean los mismos" INFO
		chmod +r $MAEDIR/asociados.mae
	fi
	if [ ! -r "$MAEDIR/super.mae" ]
	then
		$BINDIR/Logging Initializer "el archivo super.mae no tenia permisos de lectura, se setean los mismos" INFO
		chmod +r $MAEDIR/super.mae
	fi
fi

#pregunto si correr el listener.sh
echo "Desea efectuar la activacion de Listener? (s/n)"

DECISION=0
while [ $DECISION = 0 ]
do
	read opcion

	case $opcion in
	        [Ss]* ) 
			DECISION=1
		        #veo si no hay otro listener corriendo
			pid=`ps -ef | grep Listener.sh | grep -e grep -e initializer.sh -v`
			pid=`echo $pid | sed 's-^[^\ ]\+\ \([0-9]\+\)\ .*$-\1-g'`

			if [ "$pid" != "" ]
			then
				$BINDIR/Logging Initializer "El Listener ya se encuentra ejecutandose" WAR
				exit 1
			fi

			$BINDIR/Logging Initializer "Se activa el listener" INFO
			$BINDIR/Listener.sh &
			echo "Para frenar el Listener debe usar el comando Stop enviandole como parametro Listener.sh es decir, por parametro se envia el comando a frenar";break;;

	        [Nn]* ) 
			echo "Para activar el Listener debe usar el comando Start enviandole como parametro Listener.sh es decir, por parametro se envia el comando a activar";break;;

	        * ) echo "Por favor responda s o n";;
	esac
done

$BINDIR/Logging Initializer "Inicializacion completa" INFO

#mostrar estado final
echo "TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright \A9 Grupo 01."
cd ./conf
echo "Direct. de configuracion: $CONFDIR"
echo "Archivos de configuracion `ls`"
cd ..
cd ./bin
echo "Direct. de ejecutables: $BINDIR"
echo "Archivos de ejecutables `ls`"
cd ..
cd ./mae
echo "Direct. de maestros y tablas: $MAEDIR"
echo "Archivos de maestros y tablas `ls`"
cd ..
echo "Direct. de novedades: $NOVEDIR"
echo "Direct. de novedades aceptadas: $ACEPDIR"
echo "Direct. de informes de salida: $INFODIR"
echo "Direct. de archivos rechazados: $RECHDIR"
echo "Direct. de logs de comandos: $LOGDIR/<comando>.$LOGEXT"
echo "Estado del sistema: Inicializado"

#veo si esta listener corriendo
pid=`ps -ef | grep Listener.sh | grep -e grep -e initializer.sh -v`
pid=`echo $pid | sed 's-^[^\ ]\+\ \([0-9]\+\)\ .*$-\1-g'`

if [ "$pid" != "" ]
then
	echo "Listener corriendo bajo el numero: $pid"
fi

exit 0
