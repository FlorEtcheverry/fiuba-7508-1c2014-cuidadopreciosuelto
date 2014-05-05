#! /usr/bin/perl

# ------------
# INICIO MAIN.
# ------------
system("clear");

$opcion = "";

while ($opcion ne "-exit")
{
	# print "\n\n";
	print "----------------------------------------------------------------------------------\n";
	print "1ra entrada --> Opcion de proceso ('-a' para mas informacion | '-exit' para salir)\n";
	print "2da entrada --> Path de la carpeta con Listas Presupuestadas\n";
	print "3ra entrada --> Filtro de usuario\n";
	print "4ta entrada --> Filtro de Supermercado\n";
	print "5ta entrada --> Opcion de grabado ('-w') [y/n]\n";
	print "----------------------------------------------------------------------------------\n";

	print "1ra entrada: ";
	$opcion = <STDIN>;
	chomp($opcion);

	if ($opcion ne "-exit" and  $opcion ne "-a" and $opcion ne "-w" and $opcion ne "-r" and $opcion ne "-m" and $opcion ne "-d" and $opcion ne "-f" and $opcion ne "-mr" and $opcion ne "-dr")
	{
		print "No existe comando '$opcion'. Por favor ingrese '-a' para Ayuda.\n";
		$opcion = <STDIN>;
		next;
	}

	if ($opcion eq "-a")
	{
		&MostrarMenuA_Ayuda;
	}
	
	if ($opcion eq "-r" or $opcion eq "-m" or $opcion eq "-d" or $opcion eq "-f" or $opcion eq "-mr" or $opcion eq "-dr")
	{
		print "2da entrada: ";
		$pathLP = <STDIN>;
		chomp($pathLP);

		print "3ra entrada: ";
		$filtroUsuario = <STDIN>;
		chomp($filtroUsuario);

		print "4ta entrada: ";
		$filtroSuper = <STDIN>;
		chomp($filtroSuper);

		print "5ta entrada [y/n]: ";
		$opcionDeGrabado = <STDIN>;
		chomp($opcionDeGrabado);
	
		# -----------------------------------------------
		# Cargamos en un array todas las listas del path.
		# -----------------------------------------------

		@arrayLP = &CargarArrayLP($pathLP, $filtroUsuario);

		open(SUPER, "SUPER.MAE") || die "ERROR: el archivo de SUPER.MAE no existe";
		
		# -----------------------------------
		# Cargamos la Lista de Supermercados.
		# -----------------------------------
		%hashSuper = (0, "Informacion", 1, "Precios Cuidados");
		
		while ($lineaEntrada = <SUPER>)
		{
			@arrayData = split(";", $lineaEntrada);
			$id = $arrayData[0];
			$nombre_provincia = $arrayData[2]."-".$arrayData[1];
			$hashSuper{$id} = $nombre_provincia;
		}	
		
		# ----------------------------------------
		# Segun la opcion ingresa muestro la info.
		# ----------------------------------------
		if ($opcion eq "-r")
		{
			&MostrarMenuR_Referencia(\@arrayLP, $#arrayLP, \%hashSuper, $opcionDeGrabado);
		}
	
		if ($opcion eq "-m")
		{
			&MostrarMenuM_MenorPrecio(\@arrayLP, $#arrayLP, \%hashSuper, $filtroSuper, $opcionDeGrabado);
		} 

		if ($opcion eq "-d")
		{
			if ($opcionDeGrabado eq "y"){
				&MostrarMenuDArchivo(\@arrayLP, $filtroSuper, \%hashSuper ,$#arrayLP);
			}
			else{
				&MostrarMenuDPantalla(\@arrayLP, $filtroSuper, \%hashSuper ,$#arrayLP);
			}
		}
	
		if ($opcion eq "-f")
		{
			&MostrarMenuF_Faltante(\@arrayLP, $#arrayLP, \%hashSuper, $filtroSuper, $opcionDeGrabado);
		}

		if ($opcion eq "-mr")
		{
			if ($opcionDeGrabado eq "y"){
				&MostrarMenuMRArchivo(\@arrayLP, $filtroSuper, \%hashSuper ,$#arrayLP);
			}
			else{
				&MostrarMenuMRPantalla(\@arrayLP, $filtroSuper, \%hashSuper ,$#arrayLP);
			}
		}
		
		if ($opcion eq "-dr")
		{
			if ($opcionDeGrabado eq "y"){
				&MostrarMenuDR_DondeComprarYReferenciaArch(\@arrayLP, $filtroSuper, \%hashSuper ,$#arrayLP);
			}
			else{
				&MostrarMenuDR_DondeComprarYReferenciaPantalla(\@arrayLP, $filtroSuper, \%hashSuper ,$#arrayLP);
			}
		}

		close (LISTA_PRESUPUESTADA);
		close (SUPER);
	}
}

system ("clear");
# ---------
# FIN MAIN.
# ---------

# ---------------------------------------------------------------------------------------------
# SUB, Cargo el array de Listas Presupuestadas evitando el nivel anterior (.) y posterior (..).
# ---------------------------------------------------------------------------------------------
sub CargarArrayLP
{
	@array = ();

	if (opendir(DIR, $_[0]))
	{
		@arrayListas = readdir(DIR);
		close(DIR);
	}

	for (my $i=0; $i<=$#arrayListas; $i++)
	{	
		next if ($arrayListas[$i] eq "." || $arrayListas[$i] eq "..");
		
		if (length($_[1]) > 0)
		{
			if ($arrayListas[$i] =~ /$_[1].[0_9]*/)
			{
				push(@array, $arrayListas[$i]);
			}
		}
		else
		{
			if ($arrayListas[$i] =~ /[^.]*.[0_9]*/)
			{
		 		push(@array, $arrayListas[$i]);
			}
		}
	}

	return (@array);
}

# ------------------------------
# SUB, Muestra el Menu de Ayuda.
# ------------------------------
sub MostrarMenuA_Ayuda
{
	system("clear");

	print "----------------------------------------------------------------------------------------\n";
	print "1ra entrada:\n";
	print "		'-a' --> Ayuda.\n";
	print "		'-r' --> Precio de referencia (Precios Cuidados).\n";
	print "		'-m' --> Menor precio.\n";
	print "		'-d' --> Donde Comprar.\n";
	print "		'-f' --> Faltante.\n";
	print "		'-exit' --> Salir.\n";
	print "2da entrada:\n";
	print "		Path ubicacion 'Listas Presupuestadas' a procesar.\n";
	print "3ra entrada:\n";
	print "		Filtro de Usuario\n";
	print "4ta entrada:\n";
	print "		Filtro de ID de Supermercado\n";
	print "5ta entrada:\n";
	print "		'-w' [y/n] --> Opcion de Grabado\n";
	print "			       [y] no muestra por pantalla y graba en archivo de salida.\n";
	print "			       [n] muestra por pantalla.\n";
	print "----------------------------------------------------------------------------------------\n\n";
}

# -----------------------------------------------------------------
# SUB, Muestra la info de precios de Referencia (Precios Cuidados).
# -----------------------------------------------------------------
sub MostrarMenuR_Referencia
{
	system("clear");

	if ($_[3] eq "y")
	{
		($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
		$year += 1900;
		$mon++;
		$ext = $year.$mon.$mday.$hour.$min.$sec;

		open(SALIDA, ">info.$ext");
	}

	for ($i=0; $i<=$_[1]; $i++)
	{
		if ($_[3] eq "y")
		{
			print SALIDA "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA --> $_[0][$i]\n";
		}
		else
		{
			print "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA --> $_[0][$i]\n";
		}

		open (LISTA, $_[0][$i]);
		$infoSalida = "";
		
		while ($linea = <LISTA>)
		{
			chomp($linea);

			if ($linea =~ /[^;]*;[^;]*;1;.*/)
			{
				my @arrayData = split(";", $linea);

				if ($_[3] eq "y")
				{
					$infoSalida = $infoSalida."$arrayData[0] \| $arrayData[1] \| $arrayData[3] \| $arrayData[4] \| $_[2]{$arrayData[2]}\n";
				}
				else
				{
					print "$arrayData[0] \| $arrayData[1] \| $arrayData[3] \| $arrayData[4] \| $_[2]{$arrayData[2]}\n";
				}
			}
		}

		if ($_[3] eq "y")
		{
			print SALIDA "$infoSalida\n";
		}
	
		print "\n";

		close (LISTA);
	}

	if ($_[3] eq "y")
	{
		close(SALIDA);
	}
}

# ------------------------------------------------------------------
# SUB, Muestra la info de Menor Precio (omite los Precios Cuidados).
# ------------------------------------------------------------------
sub MostrarMenuM_MenorPrecio
{
	system("clear");

	if ($_[4] eq "y")
	{
		($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
		$year += 1900;
		$mon++;
		$ext = $year.$mon.$mday.$hour.$min.$sec;

		open(SALIDA,">info.$ext");
	}

	for (my $i=0; $i<=$_[1];$i++)
	{
		if ($_[4] eq "y")
		{
			print SALIDA "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA --> $_[0][$i]\n";
		}
		else
		{
			print "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA --> $_[0][$i]\n";
		}

		my $idMenor = 0;
		my $productoMenor = "";
		my $superIdMenor = 0;
		my $descripcionMenor = "";
		my $precioMenor = 9999;

		open (LISTA, $_[0][$i]);
		$infoSalida = "";
		$numeroPreciosCuidados = 0;

		while ($linea = <LISTA>)
		{
			chomp($linea);

			if (length($_[3]) > 0)
			{
				if ($linea !~ /^[^;]*;[^;]*;$_[3];.*/)
				{
					if ($idMenor > 0)
					{	
						if ($_[4] eq "y")
						{
							$infoSalida = $infoSalida."$idMenor \| $productoMenor \| $descripcionMenor \| $precioMenor \| $_[2]{$superIdMenor}\n";	
						}
						else
						{
							print "$idMenor \| $productoMenor \| $descripcionMenor \| $precioMenor \| $_[2]{$superIdMenor}\n";	
						}
					}

					$idMenor = 0;
					$productoMenor = "";
					$superIdMenor = 0;
					$descripcionMenor = "";
					$precioMenor = 9999;
					next;
				}
			}
			
			@arrayData = split(";", $linea);

			if ($linea =~ /[^;]*;[^;]*;1;.*/)
			{
				if ($idMenor > 0)
				{
					if ($_[4] eq "y")
					{
						$infoSalida = $infoSalida."$idMenor \| $productoMenor \| $descripcionMenor \| $precioMenor \| $_[2]{$superIdMenor}\n";
					}
					else
					{	
						print "$idMenor \| $productoMenor \| $descripcionMenor \| $precioMenor \| $_[2]{$superIdMenor}\n";					}
				}

				$idMenor = 0;
				$productoMenor = "";
				$superIdMenor = 0;
				$descripcionMenor = "";
				$precioMenor = 9999;
			}
			else
			{
				if (length($arrayData[4]) > 0)
				{
					if ($arrayData[4] <= $precioMenor)
					{
						$idMenor = $arrayData[0];
						$productoMenor = $arrayData[1];
						$superIdMenor = $arrayData[2];
						$descripcionMenor = $arrayData[3];
						$precioMenor = $arrayData[4];
					}
				}
			}
		}
		
		if ($idMenor > 0)
		{	
			if ($_[4] eq "y")
			{
				$infoSalida = $infoSalida."$idMenor \| $productoMenor \| $descripcionMenor \| $precioMenor \| $_[2]{$superIdMenor}\n";	
			}
			else
			{
				print "$idMenor \| $productoMenor \| $descripcionMenor \| $precioMenor \| $_[2]{$superIdMenor}\n";	
			}
		}

		if ($_[4] eq "y")
		{
			print SALIDA "$infoSalida\n";
		}
	
		print "\n";
	}

	if ($_[4] eq "y")
	{
		close(SALIDA);
	}
}

# ------------------------------------------
# SUB, Muestra la info de precios faltantes.
# ------------------------------------------
sub MostrarMenuF_Faltante
{
	system("clear");

	if ($_[4] eq "y")
	{
		($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
		$year += 1900;
		$mon++;
		$ext = $year.$mon.$mday.$hour.$min.$sec;
	
		open(SALIDA,">info.$ext");
	}

	for (my $i=0;$i<=$_[1];$i++)
	{
		if ($_[4] eq "y")
		{
			print SALIDA "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA --> $_[0][$i]\n";
		}
		else
		{
			print "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA --> $_[0][$i]\n";
		}

		open (LISTA, $_[0][$i]);
		$infoSalida = "";

		while ($linea = <LISTA>)
		{
			if (length($_[3]) > 0)
			{
				if ($linea !~ /^[^;]*;[^;]*;$_[3];.*/)
				{
					next;
				}
			}

			chomp($linea);
			$chr = chop($linea);
	
			if ($chr eq ';')
			{
				$linea = $linea.";";
				my @arrayData = split(";",$linea);
			
				# leo el ID del SUPER
				if (length($arrayData[2]) > 0)
				{	
					if ($_[4] eq "y")
					{
						$infoSalida = $infoSalida."$arrayData[0] \| $arrayData[1] \| $arrayData[3] \| $arrayData[4] \| $_[2]{$arrayData[2]}\n";
					}
					else
					{
						print "$arrayData[0] \| $arrayData[1] \| $arrayData[3] \| $arrayData[4] \| $_[2]{$arrayData[2]}\n";
					}
				}
				else
				{
					if ($_[4] eq "y")
					{
						$infoSalida = $infoSalida."$arrayData[0] \| $arrayData[1] \| $arrayData[2] \| $arrayData[3] \| $arrayData[4]\n";
					}
					else
					{
						print "$arrayData[0] \| $arrayData[1] \| $arrayData[2] \| $arrayData[3] \| $arrayData[4]\n";
					}
				}
			}
		}

		if ($_[4] eq "y")
		{
			print SALIDA "$infoSalida\n";
		}

		print "\n";
	}

	if ($_[4] eq "y")
	{
		close(SALIDA);
	}
}

#/home/juan/Documents/facultad/fiuba-7508-1c2014-cuidadopreciosuelto/informes/pres

# ------------------------------------------
# SUB, Muestra la info plus precios de referencia, agrupados por lugar e imprime a un archivo.
# ------------------------------------------
sub MostrarMenuDR_DondeComprarYReferenciaArch
{

	($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
	$year += 1900;
	$mon++;
	$ext = $year.$mon.$mday.$hour.$min.$sec;
	open(SALIDA,">info.$ext");

	for ( my $i=0; $i<=$_[3]; $i++ ){

	print SALIDA "NOMBRE_SUPER-PROVINCIA \| NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| PRECIO de REFERENCIA \| Observaciones   --> $_[0][$i]\n";

		
		open (LISTA, $_[0][$i]);


		#me creo hashes que tendran los productos como claves
		my %hashPrecios=();
		my %hashPreciosCuidados=();
		my %hashLugares=();
		my %hashNumItem=();
		my %hashDescripcion=();

		my @arrayLineaProducto=();


		while($linea = <LISTA>){

			#obtengo los campos del registro de la lista presupuesteada que estoy analizando 
			@arrayLineaProducto = split(";", $linea);

			#Me fijo si es de precios cuidados, entonces SUPER ID debe ser menor a 100
			#si lo es guardo el menor de los precios cuidados y saltear.
			if ( $arrayLineaProducto[2] < 100 ){
				if (! exists( $hashPreciosCuidados{$arrayLineaProducto[1]} ) ) {
					$hashPreciosCuidados{$arrayLineaProducto[1]}=$arrayLineaProducto[4];
				}#si esta obviamente comparo y si el precio es mejor reemplazo
				else{
					if ( $hashPreciosCuidados{$arrayLineaProducto[1]} > $arrayLineaProducto[4] ){
						$hashPreciosCuidados{$arrayLineaProducto[1]}=$arrayLineaProducto[4];
					}
				}
				next;
			}
			#Ahora si no es precio cuidado:
			#si el producto no esta en el hash lo meto con el precio y el super ID en el otro hash
			if (! exists( $hashPrecios{$arrayLineaProducto[1]} ) ) {
				$hashPrecios{$arrayLineaProducto[1]}=$arrayLineaProducto[4];
				$hashLugares{$arrayLineaProducto[1]}=$arrayLineaProducto[2];
				$hashNumItem{$arrayLineaProducto[1]}=$arrayLineaProducto[0];
				$hashDescripcion{$arrayLineaProducto[1]}=$arrayLineaProducto[3];
			}#si esta obviamente comparo y si el precio es mejor reemplazo
			else{
				#COMPARAR PRECIO ; REEMPLAZAR PRECIO Y LUGAR SI CORRESPONDE!!
				if ( $hashPrecios{$arrayLineaProducto[1]} > $arrayLineaProducto[4] ){
					$hashPrecios{$arrayLineaProducto[1]} = $arrayLineaProducto[4];
					$hashLugares{$arrayLineaProducto[1]} = $arrayLineaProducto[2];
					$hashNumItem{$arrayLineaProducto[1]}=$arrayLineaProducto[0];
					$hashDescripcion{$arrayLineaProducto[1]}=$arrayLineaProducto[3];
				}
			}
		}

		#necesito hacer esta basura o no empieza a recorrer por el ppio de nuevo
		close (LISTA);
		open (LISTA, $_[0][$i]);
		
		#todavia estando en la misma lista de presupuestos
		#recorro de nuevo separando por lugares, mostrando el precio cuidado correspondiente y el menor precio que encontre antes
		my $Super_ID="";
		my $cambioLugar = 0;

		while($linea = <LISTA>){
			@arrayLineaProducto = split(";", $linea);
			

			#el lugar viene dado por el super ID
			if ($Super_ID == ""){
				$Super_ID = $arrayLineaProducto[2];
				$cambioLugar = 1;
			}else{
				if ( $Super_ID == $arrayLineaProducto[2] ){
					$cambioLugar = 0;
				}else{
					print SALIDA "\n";	
					$Super_ID = $arrayLineaProducto[2];
					$cambioLugar = 1;
				}
			}

			my $observ="";

			if ( $cambioLugar ){
			#recorro hashLugares por claves, si encuentro un value coincidente uso la clave para hash precios e imprimo ; luego elimino ese producto de ambos hashes
				foreach $clave (keys %hashPrecios){

					if ( $hashLugares{$clave} eq $Super_ID ) {
						if ( $hashPrecios{$clave} > $hashPreciosCuidados{$clave} )
							{ $observ="**" ;}
						if ( $hashPrecios{$clave} <= $hashPreciosCuidados{$clave} )
							{ $observ="*" ;}
						if ( $hashPreciosCuidados{$clave} == "" )
							{ $observ="***" ;}

#NOMBRE_SUPER-PROVINCIA \| NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| PRECIO de REFERENCIA \| Observaciones   

						print SALIDA "$_[2]{$Super_ID} \| $hashNumItem{$clave} \| $clave \| $hashDescripcion{$clave} \| $hashPrecios{$clave} \| $hashPreciosCuidados{$clave} \| $observ \n";
					#necesarios si no ordeno el archivo por lugares
					delete($hashPrecios{$clave});
					delete($hashPrecios{$clave});
					}
				}
			}

		}

		close(LISTA);		
	}

	close(SALIDA);
}


#/home/juan/Documents/facultad/fiuba-7508-1c2014-cuidadopreciosuelto/informes/pres

# ------------------------------------------
# SUB, Idem anterior pero esta imprime por pantalla. De hecho es copiada tal cual y solo cambio que mando los prints a pantalla y saco las cosas del archivo de salida.
# ------------------------------------------

sub MostrarMenuDR_DondeComprarYReferenciaPantalla
{

	for ( my $i=0; $i<=$_[3]; $i++ ){

		print "NOMBRE_SUPER-PROVINCIA \| NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| PRECIO de REFERENCIA \| Observaciones   --> $_[0][$i]\n";
		
		open (LISTA, $_[0][$i]);


		#me creo hashes que tendran los productos como claves
		my %hashPrecios=();
		my %hashPreciosCuidados=();
		my %hashLugares=();
		my %hashNumItem=();
		my %hashDescripcion=();

		my @arrayLineaProducto=();


		while($linea = <LISTA>){

			#obtengo los campos del registro de la lista presupuesteada que estoy analizando 
			@arrayLineaProducto = split(";", $linea);

			#Me fijo si es de precios cuidados, entonces SUPER ID debe ser menor a 100
			#si lo es guardo el menor de los precios cuidados y saltear.
			if ( $arrayLineaProducto[2] < 100 ){
				if (! exists( $hashPreciosCuidados{$arrayLineaProducto[1]} ) ) {
					$hashPreciosCuidados{$arrayLineaProducto[1]}=$arrayLineaProducto[4];
				}#si esta obviamente comparo y si el precio es mejor reemplazo
				else{
					if ( $hashPreciosCuidados{$arrayLineaProducto[1]} > $arrayLineaProducto[4] ){
						$hashPreciosCuidados{$arrayLineaProducto[1]}=$arrayLineaProducto[4];
					}
				}
				next;
			}
			#Ahora si no es precio cuidado:
			#si el producto no esta en el hash lo meto con el precio y el super ID en el otro hash
			if (! exists( $hashPrecios{$arrayLineaProducto[1]} ) ) {
				$hashPrecios{$arrayLineaProducto[1]}=$arrayLineaProducto[4];
				$hashLugares{$arrayLineaProducto[1]}=$arrayLineaProducto[2];
				$hashNumItem{$arrayLineaProducto[1]}=$arrayLineaProducto[0];
				$hashDescripcion{$arrayLineaProducto[1]}=$arrayLineaProducto[3];
			}#si esta obviamente comparo y si el precio es mejor reemplazo
			else{
				#COMPARAR PRECIO ; REEMPLAZAR PRECIO Y LUGAR SI CORRESPONDE!!
				if ( $hashPrecios{$arrayLineaProducto[1]} > $arrayLineaProducto[4] ){
					$hashPrecios{$arrayLineaProducto[1]} = $arrayLineaProducto[4];
					$hashLugares{$arrayLineaProducto[1]} = $arrayLineaProducto[2];
					$hashNumItem{$arrayLineaProducto[1]}=$arrayLineaProducto[0];
					$hashDescripcion{$arrayLineaProducto[1]}=$arrayLineaProducto[3];
				}
			}
		}

		#necesito hacer esta basura o no empieza a recorrer por el ppio de nuevo
		close (LISTA);
		open (LISTA, $_[0][$i]);
		
		#todavia estando en la misma lista de presupuestos
		#recorro de nuevo separando por lugares, mostrando el precio cuidado correspondiente y el menor precio que encontre antes
		my $Super_ID="";
		my $cambioLugar = 0;

		while($linea = <LISTA>){
			@arrayLineaProducto = split(";", $linea);
			#el lugar viene dado por el super ID
			if ($Super_ID == ""){
				$Super_ID = $arrayLineaProducto[2];
				$cambioLugar = 1;
			}else{
				if ( $Super_ID == $arrayLineaProducto[2] ){
					$cambioLugar = 0;
				}else{
					print "\n";	
					$Super_ID = $arrayLineaProducto[2];
					$cambioLugar = 1;
				}
			}

			my $observ="";

			if ( $cambioLugar ){
			#recorro hashLugares por claves, si encuentro un value coincidente uso la clave para hash precios e imprimo ; luego elimino ese producto de ambos hashes
				foreach $clave (keys %hashPrecios){

					if ( $hashLugares{$clave} eq $Super_ID ) {
						if ( $hashPrecios{$clave} > $hashPreciosCuidados{$clave} )
							{ $observ="**" ;}
						if ( $hashPrecios{$clave} <= $hashPreciosCuidados{$clave} )
							{ $observ="*" ;}
						if ( $hashPreciosCuidados{$clave} == "" )
							{ $observ="***" ;}

#NOMBRE_SUPER-PROVINCIA \| NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| PRECIO de REFERENCIA \| Observaciones   

						print "$_[2]{$Super_ID} \| $hashNumItem{$clave} \| $clave \| $hashDescripcion{$clave} \| $hashPrecios{$clave} \| $hashPreciosCuidados{$clave} \| $observ \n";
					#necesarios si no ordeno el archivo por lugares
					delete($hashPrecios{$clave});
					delete($hashPrecios{$clave});
					}
				}
			}

		}

		close(LISTA);		
	}

}


#/home/juan/Documents/facultad/fiuba-7508-1c2014-cuidadopreciosuelto/informes/pres

# ------------------------------------------
# SUB, Muestra por menor precios plus el precio de referencia, imprime a un archivo
# ------------------------------------------
sub MostrarMenuMRArchivo
{

	($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
	$year += 1900;
	$mon++;
	$ext = $year.$mon.$mday.$hour.$min.$sec;
	open(SALIDA,">info.$ext");

	for ( my $i=0; $i<=$_[3]; $i++ ){

		print SALIDA "NOMBRE_SUPER-PROVINCIA \| NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| PRECIO de REFERENCIA \| Observaciones   --> $_[0][$i]\n";
	
		open (LISTA, $_[0][$i]);

		#me creo hashes que tendran los productos como claves
		my %hashPrecios=();
		my %hashPreciosCuidados=();
		my %hashLugares=();
		my %hashNumItem=();
		my %hashDescripcion=();

		my @arrayLineaProducto=();


		while($linea = <LISTA>){

			#obtengo los campos del registro de la lista presupuesteada que estoy analizando 
			@arrayLineaProducto = split(";", $linea);

			#Me fijo si es de precios cuidados, entonces SUPER ID debe ser menor a 100
			#si lo es guardo el menor de los precios cuidados y saltear.
			if ( $arrayLineaProducto[2] < 100 ){
				if (! exists( $hashPreciosCuidados{$arrayLineaProducto[1]} ) ) {
					$hashPreciosCuidados{$arrayLineaProducto[1]}=$arrayLineaProducto[4];
				}#si esta obviamente comparo y si el precio es mejor reemplazo
				else{
					if ( $hashPreciosCuidados{$arrayLineaProducto[1]} > $arrayLineaProducto[4] ){
						$hashPreciosCuidados{$arrayLineaProducto[1]}=$arrayLineaProducto[4];
					}
				}
				next;
			}
			#Ahora si no es precio cuidado:
			#si el producto no esta en el hash lo meto con el precio y el super ID en el otro hash
			if (! exists( $hashPrecios{$arrayLineaProducto[1]} ) ) {
				$hashPrecios{$arrayLineaProducto[1]}=$arrayLineaProducto[4];
				$hashLugares{$arrayLineaProducto[1]}=$arrayLineaProducto[2];
				$hashNumItem{$arrayLineaProducto[1]}=$arrayLineaProducto[0];
				$hashDescripcion{$arrayLineaProducto[1]}=$arrayLineaProducto[3];
			}#si esta obviamente comparo y si el precio es mejor reemplazo
			else{
				#COMPARAR PRECIO ; REEMPLAZAR PRECIO Y LUGAR SI CORRESPONDE!!
				if ( $hashPrecios{$arrayLineaProducto[1]} > $arrayLineaProducto[4] ){
					$hashPrecios{$arrayLineaProducto[1]} = $arrayLineaProducto[4];
					$hashLugares{$arrayLineaProducto[1]} = $arrayLineaProducto[2];
					$hashNumItem{$arrayLineaProducto[1]}=$arrayLineaProducto[0];
					$hashDescripcion{$arrayLineaProducto[1]}=$arrayLineaProducto[3];
				}
			}
		}
		
		#todavia estando en la misma lista de presupuestos
		#recorro los hashes mostrando lo pedido

		foreach $clave (keys %hashPrecios){
			if ( $hashPrecios{$clave} > $hashPreciosCuidados{$clave} )
				{ $observ="**" ;}
			if ( $hashPrecios{$clave} <= $hashPreciosCuidados{$clave} )
				{ $observ="*" ;}
			if ( $hashPreciosCuidados{$clave} == "" )
				{ $observ="***" ;}

#NOMBRE_SUPER-PROVINCIA \| NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| PRECIO de REFERENCIA \| Observaciones   
	
			print SALIDA "$_[2]{$Super_ID} \| $hashNumItem{$clave} \| $clave \| $hashDescripcion{$clave} \| $hashPrecios{$clave} \| $hashPreciosCuidados{$clave} \| $observ \n";
		}

		close(LISTA);		
	}

	close(SALIDA);
}

#/home/juan/Documents/facultad/fiuba-7508-1c2014-cuidadopreciosuelto/informes/pres

# ------------------------------------------
# SUB, Idem anterior pero muestra por pantalla
# ------------------------------------------
sub MostrarMenuMRPantalla
{

	for ( my $i=0; $i<=$_[3]; $i++ ){

		print "NOMBRE_SUPER-PROVINCIA \| NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| PRECIO de REFERENCIA \| Observaciones   --> $_[0][$i]\n";
	
		open (LISTA, $_[0][$i]);

		#me creo hashes que tendran los productos como claves
		my %hashPrecios=();
		my %hashPreciosCuidados=();
		my %hashLugares=();
		my %hashNumItem=();
		my %hashDescripcion=();

		my @arrayLineaProducto=();


		while($linea = <LISTA>){

			#obtengo los campos del registro de la lista presupuesteada que estoy analizando 
			@arrayLineaProducto = split(";", $linea);

			#Me fijo si es de precios cuidados, entonces SUPER ID debe ser menor a 100
			#si lo es guardo el menor de los precios cuidados y saltear.
			if ( $arrayLineaProducto[2] < 100 ){
				if (! exists( $hashPreciosCuidados{$arrayLineaProducto[1]} ) ) {
					$hashPreciosCuidados{$arrayLineaProducto[1]}=$arrayLineaProducto[4];
				}#si esta obviamente comparo y si el precio es mejor reemplazo
				else{
					if ( $hashPreciosCuidados{$arrayLineaProducto[1]} > $arrayLineaProducto[4] ){
						$hashPreciosCuidados{$arrayLineaProducto[1]}=$arrayLineaProducto[4];
					}
				}
				next;
			}
			#Ahora si no es precio cuidado:
			#si el producto no esta en el hash lo meto con el precio y el super ID en el otro hash
			if (! exists( $hashPrecios{$arrayLineaProducto[1]} ) ) {
				$hashPrecios{$arrayLineaProducto[1]}=$arrayLineaProducto[4];
				$hashLugares{$arrayLineaProducto[1]}=$arrayLineaProducto[2];
				$hashNumItem{$arrayLineaProducto[1]}=$arrayLineaProducto[0];
				$hashDescripcion{$arrayLineaProducto[1]}=$arrayLineaProducto[3];
			}#si esta obviamente comparo y si el precio es mejor reemplazo
			else{
				#COMPARAR PRECIO ; REEMPLAZAR PRECIO Y LUGAR SI CORRESPONDE!!
				if ( $hashPrecios{$arrayLineaProducto[1]} > $arrayLineaProducto[4] ){
					$hashPrecios{$arrayLineaProducto[1]} = $arrayLineaProducto[4];
					$hashLugares{$arrayLineaProducto[1]} = $arrayLineaProducto[2];
					$hashNumItem{$arrayLineaProducto[1]}=$arrayLineaProducto[0];
					$hashDescripcion{$arrayLineaProducto[1]}=$arrayLineaProducto[3];
				}
			}
		}
		
		#todavia estando en la misma lista de presupuestos
		#recorro los hashes mostrando lo pedido

		foreach $clave (keys %hashPrecios){
			if ( $hashPrecios{$clave} > $hashPreciosCuidados{$clave} )
				{ $observ="**" ;}
			if ( $hashPrecios{$clave} <= $hashPreciosCuidados{$clave} )
				{ $observ="*" ;}
			if ( $hashPreciosCuidados{$clave} == "" )
				{ $observ="***" ;}

#NOMBRE_SUPER-PROVINCIA \| NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| PRECIO de REFERENCIA \| Observaciones   
			
			print "$_[2]{$Super_ID} \| $hashNumItem{$clave} \| $clave \| $hashDescripcion{$clave} \| $hashPrecios{$clave} \| $hashPreciosCuidados{$clave} \| $observ \n";
		}

		close(LISTA);		
	}

}


#/home/juan/Documents/facultad/fiuba-7508-1c2014-cuidadopreciosuelto/informes/pres

# ------------------------------------------
# SUB, Muestra la info, agrupados por lugar e imprime a un archivo.
# ------------------------------------------
sub MostrarMenuDArchivo
{

	($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
	$year += 1900;
	$mon++;
	$ext = $year.$mon.$mday.$hour.$min.$sec;
	open(SALIDA,">info.$ext");

	for ( my $i=0; $i<=$_[3]; $i++ ){

	print SALIDA "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA --> $_[0][$i]\n";
		
		open (LISTA, $_[0][$i]);

		#me creo hashes que tendran los productos como claves
		my %hashPrecios=();
		my %hashLugares=();
		my %hashNumItem=();
		my %hashDescripcion=();

		my @arrayLineaProducto=();


		while($linea = <LISTA>){

			#obtengo los campos del registro de la lista presupuesteada que estoy analizando 
			@arrayLineaProducto = split(";", $linea);

			#Me fijo si es de precios cuidados y lo salteo.
			if ( $arrayLineaProducto[2] < 100 ){
				next;
			}
			#Ahora si no es precio cuidado:
			#si el producto no esta en el hash lo meto con el precio y el super ID en el otro hash, etc.
			if (! exists( $hashPrecios{$arrayLineaProducto[1]} ) ) {
				$hashPrecios{$arrayLineaProducto[1]}=$arrayLineaProducto[4];
				$hashLugares{$arrayLineaProducto[1]}=$arrayLineaProducto[2];
				$hashNumItem{$arrayLineaProducto[1]}=$arrayLineaProducto[0];
				$hashDescripcion{$arrayLineaProducto[1]}=$arrayLineaProducto[3];
			}#si esta obviamente comparo y si el precio es mejor reemplazo
			else{
				#COMPARAR PRECIO ; REEMPLAZAR PRECIO Y LUGAR SI CORRESPONDE!!
				if ( $hashPrecios{$arrayLineaProducto[1]} > $arrayLineaProducto[4] ){
					$hashPrecios{$arrayLineaProducto[1]} = $arrayLineaProducto[4];
					$hashLugares{$arrayLineaProducto[1]} = $arrayLineaProducto[2];
					$hashNumItem{$arrayLineaProducto[1]}=$arrayLineaProducto[0];
					$hashDescripcion{$arrayLineaProducto[1]}=$arrayLineaProducto[3];
				}
			}
		}

		#necesito hacer esta basura o no empieza a recorrer por el ppio de nuevo
		close (LISTA);
		open (LISTA, $_[0][$i]);
		
		#todavia estando en la misma lista de presupuestos
		#recorro de nuevo separando por lugares, mostrando el precio cuidado correspondiente y el menor precio que encontre antes
		my $Super_ID="";
		my $cambioLugar = 0;

		while($linea = <LISTA>){
			@arrayLineaProducto = split(";", $linea);
			

			#el lugar viene dado por el super ID
			if ($Super_ID == ""){
				$Super_ID = $arrayLineaProducto[2];
				$cambioLugar = 1;
			}else{
				if ( $Super_ID == $arrayLineaProducto[2] ){
					$cambioLugar = 0;
				}else{
					print SALIDA "\n";	
					$Super_ID = $arrayLineaProducto[2];
					$cambioLugar = 1;
				}
			}

			my $observ="";

			if ( $cambioLugar ){
			#recorro hashLugares por claves, si encuentro un value coincidente uso la clave para hash precios e imprimo ; luego elimino ese producto de ambos hashes
				foreach $clave (keys %hashPrecios){

					if ( $hashLugares{$clave} eq $Super_ID ) {

#"NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA"   

						print SALIDA "$hashNumItem{$clave} \| $clave \| $hashDescripcion{$clave} \| $hashPrecios{$clave} \| $_[2]{$Super_ID} \n";
					#necesarios si no ordeno el archivo por lugares
					delete($hashPrecios{$clave});
					delete($hashPrecios{$clave});
					}
				}
			}

		}

		close(LISTA);		
	}

	close(SALIDA);
}

#/home/juan/Documents/facultad/fiuba-7508-1c2014-cuidadopreciosuelto/informes/pres

# ------------------------------------------
# SUB, Idem atnerior pero muestra por pantalla
# ------------------------------------------
sub MostrarMenuDPantalla
{

	for ( my $i=0; $i<=$_[3]; $i++ ){

	print "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA --> $_[0][$i]\n";
		
		open (LISTA, $_[0][$i]);

		#me creo hashes que tendran los productos como claves
		my %hashPrecios=();
		my %hashLugares=();
		my %hashNumItem=();
		my %hashDescripcion=();

		my @arrayLineaProducto=();


		while($linea = <LISTA>){

			#obtengo los campos del registro de la lista presupuesteada que estoy analizando 
			@arrayLineaProducto = split(";", $linea);

			#Me fijo si es de precios cuidados y lo salteo.
			if ( $arrayLineaProducto[2] < 100 ){
				next;
			}
			#Ahora si no es precio cuidado:
			#si el producto no esta en el hash lo meto con el precio y el super ID en el otro hash, etc.
			if (! exists( $hashPrecios{$arrayLineaProducto[1]} ) ) {
				$hashPrecios{$arrayLineaProducto[1]}=$arrayLineaProducto[4];
				$hashLugares{$arrayLineaProducto[1]}=$arrayLineaProducto[2];
				$hashNumItem{$arrayLineaProducto[1]}=$arrayLineaProducto[0];
				$hashDescripcion{$arrayLineaProducto[1]}=$arrayLineaProducto[3];
			}#si esta obviamente comparo y si el precio es mejor reemplazo
			else{
				#COMPARAR PRECIO ; REEMPLAZAR PRECIO Y LUGAR SI CORRESPONDE!!
				if ( $hashPrecios{$arrayLineaProducto[1]} > $arrayLineaProducto[4] ){
					$hashPrecios{$arrayLineaProducto[1]} = $arrayLineaProducto[4];
					$hashLugares{$arrayLineaProducto[1]} = $arrayLineaProducto[2];
					$hashNumItem{$arrayLineaProducto[1]}=$arrayLineaProducto[0];
					$hashDescripcion{$arrayLineaProducto[1]}=$arrayLineaProducto[3];
				}
			}
		}

		#necesito hacer esta basura o no empieza a recorrer por el ppio de nuevo
		close (LISTA);
		open (LISTA, $_[0][$i]);
		
		#todavia estando en la misma lista de presupuestos
		#recorro de nuevo separando por lugares, mostrando el precio cuidado correspondiente y el menor precio que encontre antes
		my $Super_ID="";
		my $cambioLugar = 0;

		while($linea = <LISTA>){
			@arrayLineaProducto = split(";", $linea);
			

			#el lugar viene dado por el super ID
			if ($Super_ID == ""){
				$Super_ID = $arrayLineaProducto[2];
				$cambioLugar = 1;
			}else{
				if ( $Super_ID == $arrayLineaProducto[2] ){
					$cambioLugar = 0;
				}else{
					print "\n";	
					$Super_ID = $arrayLineaProducto[2];
					$cambioLugar = 1;
				}
			}

			my $observ="";

			if ( $cambioLugar ){
			#recorro hashLugares por claves, si encuentro un value coincidente uso la clave para hash precios e imprimo ; luego elimino ese producto de ambos hashes
				foreach $clave (keys %hashPrecios){

					if ( $hashLugares{$clave} eq $Super_ID ) {

#"NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA"   

						print "$hashNumItem{$clave} \| $clave \| $hashDescripcion{$clave} \| $hashPrecios{$clave} \| $_[2]{$Super_ID} \n";
					#necesarios si no ordeno el archivo por lugares
					delete($hashPrecios{$clave});
					delete($hashPrecios{$clave});
					}
				}
			}

		}

		close(LISTA);		
	}

}
