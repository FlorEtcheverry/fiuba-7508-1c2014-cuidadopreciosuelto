#! /usr/bin/perl

# $string1 = <STDIN>;
# $string2 = <STDIN>;
# chomp($string1);
# chomp($string2);
# print "usted escribio $string1 y ademas $string2\n";
# ----------------------------------------------------

open(LISTA_PRESUPUESTADA,"<pepe.xxx") || die "ERROR: el archivo de Lista Presupuestada no existe";
open(SUPER, "SUPER.MAE") || die "ERROR: el archivo de SUPER.MAE no existe";

$cantDeLineas = 0;
%hashListaPresupuestada = ($cantDeLineas,"Informacion");

while ($lineaEntrada = <LISTA_PRESUPUESTADA>)
{
	# print $lineaEntrada
	$cantDeLineas++;
	$hashListaPresupuestada{$cantDeLineas} = $lineaEntrada;
}

# print "$hashListaPresupuestada{0}\n";
# print "$hashListaPresupuestada{1}\n";
# &MostrarMenuA_Ayuda;
# &MostrarMenuF_Faltante(\%hashListaPresupuestada, $cantDeLineas);
# &MostrarMenuR_Referencia(\%hashListaPresupuestada, $cantDeLineas);

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
	for($i=1;$i<=$_[1];$i++)
	{
		$linea = $_[0]{$i};
		chomp($linea);

		if ($linea =~ /[^;]*;[^;]*;1;.*/)
		{
			print "$linea\n";
		} 
	}
}

sub MostrarMenuF_Faltante
{
	for($i=1;$i<=$_[1];$i++)
	{
		$linea = $_[0]{$i};
		chomp($linea);
		$chr = chop($linea);
		
		if($chr eq ';')
		{
			print "$linea\n";
		}
	}
}
