#!/bin/bash

function alta {

arch=$1
i=0

regOK=0
regNOK=0

while read -r linea
do
	if [ "$i" -eq 0 ] || [ -z "$linea" ] ; then
		let i=i+1		
		continue
		#es cabecera o en blanco
	fi

	superID=$2
	usuario=$3
	fecha=$4$5$6

	cantCampos=`echo $linea|sed 's/[^;]//g'|wc -m`
	if [ $cantCampos -ne $7 ] ; then
		let regNOK=regNOK+1
		continue
	fi

	prod=`echo "$linea" | cut -s -f"$8" -d';'`
	precio=`echo "$linea" | cut -s -f"$9" -d';'`

	if [ "$prod" = "" ] || [ "$precio" = "" ] || [[ "$prod" =~ ^\ *$ ]] || [[ "$precio" =~ ^\ *$ ]] ; then
		let regNOK=regNOK+1
		continue
	fi

	let regOK=regOK+1

	echo "$superID;$usuario;$fecha;$prod;$precio" >> ./$MAEDIR/precios.mae
done < "$arch"

./Logging Masterlist "Registros OK: "$regOK INFO
./Logging Masterlist "Registros NOK: "$regNOK INFO

return 0

}


function reemplazo {

arch=$1

#borro todos los que voy a reemplazar

regBorrados=grep -c '^'"$superID"';'"$usuario"';'"$4$5$6"';[^;]\+;[0-9]\+$' ./$MAEDIR/precios.mae
sed -i '/^'"$superID"';'"$usuario"';'"$4$5$6"';[^;]\+;[0-9]\+$/d' ./$MAEDIR/precios.mae

./Logging Masterlist "Registros borrados: "$regBorrados INFO

#llamo a alta
alta $1 $2 $3 $4 $5 $6 $7 $8 $9

return 0

}




./Logging Masterlist "Inicio de Masterlist" INFO

archPrecios=($MAEDIR/precios/*.txt)
cantArchProc=${#archPrecios[@]}
./Logging Masterlist "Cantidad de listas a procesar: $cantArchProc" INFO

if [ ! $cantArchProc -eq 0 ] ; then

for arch in $MAEDIR/precios/*.txt
do
	nombre=`basename "$arch"`
	./Logging Masterlist "Archivo a procesar: $nombre" INFO

	#verifico que no este duplicado
	if [ -f $MAEDIR/precios/proc/"$nombre" ] ; then
		./Mover $arch $RECHDIR Masterlist
		./Logging Masterlist "Se rechaza archivo por estar DUPLICADO" INFO
		continue
	fi

	#valido registro cabecera
	#valido extra que los campos numericos realmente sean numericos
	cabecera=`sed -n -e 1p "$arch"`
	
	nombreSuper=`echo $cabecera | cut -s -f1 -d';'`
	prov=`echo $cabecera | cut -s -f2 -d';'`
	cantCampos=`echo $cabecera | cut -s -f3 -d';'`
	ubicProd=`echo $cabecera | cut -s -f4 -d';'`
	ubicPrecio=`echo $cabecera | cut -s -f5 -d';'`
	email=`echo $cabecera | cut -s -f6 -d';'`

	if ! grep -q '^[^;]\+;'"$prov"';'"$nombreSuper"';[0-9]*;[^;]*;[^;]\+$' $MAEDIR/super.mae ; then
		./Mover $arch $RECHDIR Masterlist
		./Logging Masterlist "Se rechaza archivo por Supermercado inexistente" INFO
		continue
	fi

	if [ "$cantCampos" -lt 1 ] ; then
		./Mover $arch $RECHDIR Masterlist
		./Logging Masterlist "Se rechaza archivo por cantidad de campos invalida" INFO
		continue
	fi

	re='^[0-9]+$'

	if ! [[ $ubicProd =~ $re ]] || [ "$ubicProd" -eq "$ubicPrecio" ] || [ "$ubicProd" -lt 0 ] ; then
		./Mover $arch $RECHDIR Masterlist
		./Logging Masterlist "Se rechaza archivo por ubicacion producto invalida" INFO
		continue
	fi

	if ! [[ $ubicPrecio =~ $re ]] || [ "$ubicProd" -eq "$ubicPrecio" ] || [ "$ubicPrecio" -lt 0 ] ; then
		./Mover $arch $RECHDIR Masterlist
		./Logging Masterlist "Se rechaza archivo por ubicacion precio invalida" INFO
		continue
	fi

	usuario=`echo "$nombre" | sed s-'^[^\.]*\.[0-9]\{8\}\.\([^-]*\)\.txt$-\1-'`
	
	if ! grep -q '^[^;]*;[^;]*;'$usuario';1;'"$email"'$' $MAEDIR/asociados.mae ; then
		./Mover $arch $RECHDIR Masterlist
		./Logging Masterlist "Se rechaza archivo por correo electronico invalido" INFO
		continue
	fi

	#fin validaciones
	
	#me quedo registro de la tabla de supermercados
	# y obtengo el id del super
	registro=`grep '^[^;]\+;'"$prov"';'"$nombreSuper"';[0-9]*;[^;]*;[^;]\+$' $MAEDIR/super.mae`
	superID=`echo "$registro" | cut -s -f1 -d';'`

	#analizo si es alta o reemplazo
	registro=`grep '^'"$superID"';'"$usuario"';[0-9]\{8\};[^;]\+;[0-9]\+$' $MAEDIR/precios.mae | head -n1 `
	
	anioViejo=`echo "$registro" | sed s-'^[^;]\+;[^;]\+;\([0-9]\{4\}\)[0-9]\{4\};[^;]\+;[0-9]\+$-\1-'`
	mesViejo=`echo "$registro" | sed s-'^[^;]\+;[^;]\+;[0-9]\{4\}\([0-9]\{2\}\)[0-9]\{2\};[^;]\+;[0-9]\+$-\1-'`
	diaViejo=`echo "$registro" | sed s-'^[^;]\+;[^;]\+;[0-9]\{6\}\([0-9]\{2\}\);[^;]\+;[0-9]\+$-\1-'`

	anioNuevo=`echo "$nombre" | sed s-'^.*\.\([0-9]\{4\}\)[0-9]\{4\}\.[^-]*\.txt$-\1-'`
	mesNuevo=`echo "$nombre" | sed s-'^.*\.[0-9]\{4\}\([0-9]\{2\}\)[0-9]\{2\}\.[^-]*\.txt$-\1-'`
	diaNuevo=`echo "$nombre" | sed s-'^.*\.[0-9]\{6\}\([0-9]\{2\}\)\.[^-]*\.txt$-\1-'`

	if [ -z "$registro" ] || [ "$registro" = "" ] ; then
		#PROCESAR ALTA
		alta $arch $superID $usuario $anioNuevo $mesNuevo $diaNuevo $cantCampos $ubicProd $ubicPrecio
		./Mover $arch $MAEDIR/precios/proc
		continue
	fi

	if [ "$anioNuevo" -gt "$anioViejo" ] ; then
		#PROCESAR REEMPLAZO
		reemplazo $arch $superID $usuario $anioNuevo $mesNuevo $diaNuevo $cantCampos $ubicProd $ubicPrecio
		./Mover $arch $MAEDIR/precios/proc
	elif [ "$anioNuevo" -eq "$anioViejo" ] && [ "$mesNuevo" -gt "$mesViejo" ] ; then
		#PROCESAR REEMPLAZO
		reemplazo $arch $superID $usuario $anioNuevo $mesNuevo $diaNuevo $cantCampos $ubicProd $ubicPrecio
		./Mover $arch $MAEDIR/precios/proc
	elif [ "$anioNuevo" -eq "$anioViejo" ] && [ "$mesNuevo" -eq "$mesViejo" ] && [ "$diaNuevo" -gt "$diaViejo" ] ; then
		#PROCESAR REEMPLAZO
		reemplazo $arch $superID $usuario $anioNuevo $mesNuevo $diaNuevo $cantCampos $ubicProd $ubicPrecio
		./Mover $arch $MAEDIR/precios/proc
	else
		#HIPOTESIS: ANTE FECHAS IGUALES SE DESCARTA
		#DESCARTAR
		./Mover $arch $RECHDIR Masterlist
		./Logging Masterlist "Se rechaza archivo por fecha anterior o igual a la existente" INFO
		continue
	fi

done

fi

./Logging Masterlist "Fin de Masterlist" INFO



