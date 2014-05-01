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
	print "2da entrada --> Path de la carpata con Listas Presupuestadas\n";
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
		# $opcion = "-exit";
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
			print "proximamente\n";
		}
	
		if ($opcion eq "-f")
		{
			&MostrarMenuF_Faltante(\@arrayLP, $#arrayLP, \%hashSuper, $filtroSuper, $opcionDeGrabado);
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

	# print "en array $array[0]\n";
	# print "en array $array[1]\n";

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
		open(SALIDA, ">salida.txt");
		print SALIDA "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA\n";
	}
	else
	{
		print "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA\n";
	}

	for ($i=0; $i<=$_[1]; $i++)
	{
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
		open(SALIDA,">salida.txt");
		print SALIDA "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA\n";
	}
	else
	{
		print "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA\n";
	}

	for (my $i=0; $i<=$_[1];$i++)
	{
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
		open(SALIDA,">salida.txt");
		print SALIDA "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA\n";
	}
	else
	{
		print "NRO de ITEM \| PRODUCTO PEDIDO \| PRODUCTO ENCONTRADO \| PRECIO \| NOMBRE_SUPER-PROVINCIA\n";
	}

	for (my $i=0;$i<=$_[1];$i++)
	{
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
