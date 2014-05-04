#!/bin/bash
#declaraciones
export GRUPO01=`pwd`
export CONFDIR="conf"

#borrar
clear
#rm "$GRUPO01/$CONFDIR/Installer.log"
#rm "$GRUPO01/$CONFDIR/Installer.conf"
#borrar

#funciona verificacion
function Pregunta_SiNo {
	echo  $1
	local Acepta="null"
	while [ "$Acepta" != "si" -a "$Acepta" != "no" ]
	do
		read Acepta
		Acepta=`echo "$Acepta" | tr '[:upper:]' '[:lower:]'`
		if [ "$Acepta" != "si" -a "$Acepta" != "no" ]; then
			echo "No se ingreso una opcion valida. Acepta? Si - No"
		fi
	done
	if [ "$Acepta" == "no" ]; then
		return 0
	fi	
	return 1
}

function Verificar_perl {
	Perl=`perl --version`
	Version=`echo $Perl | sed -n 's/.*v\([0-9]\)\.[0-9][0-9]\.[0-9].*/\1/p'`
	if [[ $Version -lt 5 ]]; then
		echo "TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 01
Para instalar el TP es necesario contar con Perl 5 o superior. Efectue su instalacion e intentelo nuevamente.
Proceso de Instalacion Cancelado"

		./Logging Installer "TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 01
Para instalar el TP es necesario contar con Perl 5 o superior. Efectue su instalacion e intentelo nuevamente.
Proceso de Instalacion Cancelado" ERROR

		exit 1
	fi
	echo "TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 01
Perl Version: $Perl"
 	./Logging Installer "TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 01
Perl Version: $Perl" INFO
}

function Verificar_tamano {
	valorIngresado="$1"
	valorPorDefecto="$2"
	estado=`echo $valorIngresado | sed -n "s/\(.*[^0-9].*\)/ERROR/p"`
	if [ "$estado" == "ERROR" -o "$1" == "" ]
	then 
		resultado=$valorPorDefecto
	else
		resultado=$1
	fi
	echo $resultado
}

function Verificar_tamano_disco {
	lineaDiscoDisponible=`df -h | grep "sda1" | tr -s " "`
	# obtengo tamano del disco con la unidad incluida (Gb)
	espacioDisponible=`echo $lineaDiscoDisponible | cut -f4 -d ' ' `  
	# obtengo unicamente el numero del espacio disponible en disco. saco unidades
	espacioDisponible=`echo $espacioDisponible | sed -n 's/\(^.*\),.*G/\1/p'`
	let espacioDisponible=`expr $espacioDisponible*1024`
	echo $espacioDisponible
}

#Recibe 4 parametros [variable a guardar el resultado,salida en pantalla y log, log fracaso,pathdefecto]
function Obtener_path {
	#devolucion de parametros basada en http://www.linuxjournal.com/content/return-values-bash-functions
	local  Resultado=$1
	local  Resultadoparcial
	read Resultadoparcial
	if [ "$Resultadoparcial" == "" ]
    	then
		Resultadoparcial=$3	
		echo "Error: El valor ingresado es inválido, se tomará el predeterminado: $3"
    	else
		Resultadoparcial=$Resultadoparcial
	fi
	
	Resultadoparcial=`echo "$Resultadoparcial" | grep '^[^=]*$'`
	if [ "$Resultadoparcial" == "" ]
	then
		echo "Error: El valor ingresado para $1 es inválido, se tomará el predeterminado: $3"
		#echo "Error: El valor ingresado para $1 es inválido, se tomará el predeterminado: $3" >> "$GRUPO01/$CONFDIR/Installer.log"
		Resultadoparcial=$3	
	fi
	
	./Logging Installer "$2 $Resultadoparcial" INFO
    	eval $Resultado="'$Resultadoparcial'"
}

#Recibe 3 parametros [variable a guardar el resultado,salida en pantalla y log,pathdefecto]
function Obtener_valor {
	#devolucion de parametros basada en http://www.linuxjournal.com/content/return-values-bash-functions
	local  Resultado=$1
	local  Resultadoparcial
	read Resultadoparcial
	if [ "$Resultadoparcial" == "" ] 
	then
		Resultadoparcial=$3
		echo "El valor ingresado para $1 es inválido, se tomará el predeterminado: $3"
	fi

	Resultadoparcial=`echo "$Resultadoparcial" | grep '^[^=]*$'`
	if [ "$Resultadoparcial" == "" ]
	then
		echo "El valor ingresado para $1 es inválido, se tomará el predeterminado: $3"
		./Logging Installer "Error: El valor ingresado para $1 es inválido, se tomará el predeterminado." ERR
		Resultadoparcial=$3	
	fi

	./Logging Installer "$2 $Resultadoparcial" INFO
	eval $Resultado="'$Resultadoparcial'"
}

#Recibe 5 parametros [variable a guardar el resultado,salida en pantalla y log, log error, pathdefecto, cota]
function Obtener_numero {
	#devolucion de parametros basada en http://www.linuxjournal.com/content/return-values-bash-functions
	local  Resultado=$1
	local  Resultadoparcial
	read Resultadoparcial
	if [ "$Resultadoparcial" == "" ]
	then
		Resultadoparcial="ERROR"
	fi
	Resultadoparcial=`echo "$Resultadoparcial" | sed 's/^.*[^0-9].*$/ERROR/'`
	if [ "$Resultadoparcial" == "ERROR" ] 
	then
		echo "Error: El número ingresado para $1 es inválido, se tomará el predeterminado: $4"
		./Logging Installer "Error: El número ingresado para $1 es inválido, se tomará el predeterminado." ERR
		Resultadoparcial=$4
		eval $Resultado="'$Resultadoparcial'"
		return 0
	fi

	if [ $Resultadoparcial -lt $5 ]
	then
		Resultadoparcial=$4
	fi
	./Logging Installer "$2 $Resultadoparcial" INFO
	eval $Resultado="'$Resultadoparcial'"
}

#recibe: $1: mensaje a mostrar
#$2: directorio del cual se quiere mostrar el path y archivos contenidos dentro de ese path
#3:booleano indicando si se quiere listar los archivos o no (1=si 0=no)	
function Path_y_Archivos {
	if [ "$3" -eq 1 ]
	then	
		if [ -d "$2" ]
		then
			archivos=`ls -1 "$2"`
		fi	
	else
		archivos=" "
	fi	
	if [ "$archivos" != " " ]
	then
		resultado="$1 $2 
Archivos en $2:
$archivos "
	else
		resultado="$1 $2"
	fi
	echo "$resultado"
	./Logging Installer "$resultado" INFO
}
#Creo directorios

# 1er parametro directorio a crear, 2do parametro directorio padre
function Crear_directorios {
	primerSubpath=`echo $1 | sed "s-^\([^/]*\)/.*-\1-"`
	segundoSubpath=`echo $1 | sed -n "s-^[^/]*/\(.*\)-\1-p"`
	path=$2
	if [ "$segundoSubpath" == "" -a ! -d "$2/$primerSubpath" ]
	then
		mkdir "$path/$primerSubpath"
	else
		while [ "$segundoSubpath" != "" ]
		do
			if [ ! -d "$path/$primerSubpath" ]
			then
				mkdir "$path/$primerSubpath"
			fi
			echo 
			path="$path/$primerSubpath"
			primerSubpath=`echo $segundoSubpath | sed "s-^\([^/]*\)/.*-\1-"`
			segundoSubpath=`echo $segundoSubpath | sed -n "s-^[^/]*/\(.*\)-\1-p"`
		done
		if [ ! -d "$path/$primerSubpath" ]
		then
			mkdir "$path/$primerSubpath"
		fi
	fi
}

function Creacion_de_directorios {
	echo "Creando estructuras de directorio . . . ."
	Crear_directorios "$BINDIR" "$GRUPO01"
	Crear_directorios "$MAEDIR" "$GRUPO01"
	Crear_directorios "$MAEDIR/precios" "$GRUPO01"
	Crear_directorios "$MAEDIR/precios/proc" "$GRUPO01"
	Crear_directorios "$NOVEDIR" "$GRUPO01"
	Crear_directorios "$ACEPDIR" "$GRUPO01"
	Crear_directorios "$ACEPDIR/proc" "$GRUPO01"
	Crear_directorios "$INFODIR" "$GRUPO01"
	Crear_directorios "$INFODIR/pres" "$GRUPO01"
	Crear_directorios "$RECHDIR" "$GRUPO01"
	Crear_directorios "$LOGDIR" "$GRUPO01"
}

#$1=subdirectorio $2=expresion que matchea, $3 dir destino
function Copiar_archivos {
	declare local directorioActual=`pwd`
	cd "$1"
	ListaArchivos=`ls $1/$2`
	for Archivo in $ListaArchivos;
	do
		echo "archivo $Archivo"
		local Nombre_archivo=`echo $Archivo | sed -n 's/.*[/]\([^/]*\)/\1/p'`
		if [[ ! -f "$3"/$Nombre_archivo ]]; then
			cp -a "$Archivo" "$3"
		fi
	done
	cd "$directorioActual"
}

#instalo archivos
function Instalacion_archivos {
	echo "Instalando Archivos Maestros y tablas"
	Copiar_archivos "$GRUPO01/datos" "*.mae" "$GRUPO"/"$MAEDIR"
	Copiar_archivos "$GRUPO01/datos" "*.tab" "$GRUPO"/"$MAEDIR"
	echo
	echo "Instalando Programas y Funciones"
	Copiar_archivos "$GRUPO01/datos" "*.sh" "$GRUPO01"/"$BINDIR"
	Copiar_archivos "$GRUPO01/datos" "*.pl" "$GRUPO01"/"$BINDIR"	
	Copiar_archivos "$GRUPO01/datos" "Logging*. " "$GRUPO01"/"$BINDIR"
	Copiar_archivos "$GRUPO01/datos" "Start*." "$GRUPO01"/"$BINDIR"
	Copiar_archivos "$GRUPO01/datos" "Stop*." "$GRUPO01"/"$BINDIR"
	Copiar_archivos "$GRUPO01/datos" "Mover*." "$GRUPO01"/"$BINDIR"
	Copiar_archivos "$GRUPO01/datos" "Rating*." "$GRUPO01"/"$BINDIR"
}
#Actualizo archivos de configuracion
function Actualizacion_archivos_configuracion {
	if [ -f "$GRUPO01/$CONFDIR/Installer.conf" ] 
	then
		rm $GRUPO01/$CONFDIR/Installer.conf
	fi
	date=`date`
	./Logging Installer "GRUPO01=$GRUPO01=$USER=$date
CONFDIR=$CONFDIR=$USER=$date
BINDIR=$BINDIR=$USER=$date 
MAEDIR=$MAEDIR=$USER=$date
NOVEDIR=$NOVEDIR=$USER=$date
DATASIZE=$DATASIZE=$USER=$date 
ACEPDIR=$ACEPDIR=$USER=$date
INFODIR=$INFODIR=$USER=$date
RECHDIR=$RECHDIR=$USER=$date
LOGDIR=$LOGDIR=$USER=$date
LOGEXT=$LOGEXT=$USER=$date
LOGSIZE=$LOGSIZE=$USER=$date" INFO

}

# Rescata el valor que corresponde a la variable pasada por parametro  
# que se encuentra en el archivo de configuracion
# $1:Variable
function Tomar_Variable { 
	declare local var=`grep '^'$1'=[^=]*=[^=]*=[^=]*$' "$GRUPO01/$CONFDIR/Installer.conf" | sed 's@^[^=]*=\([^=]*\)=.*@\1@'`
	
	if [  "$1" == DATASIZE  -o  "$1" == LOGSIZE  ] 
	then
		var=`echo "$var" | sed 's@[0-9]*[^0-9]\+.*@@'`
	fi
	
	if [ "$var" == "" ] 
	then
		echo "Error: registro $1 inexistente o mal formado en el archivo de configuración."
		Logging Installer "Error: registro $1 inexistente o mal formado en el archivo de configuración." ERR
		echo "Por favor, vuelva a instalar el sistema siguiendo el README desde el comienzo."
		exit 1
	fi
	eval "$1=\"$var\""
	return 0
}


function Verificar_archivos_faltantes {
echo "entro"
	ERROR=0
	conf_roto=0
	echo ERROR , conf_roto
	#verifico cada archivo de tipo .mae y .tab que se encuentran en MAEDIR
	if [ ! -f "$GRUPO01/$MAEDIR/asociados.mae" ] 
	then
		Faltantes="$Faltantes 
		asociados.mae"
		if [ ! -f  "$GRUPO01/Datos/asociados.mae" ]
		 then
			ERROR=1
		fi
	fi
	if [ ! -f "$GRUPO01/$MAEDIR/super.mae" ] 
	then
		Faltantes="$Faltantes 
		super.mae"
		if [ ! -f  "$GRUPO01/Datos/super.mae" ]
		 then
			ERROR=1
		fi
	fi
	if [ ! -f "$GRUPO01/$MAEDIR/um.tab" ] 
	then
		Faltantes="$Faltantes 
		um.tab"
		if [ ! -f  "$GRUPO01/Datos/um.tab" ]
		 then
			ERROR=1
		fi
	fi

#verifico cada archivo que esta en BINDIR
	Tomar_Variable BINDIR
	if [ ! -f "$GRUPO01/$BINDIR/Initializer.sh" ] 
	then
		Faltantes="$Faltantes 
		Initializer.sh"
		if [ ! -f  "$GRUPO01/Datos/Initializer.sh" ]
		 then
			ERROR=1
		fi
	fi
	if [ ! -f "$GRUPO01/$BINDIR/Listener.sh" ] 
	then
		Faltantes="$Faltantes 
		Listener.sh"
		if [ ! -f  "$GRUPO01/Datos/Listener.sh" ]
		 then
			ERROR=1
		fi
	fi
	if [ ! -f "$GRUPO01/$BINDIR/Masterlist.sh" ] 
	then
		Faltantes="$Faltantes 
		Masterlist.sh"
		if [ ! -f  "$GRUPO01/Datos/Masterlist.sh" ]
		 then
			ERROR=1
		fi
	fi
	if [ ! -f "$GRUPO01/$BINDIR/Logging.pl" ] 
	then
		Faltantes="$Faltantes 
		Logging.pl"
		if [ ! -f  "$GRUPO01/Datos/Logging.pl" ]
		 then
			ERROR=1
		fi
	fi
	if [ ! -f "$GRUPO01/$BINDIR/Mover.sh" ] 
	then
		Faltantes="$Faltantes 
		Mover.sh"
		if [ ! -f  "$GRUPO01/Datos/Mover.sh" ]
		 then
			ERROR=1
		fi
	fi
	if [ ! -f "$GRUPO01/$BINDIR/Rating.sh" ] 
	then
		Faltantes="$Faltantes 
		Rating.sh"
		if [ ! -f  "$GRUPO01/Datos/Rating.sh" ]
		 then
			ERROR=1
		fi
	fi
	if [ ! -f "$GRUPO01/$BINDIR/Start.sh" ] 
	then
		Faltantes="$Faltantes 
		Start.sh"
		if [ ! -f  "$GRUPO01/Datos/Start.sh" ]
		 then
			ERROR=1
		fi
	fi
	if [ ! -f "$GRUPO01/$BINDIR/Stop.sh" ] 
	then
		Faltantes="$Faltantes 
		Stop.sh"
		if [ ! -f  "$GRUPO01/Datos/Stop.sh" ]
		 then
			ERROR=1
		fi
	fi
	if [ ! -f "$GRUPO01/$BINDIR/inicio_var_entorno.sh" ] 
	then
		Faltantes="$Faltantes 
		inicio_var_entorno.sh"
		if [ ! -f  "$GRUPO01/Datos/inicio_var_entorno.sh" ]
		 then
			ERROR=1
		fi
	fi
	if [ ! -f "$GRUPO01/$BINDIR/prueba.sh" ] 
	then
		Faltantes="$Faltantes 
		prueba.sh"
		if [ ! -f  "$GRUPO01/Datos/prueba.sh" ]
		 then
			ERROR=1
		fi
	fi
	if [ ! -f "$GRUPO01/$BINDIR/reporting.pl" ] 
	then
		Faltantes="$Faltantes 
		reporting.pl"
		if [ ! -f  "$GRUPO01/Datos/reporting.pl" ]
		 then
			ERROR=1
		fi
	fi

	#guardo el resto de los valores ya configurados
	conseguirVariable NOVEDIR
	conseguirVariable DATASIZE
	conseguirVariable ACEPDIR
	conseguirVariable RECHDIR
	conseguirVariable INFODIR
	conseguirVariable LOGDIR
	conseguirVariable LOGEXT
	conseguirVariable LOGSIZE

	#LISTO DIRECTORIOS.
	echo
	echo "TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 01"
	./Logging Installer "TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 01" INFO
	echo "Direct. de Configuracion: /$BINDIR/ Archivos:"
	./Logging Installer "Direct. de Configuracion: /$BINDIR/ Archivos:" INFO
	if [ -d "$GRUPO01/$BINDIR" ] 
	then
		ls "$BINDIR"
		Archivosbin=`ls "$BINDIR" `
		./Logging Installer "$Archivosbin" INFO
	else
		echo "Directorio $BINDIR inexistente" 
		./Logging Installer "Directorio $BINDIR inexistente" ERR
		conf_roto=1
	fi
	echo
	echo "Direct Maestros y Tablas: /$MAEDIR/ Archivos:"
	./Logging Installer "Direct Maestros y Tablas: /$MAEDIR/ Archivos:" INFO
	if [ -d "$GRUPO01/$MAEDIR" ]
	then
		ls "$MAEDIR"
		Archivosmae=`ls "$MAEDIR" `
		./Logging Installer "$Archivosmae" INFO
	else
		echo "Directorio $MAEDIR inexistente"
		./Logging Installer "Directorio $MAEDIR inexistente" ERR
		conf_roto=1
	fi
	echo
	echo "Direct. de Configuracion: /$CONFDIR/ Archivos:"
	./Logging Installer "Direct. de Configuracion: /$CONFDIR/ Archivos:" INFO
	if [ -d "$GRUPO01/$CONFDIR" ] 
	then
		ls "$CONFDIR"
		Archivosconf=`ls "$CONFDIR" `
		./Logging Installer "$Archivosconf" INFO
	else
		echo "Directorio $CONFDIR inexistente"
		./Logging Installer "Directorio $CONFDIR inexistente" ERR
		conf_roto=1
	fi
	if [ ! -d "$GRUPO01/$NOVEDIR" ] 
	then
		echo "Directorio $NOVEDIR inexistente"
		./Logging Installer "Directorio $NOVEDIR inexistente" ERR
		conf_roto=1
	else 
		echo "Directorio de Novedades: $NOVEDIR"
		./Logging Installer "Directorio de Novedades: $NOVEDIR" INFO
	fi
	if [ ! -d "$GRUPO01/$ACEPDIR" ] 
	then
		echo "Directorio $ACEPDIR inexistente"
		./Logging Installer "Directorio $ACEPDIR inexistente" ERR
		conf_roto=1
	else
		echo "Novedades Aceptadas: $ACEPDIR"
		./Logging Installer "Novedades Aceptadas: $ACEPDIR" INFO
	fi
	if [ ! -d "$GRUPO01/$RECHDIR" ] 
	then
		echo "Directorio $RECHDIR inexistente"
		./Logging Installer "Directorio $RECHDIR inexistente" ERR
		conf_roto=1
	else
		echo "Novedades Rechazadas: $RECHDIR"
		./Logging Installer "Novedades Rechazadas: $RECHDIR" INFO
	fi
	if [ ! -d "$GRUPO01/$INFODIR" ] 
	then
		echo "Directorio $INFODIR inexistente"
		./Logging Installer "Directorio $INFODIR inexistente" ERR
		conf_roto=1
	else
		echo "Dir informes de salida: $INFODIR"
		./LOgging Installer "Dir informes de salida: $INFODIR" INFO
	fi
	if [ ! -d "$GRUPO01/$LOGDIR" ] 
	then
		echo "Directorio $LOGDIR inexistente"
		./Logging Installer "Directorio $LOGDIR inexistente" ERR
		conf_roto=1
	else
		echo "Directorio de Logs de Comandos: $LOGDIR/<comando> $LOGEXT"
		./Logging Installer "Directorio de Logs de Comandos: $LOGDIR/<comando> $LOGEXT" INFO
	fi	
	echo "Estado de la instalación: COMPLETA"
	./Logging Installer "Estado de la instalacion: COMPLETA" INFO
	echo "Proceso de Instalacion Cancelado"
	./Logging Installer "Proceso de Instalacion Cancelado" INFO

	#imprimo faltantes
	#echo "Faltan: $Faltantes"
	if [ "$Faltantes" == "" && $conf_roto -eq 0 ] 
	then
		echo "Estado de la instalacion: COMPLETA
Proceso de instalacion cancelado." 
		./Logging Installer "Estado de la instalacion: COMPLETA" INFO
		./Logging Installer "Proceso de instalacion cancelado." INFO
		exit 0;
	else 
		if [ $conf_roto -ne 0 ] 
		then
			echo "Se rompio el archivo de configuracion."
			./Logging Installer "Se rompio el archivo de configuracion." INFO
		fi
		echo "Estado de la instalacion: Incompleto"
		echo "Faltan Archivos: $Faltantes"
		./Logging Installer "Faltan Archivos: $Faltantes" INFO
		./Logging Installer "Estado de la instalacion: Incompleto" INFO
		Pregunta_SiNo "Desea completar la instalacion? (si-no)"
		if [ "$?" == 0 ] 
		then
			exit 0
		else 
			if [ $ERROR == 1 ] 
			then
				echo "No se encuentran los archivos fuentes."
				exit 1
			fi
		fi
	fi
}

#pgm principal
clear
echo "Inicio de Ejecucion de Installer"
#verificacion de existencia de directorio
if [ ! -d "$GRUPO01/$CONFDIR" ] 
then 
	mkdir "$GRUPO01/$CONFDIR" 
fi
existeLog=1
if [ ! -f "$GRUPO01/$CONFDIR/Installer.log" ]
then
	existeLog=0
	#creo archivo de log
	touch "$CONFDIR/Installer.log"
fi	
echo "Log de la instalacion: $GRUPO01/$CONFDIR/Installer.log"
./Logging Installer "Log de la instalacion: $GRUPO01/$CONFDIR/Installer.log" INFO
echo "Directorio predefinido de Configuracion: $GRUPO01/$CONFDIR"
./Logging Installer "Directorio predefinido de Configuracion: $GRUPO01/$CONFDIR" INFO

if [ $existeLog -eq 1 ]
then	
	if [ -f "$GRUPO01/$CONFDIR/Installer.conf" ]
	then
		echo "El paquete fue instalado anteriormente"
		Verificar_archivos_faltantes
	fi
else
	echo 'TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 01 Al instalar TP SO7508 Primer Cuatrimestre 2014 UD. expresa aceptar los terminos y condiciones del "ACUERDO DE LICENCIA DE SOFTWARE" incluido en este paquete.'
	Pregunta_SiNo "Acepta? Si – No'"
	if [ $? -eq 0 ]
	then
		exit 1
	else
		Verificar_perl
		instalar=0
		BINDIR="bin"
		MAEDIR="mae"
		NOVEDIR="arribos"
		DATASIZE=100
		ACEPDIR="aceptadas"
		INFODIR="informes"
		RECHDIR="rechazados"
		LOGDIR="log"
		LOGEXT=".log"
		LOGSIZE=400

		while [ $instalar -eq 0 ]
		do
			echo
			# solicito valor de BINDIR
			echo "Defina el directorio de instalacion de los ejecutables ($GRUPO01/$BINDIR):"
			Obtener_path BINDIR "Directorio de instalacion de los ejecutables ($GRUPO01/$BINDIR):" "$BINDIR"
			echo
			# solicito valor de MAEDIR
			echo "Defina directorio para maestros y tablas ($GRUPO01/$MAEDIR):"
			Obtener_path MAEDIR "Directorio para maestros y tablas ($GRUPO01/$MAEDIR):" "$MAEDIR"
			echo 
			# solicito valor de NOVEDIR
			echo "Defina el Directorio de arribo de novedades ($GRUPO01/$NOVEDIR):"
			Obtener_path NOVEDIR "Directorio de arribo de novedades ($GRUPO01/$NOVEDIR):" "$NOVEDIR"
			echo
			# solicito valor de DATASIZE
			echo "Defina espacio minimo libre para el arribo de novedades en Mbytes ($DATASIZE):"
			Obtener_numero DATASIZE "Espacio minimo libre para el arribo de novedades en Mbytes ($DATASIZE):" "error" "$DATASIZE" 1
			DATASIZE=$(Verificar_tamano "$DATASIZE" $DATASIZE)
			#COMPRUEBO ESPACIO EN DISCO
			espacioDisponible=$(Verificar_tamano_disco)
			while [ $espacioDisponible -lt $DATASIZE ]
			do
				./Logging Installer "Insuficiente espacio en disco." ERR
	 			./Logging Installer "Espacio disponible: $espacioDisponible Mb." ERR
				./Logging Installer "Espacio requerido $DATASIZE Mb" ERR
				./Logging Installer "Cancele la instalacion o intentelo nuevamente." ERR

				echo "Insuficiente espacio en disco." 
				echo "Espacio disponible: $espacioDisponible Mb."  
				echo "Espacio requerido: $DATASIZE Mb."
				echo "Cancele la instalacion o intentelo nuevamente."  
				echo
				#pido que el user vuelva a ingresar un tamano para el DATASIZE
				Pregunta_SiNo "Desea cancelar? (si) o elegir un nuevo espacio para el arribo de novedades en Mbytes(no) si-no"
				if [ "$?" == 1 ] 
				then
					exit 1
				fi
				echo "Vuelva a definir un espacio minimo libre para el arribo de novedades en Mbytes "
				Obtener_numero DATASIZE "Espacio minimo libre para el arribo de novedades en Mbytes (100):" "error" "100" 1
				DATASIZE=$(Verificar_tamano "$DATASIZE" $DATASIZE)
			done
			echo 		
			# solicito valor de ACEPDIR
			echo "Defina el directorio de grabacion de las Novedades aceptadas ($GRUPO01/aceptadas):"
			Obtener_path ACEPDIR "Directorio de grabacion de las Novedades aceptadas ($GRUPO01/aceptadas):" "aceptadas"		
			echo
			# solicito valor de INFODIR
			echo "Defina el directorio de grabación de los informes de salida ($GRUPO01/informes):"
			Obtener_path INFODIR "Directorio de grabación de los informes de salida ($GRUPO01/informes):" "informes"
			echo
			# solicito valor de RECHDIR
			echo "Defina el directorio de grabacion de Archivos rechazados ($GRUPO01/rechazados):"
			Obtener_path RECHDIR "Directorio de grabación de Archivos rechazados ($GRUPO01/rechazados):" "rechazados"
			echo			
			# solicito valor de LOGDIR
			echo "Defina el directorio de logs ($GRUPO01/log):"
			Obtener_path LOGDIR "Directorio de logs ($GRUPO01/log):" "log"
			echo
			# solicito valor de LOGEXT (EXTENSION)
			echo "Ingrese la extension para los archivos de log (.log):"
			Obtener_valor LOGEXT "La extension para los archivos de log es:" ".log" 
			echo 
			#verifico valor maximo para los archivos de log LOGSIZE
			echo "Defina el tamaño maximo para los archivos $LOGEXT en Kbytes ($LOGSIZE):"		
			Obtener_numero LOGSIZE "Tamaño maximo para los archivos $LOGEXT en Kbytes ($LOGSIZE):" "error" $LOGSIZE 1		
			clear
			# estructura de directorios resultante y valores de los parámetros configurados
			echo "TP SO7508 Primer Cuatrimestre 2014. Tema C Copyright © Grupo 01"
			Path_y_Archivos "Direct. de Configuracion: " "$GRUPO01/$CONFDIR" 1
			Path_y_Archivos "Directorio Ejecutables: " "$BINDIR" 1
			Path_y_Archivos "Directorio Maestros y Tablas:" "$MAEDIR" 1
			Path_y_Archivos "Directorio de Novedades:" "$NOVEDIR" 0
			Path_y_Archivos "Espacio mínimo libre para arribos:" "$DATASIZE Mb" 0
			Path_y_Archivos "Directiorio Novedades Aceptadas:" "$ACEPDIR" 0
			Path_y_Archivos "Directorio Informes de Salida:" "$INFODIR" 0
			Path_y_Archivos "Directorio Archivos Rechazados:" "$RECHDIR" 0
			echo "Directorio de Logs de Comandos: $LOGDIR /<comando> $LOGEXT"
			echo "Tamano maximo para los archivos de log del sistema:" "$LOGSIZE" "Kb"
			echo "Estado de la instalacion: LISTA"
			Pregunta_SiNo "Iniciando Instalación. Esta Ud. seguro? (Si-No)"
			instalar=$?			
			respuestaInstalacion="si"
			if [ $instalar -eq 0 ]
			then
				respuestaInstalacion="no"
			fi
			./Logging Installer "Iniciando Instalacion. Esta Ud. seguro? (Si-No): $respuestaInstalacion" INFO
		done
		Creacion_de_directorios
		Instalacion_archivos
		Actualizacion_archivos_configuracion
		echo "INSTALACION CONCLUIDA"
		./Logging Installer "Intalacion CONCLUIDA" INFO 
	fi
	chmod 777 "$BINDIR"/Initializer.sh
fi















