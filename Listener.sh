#!/bin/bash

while [ 0 ]
do

#Grabo numero de ciclo
numLog=`grep "Ciclo numero: "'.*$' "$LOGDIR"/Listener."$LOGEXT" | tail -1 | sed s-'.*\ Ciclo numero: \([0-9]\+\)-\1-' `

let numLog=numLog+1

./Logging Listener "Ciclo numero: $numLog" INFO


#Chequeo el formato

t_compras=1
t_precios=1

for arch in $NOVEDIR/* 
do
	nombre=`basename "$arch"`

	t_compras=`echo "$nombre" | sed s-'^[^-.]*\.[^-\ .]*\.txt$-0-'`
	t_precios=`echo "$nombre" | sed s-'^[^.]*\.[0-9]\{8\}\.[^-.]*\.txt$-0-'`

	if [ "$t_compras" != 0 ] && [ "$t_precios" != 0 ] ; then
		./Logging Listener "Archivo: $nombre rechazado por formato invalido" ERR
		./Mover $arch $RECHDIR Listener
		continue	
		#formato
	elif [ "$t_compras" = 0 ] ; then
		usuario=`echo "$nombre" | sed s-'^\([^-]*\)\.[^-\\ ]*\.txt$-\1-'`
		
		existe=0
		existe=`grep -c '^[^;]*;[^;]*;'$usuario';[01];\?[^;]*$' $MAEDIR/asociados.mae`
		if [ "$existe" = 0 ] ; then
			./Logging Listener "Archivo: $nombre rechazado porque usuario es inexistente" ERR
			./Mover $arch $RECHDIR Listener	
			continue
			#usuario no en campo de asociados
		fi

		#lo acepto
		./Logging Listener "Archivo de lista de compras: $nombre aceptado" INFO
		./Mover $arch $ACEPDIR Listener	
			

	elif [ "$t_precios" -eq 0 ] ; then
		anioIngr=`echo "$nombre" | sed s-'^.*\.\([0-9]\{4\}\)[0-9]\{4\}\.[^-]*\.txt$-\1-'`
		mesIngr=`echo "$nombre" | sed s-'^.*\.[0-9]\{4\}\([0-9]\{2\}\)[0-9]\{2\}\.[^-]*\.txt$-\1-'`
		diaIngr=`echo "$nombre" | sed s-'^.*\.[0-9]\{6\}\([0-9]\{2\}\)\.[^-]*\.txt$-\1-'`
		
		anioAct=`date +%y`
		let anioAct=2000+$anioAct

		mesAct=`date +%m`
		diaAct=`date +%e`

		if [ "$anioIngr" -gt "$anioAct" ] ; then
			./Logging Listener "Archivo: $nombre rechazado porque la fecha es invalida 1" ERR
			./Mover $arch $RECHDIR Listener	
			continue		
			#fecha invalida
		elif [ "$anioIngr" -eq "$anioAct" ] && [ "$mesIngr" -gt "$mesAct" ] ; then
			./Logging Listener "Archivo: $nombre rechazado porque la fecha es invalida 2" ERR
			./Mover $arch $RECHDIR Listener
			continue
			#fecha invalida
		elif [ "$anioIngr" -eq "$anioAct" ] && [ "$mesIngr" -eq "$mesAct"  ] && [ "$diaIngr" -gt "$diaAct" ] ; then
			./Logging Listener "Archivo: $nombre rechazado porque la fecha es invalida 3" ERR
			./Mover $arch $RECHDIR Listener		
			continue	
			#fecha invalida
		fi


		if [ "$anioIngr" -lt 2014 ] ; then
			./Logging Listener "Archivo: $nombre rechazado porque la fecha es invalida (Antes de inicio del sistema)" ERR
			./Mover $arch $RECHDIR Listener
			continue
			#fecha invalida
		fi


		usuario=`echo "$nombre" | sed s-'^[^\.]*\.[0-9]\{8\}\.\([^-]*\)\.txt$-\1-'`

		esColab=2
		#HIPOTESIS: si hay dos usuarios iguales y alguno es colaborador, consideramos archivo valido
		while read -r reg ; do
   			esColab=`echo "$reg" | cut -s -f4 -d';'`
			if [ "$esColab" -eq 1 ] ; then
				break
			fi 
		done < <(grep '^[^;]*;[^;]*;'$usuario';[01];\?[^;]*$' $MAEDIR/asociados.mae)

		if [ "$esColab" != 1 ] ; then
			./Logging Listener "Archivo: $nombre rechazado porque colaborador es inexistente" ERR
			./Mover $arch $RECHDIR Listener
			continue	
			#usuario no existe o no es colaborador
		fi

		./Logging Listener "Archivo de lista de precios: $nombre aceptado" INFO
		./Mover $arch $MAEDIR/precios Listener	

	fi
done

ratingCorriendo=0
masterlistCorriendo=0

shopt -s nullglob
files=($MAEDIR/precios/*.txt)
if [ ${#files[@]} -gt 0 ] ; then

	pidRat=`ps -ef | grep Rating.sh | grep -e grep -e Listener.sh -v`
	pidRat=`echo $pidRat | sed 's-^[^\ ]\+\ \([0-9]\+\)\ .*$-\1-g'` 
	pidMstLst=`ps -ef | grep Rating.sh | grep -e grep -e Listener.sh -v`
	pidMstLst=`echo $pidMstLst | sed 's-^[^\ ]\+\ \([0-9]\+\)\ .*$-\1-g'` 

	if [ "$pidRat" = "" ] && [ "$pidMstLst" = "" ] ; then
		./Start Masterlist.sh
		if [ $? = 0 ] ; then
			pid=`ps -ef | grep  "Masterlist.sh" | grep -e grep -v`
			pid=`echo $pid | sed 's-^[^\ ]\+\ \([0-9]\+\)\ .*$-\1-g'` 
			./Logging Listener "Masterlist corriendo bajo el numero: $pid" INFO
			#grabar en log
		else
			./Logging Listener "No se pudo lanzar Rating" WAR
		fi			
	fi
fi

ratingCorriendo=0
masterlistCorriendo=0

files=($ACEPDIR/*.txt)
if [ ${#files[@]} -gt 0 ] ; then

	pidRat=`ps -ef | grep Rating.sh | grep -e grep -e Listener.sh -v`
	pidRat=`echo $pidRat | sed 's-^[^\ ]\+\ \([0-9]\+\)\ .*$-\1-g'` 
	pidMstLst=`ps -ef | grep Rating.sh | grep -e grep -e Listener.sh -v`
	pidMstLst=`echo $pidMstLst | sed 's-^[^\ ]\+\ \([0-9]\+\)\ .*$-\1-g'` 

	if [ "$pidRat" = "" ] && [ "$pidMstLst" = "" ] ; then
		./Start Rating.sh
		if [ $? = 0 ] ; then
			pid=`ps -ef | grep "Rating.sh" | grep -e grep -v`
			pid=`echo $pid | sed 's-^[^\ ]\+\ \([0-9]\+\)\ .*$-\1-g'` 
			./Logging Listener "Rating corriendo bajo el numero: $pid" INFO
			#grabar en log
		else
			./Logging Listener "No se pudo lanzar Rating" WAR
		fi
	fi
fi

sleep 30

done












