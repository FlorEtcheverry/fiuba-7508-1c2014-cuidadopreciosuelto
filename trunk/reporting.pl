#! /usr/bin/perl

open(LISTA_PRESUPUESTADA,"<pepe.xxx") || die "ERROR: el archivo de Lista Presupuestada no existe";
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


# print "$hashListaPresupuestada{0}\n";
# print "$hashListaPresupuestada{1}\n";
# &MostrarMenuA_Ayuda;
# &MostrarMenuF_Faltante(\%hashListaPresupuestada, \$hashSuper, $cantDeLineas);
# &MostrarMenuR_Referencia(\%hashListaPresupuestada, \%hashSuper, $cantDeLineas);
&MostrarMenuM_MenorPrecio(\%hashListaPresupuestada, \%hashSuper, $cantDeLineas);

close (LISTA_PRESUPUESTADA);
close (SUPER);

sub MostrarMenuA_Ayuda
{
	print "-a --> Ayuda\n";
	print "-w --> Grabar\n";
	print "-r --> Precio de referencia\n";
	print "-m --> Menor precio\n";
	print "-d --> Donde Comprar\n";
	print "-f --> Faltante\n";
	print "-x --> Filtrar por Provincia/Supermercado\n";
	print "-u --> Filtrar por Usuario\n";
	print "Otros --> Proximamente\n";
}

sub MostrarMenuR_Referencia
{
	for (my $i=1;$i<=$_[2];$i++)
	{
		my $linea = $_[0]{$i};
		chomp($linea);

		if ($linea =~ /[^;]*;[^;]*;1;.*/)
		{
			my @arrayData = split(";", $linea);
			print "$arrayData[0] \| $arrayData[1] \| $arrayData[3] \| $arrayData[4] \| $_[1]{$arrayData[2]}\n";
		}
	}
}

sub MostrarMenuM_MenorPrecio
{
	my $idMenor = 0;
	my $productoMenor = "";
	my $superIdMenor = 0;
	my $descripcionMenor = "";
	my $precioMenor = 9999;

	for (my $i=1; $i<=$_[2];$i++)
	{
		my $linea = $_[0]{$i};
		chomp($linea);

		@arrayData = split(";", $linea);

		if ($linea =~ /[^;]*;[^;]*;1;.*/)
		{
			if ($i != 1)
			{
				print "$idMenor \| $productoMenor \| $descripcionMenor \| $precioMenor \| $_[1]{$superIdMenor}\n";
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
				print "$idMenor \| $productoMenor \| $descripcionMenor \| $precioMenor \| $_[1]{$superIdMenor}\n";
			}
		}
	}
}

sub MostrarMenuF_Faltante
{
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
				print "$arrayData[0] \| $arrayData[1] \| $arrayData[3] \| $arrayData[4] \| $_[1]{$arrayData[2]}\n";
			}
			else
			{
				print "$arrayData[0] \| $arrayData[1] \| $arrayData[2] \| $arrayData[3] \| $arrayData[4]\n";
			}
		}
	}
}
