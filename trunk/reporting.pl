#! /usr/bin/perl

# ------------
# INICIO MAIN.
# ------------
system("clear");

$opcion = "";

while ($opcion ne "-exit")
{
	print "\n\n";
	print "----------------------------------------------------------------------------------\n";
	print "1ra entrada --> Opcion de proceso ('-a' para mas informacion | '-exit' para salir)\n";
	print "2da entrada --> Path del archivo de Lista Presupuestada\n";
	print "3ra entrada --> Opcion de grabado ('-w') [y/n]\n";
	print "----------------------------------------------------------------------------------\n";

	print "1ra entrada: ";
	$opcion = <STDIN>;
	chomp($opcion);

	if ($opcion ne "-exit" and  $opcion ne "-a" and $opcion ne "-w" and $opcion ne "-r" and $opcion ne "-m" and $opcion ne "-d" and $opcion ne "-f" and $opcion ne "-x" and $opcion ne "-u" and $opcion ne "-mr" and $opcion ne "-dr")
	{
		print "No existe comando '$opcion'. Por favor ingrese '-a' para Ayuda.\n";
		$opcion = "-exit";
	}

	if ($opcion eq "-a")
	{
		&MostrarMenuA_Ayuda;
	}
	
	if ($opcion eq "-r" or $opcion eq "-m" or $opcion eq "-d" or $opcion eq "-f" or $opcion eq "-x" or $opcion eq "-u" or $opcion eq "-mr" or $opcion eq "-dr")
	{
		print "2da entrada: ";
		$pathListaPresupuestada = <STDIN>;
		chomp($pathListaPresupuestada);

		print "3ra entrada [y/n]: ";
		$opcionDeGrabado = <STDIN>;
		chomp($opcionDeGrabado);
	
		open(LISTA_PRESUPUESTADA,$pathListaPresupuestada) || die "ERROR: el archivo de Lista Presupuestada no existe";
		open(SUPER, "SUPER.MAE") || die "ERROR: el archivo de SUPER.MAE no existe";
	
		# --------------------------------
		# Cargamos la Lista Presupuestada.
		# --------------------------------
		$cantDeLineas = 0;
		%hashListaPresupuestada = ($cantDeLineas, "Informacion");
		
		while ($lineaEntrada = <LISTA_PRESUPUESTADA>)
		{
			$cantDeLineas++;
			$hashListaPresupuestada{$cantDeLineas} = $lineaEntrada;
		}
		
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
			&MostrarMenuR_Referencia(\%hashListaPresupuestada, \%hashSuper, $cantDeLineas, $opcionDeGrabado);
		}
	
		if ($opcion eq "-m")
		{
			&MostrarMenuM_MenorPrecio(\%hashListaPresupuestada, \%hashSuper, $cantDeLineas, $opcionDeGrabado);
		} 

		if ($opcion eq "-d")
		{
			print "proximamente\n";
		}
	
		if ($opcion eq "-f")
		{
			&MostrarMenuF_Faltante(\%hashListaPresupuestada, \%hashSuper, $cantDeLineas, $opcionDeGrabado);
		}

		if ($opcion eq "-x")
		{
			print "proximamente\n";
		}

		if ($opcion eq "-u")
		{
			print "proximamente\n";
		}

		if ($opcion eq "-mr")
		{
			print "proximamente\n";
		}
		
		if ($opcion eq "-dr")
		{
			print "proximamente\n";
		}
		
		close (LISTA_PRESUPUESTADA);
		close (SUPER);
	}
}

system ("clear");
# ---------
# FIN MAIN.
# ---------

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
	print "		'-x' --> Filtrar por Provincia/Supermercado.\n";
	print "		'-u' --> Filtrar por Usuario.\n";
	print "		'-exit' --> Salir.\n";
	print "2da entrada:\n";
	print "		Path del archivo 'Lista Presupuestada' a procesar.\n";
	print "3ra entrada:\n";
	print "		'-w' [y/n] --> Opcion de Grabado\n";
	print "			       [y] no muestra por pantalla y graba en archivo de salida.\n";
	print "			       [n] muestra por pantalla.\n";
	print "----------------------------------------------------------------------------------------\n";
}

# -----------------------------------------------------------------
# SUB, Muestra la info de precios de Referencia (Precios Cuidados).
# -----------------------------------------------------------------
sub MostrarMenuR_Referencia
{
	system("clear");

	if ($_[3] eq "y")
	{
		# open(SALIDA, ">$salida.txt") || die "ERROR: El archivo 'salida.txt' no existe";
		open(SALIDA, ">salida.txt");
		print SALIDA "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA\n";
	}
	else
	{
		print "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA\n";
	}

	for (my $i=1;$i<=$_[2];$i++)
	{
		my $linea = $_[0]{$i};
		chomp($linea);

		if ($linea =~ /[^;]*;[^;]*;1;.*/)
		{
			my @arrayData = split(";", $linea);

			if ($_[3] eq "y")
			{
				$infoSalida = $infoSalida."$arrayData[0] \| $arrayData[1] \| $arrayData[3] \| $arrayData[4] \| $_[1]{$arrayData[2]}\n";
			}
			else
			{
				print "$arrayData[0] \| $arrayData[1] \| $arrayData[3] \| $arrayData[4] \| $_[1]{$arrayData[2]}\n";
			}
		}
	}

	if ($_[3] eq "y")
	{
		print SALIDA $infoSalida;
		close(SALIDA);
	}
}

# ------------------------------------------------------------------
# SUB, Muestra la info de Menor Precio (omite los Precios Cuidados).
# ------------------------------------------------------------------
sub MostrarMenuM_MenorPrecio
{
	system("clear");

	my $idMenor = 0;
	my $productoMenor = "";
	my $superIdMenor = 0;
	my $descripcionMenor = "";
	my $precioMenor = 9999;

	if ($_[3] eq "y")
	{
		open(SALIDA,">salida.txt");
		print SALIDA "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA\n";
	}
	else
	{
		print "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA\n";
	}

	for (my $i=1; $i<=$_[2];$i++)
	{
		my $linea = $_[0]{$i};
		chomp($linea);

		@arrayData = split(";", $linea);

		if ($linea =~ /[^;]*;[^;]*;1;.*/)
		{
			if ($i != 1)
			{
				if ($_[3] eq "y")
				{
					$infoSalida = $infoSalida."$idMenor \| $productoMenor \| $descripcionMenor \| $precioMenor \| $_[1]{$superIdMenor}\n";
				}
				else
				{	
					print "$idMenor \| $productoMenor \| $descripcionMenor \| $precioMenor \| $_[1]{$superIdMenor}\n";
				}
				
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

			if ($i == $_[2])
			{
				if ($_[3] eq "y")
				{
					$infoSalida = $infoSalida."$idMenor \| $productoMenor \| $descripcionMenor \| $precioMenor \| $_[1]{$superIdMenor}\n";
				}
				else
				{
					print "$idMenor \| $productoMenor \| $descripcionMenor \| $precioMenor \| $_[1]{$superIdMenor}\n";
				}
			}
		}
	}

	if ($_[3] eq "y")
	{
		print SALIDA $infoSalida;
		close(SALIDA);
	}
}

# ------------------------------------------
# SUB, Muestra la info de precios faltantes.
# ------------------------------------------
sub MostrarMenuF_Faltante
{
	system("clear");

	if ($_[3] eq "y")
	{	
		open(SALIDA,">salida.txt");
		print SALIDA "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA\n";
	}
	else
	{
		print "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA\n";
	}

	for (my $i=1;$i<=$_[2];$i++)
	{
		my $linea = $_[0]{$i};
		chomp($linea);
		my $chr = chop($linea);
		
		if ($chr eq ';')
		{
			$linea = $linea.";";
			my @arrayData = split(";",$linea);
		
			if (length($arrayData[2]) > 0)
			{	
				if ($_[3] eq "y")
				{
					$infoSalida = $infoSalida."$arrayData[0] \| $arrayData[1] \| $arrayData[3] \| $arrayData[4] \| $_[1]{$arrayData[2]}\n";
				}
				else
				{
					print "$arrayData[0] \| $arrayData[1] \| $arrayData[3] \| $arrayData[4] \| $_[1]{$arrayData[2]}\n";
				}
			}
			else
			{
				if ($_[3] eq "y")
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

	if ($_[3] eq "y")
	{
		print SALIDA $infoSalida;
		close(SALIDA);
	}
}
