#!/usr/bin/perl

# ReadErrorBlockPlainRotated
# v 1.2
# Búsqueda de errores como bloques en archivos, aun si son rotados.

use strict;
use warnings;
use diagnostics;
use Digest::SHA qw(sha256_hex);
use File::Tail;

=begin comment
Función que valida los argumentos y si no son los adecuados, muestra la ayuda del programa y luego se sale.
=cut
sub valida_args {
  my @args = @_;
  print join(",", @args), "\n";
  if (@args < 3) {
    print "Uso: ".__FILE__." <archivo> <patron_bloque> <patron_despliegue> [<patron_id>] [<num_grupo>] [<delimitador>]\n";
    exit -1;
  }
}

=begin comment
Función principal.
 @param ARGV La lista de parámetros de la línea de comandos.
=cut
# args: ($ARGV)
# valida los argumentos
valida_args @ARGV;

# ejecutar el procedimiento.
my $file_name = $ARGV[0];
my $pattern_block = $ARGV[1];
my $pattern_display = $ARGV[2];
my $pattern_id = defined $ARGV[3] ? $ARGV[3] :undef;
our $num_grupo = defined $ARGV[4] ? scalar($ARGV[4]) : undef;
my $divisor = defined $ARGV[5] ? $ARGV[5] : undef;
print STDOUT "Ejecutando lectura sobre\n[$file_name]\n".
"con patron de bloque [$pattern_block]\n".
"patron de despliegue [".(defined $pattern_display ? $pattern_display : "")."]\n".
"patron de id [".(defined $pattern_id ? $pattern_id : "")."]\n".
"numero de grupo [".(defined $num_grupo ? $num_grupo : "")."]\n".
"y divisor [".(defined $divisor ? $divisor : "")."]\n";
print STDOUT 
  "**********************************************************************\n";

my $file;
$file=File::Tail->new(name=>$file_name, maxinterval=>30, adjustafter=>7, interval=>1, tail=>-1);
open SALIDA, ">".$file_name."filtrado" or die "No se pudo abrir el archivo ".$file_name."filtrado";
# mientras haya datos en el archivo...
# un arreglo para guardar las líneas del error.
my @array;
my @array_num_lineas;
my $num_linea = 0;
my @id;
my $line;
while(defined($line=$file->read)) {
  # si la línea no cumple el patrón de error, agregarla al arreglo
  # my $line=$_;  
  unless ($line=~/$pattern_block/) {
    # es parte del error
    push(@array, $line);    
    push(@array_num_lineas, $num_linea);
  } else {
    # es un nuevo error.
    # imprimir el error. Solo si tiene el patron de despliegue
    if (grep(/$pattern_display/, @array) > 0) {
      # obtener el ID
      if (defined $pattern_id and defined $num_grupo) {
		@id = ( $array[0] =~ /$pattern_id/g );
      	print STDOUT "{", $id[$num_grupo] , "} -> [", join(":", @id), "] -> ";
      	print STDOUT join(":", @array_num_lineas), "\n";
      } else {
	      # en caso contrario usar el hash.
		  my $digest;
		  my $sha = Digest::SHA->new(256);
		  for (@array) {
		    $sha->add($_);
		  }
		  $digest = $sha->hexdigest;
		  print STDOUT "{", $digest, "} -> ";
		  print STDOUT join(":", @array_num_lineas), "\n";
      }
	  print SALIDA join("", @array);
	  # imprimir el divisor.
	  print SALIDA $divisor, "\n" if defined $divisor;
	}
	# limpiar el arreglo.
	undef(@array);
	# también el de las líneas.
	undef(@array_num_lineas);
	# colocar ahora la linea que es parte del error.
	push(@array, $line);
	# también el número de linea
    push (@array_num_lineas, $num_linea);
  }
  $num_linea += 1;
}
# al final, si tenemos algo en el arreglo, que siempre lo tendremos, que 
# cumpla también con el patrón, imprimirlo
if (@array > 0) {
  if (grep(/$pattern_display/, @array) > 0) {
    print SALIDA join("\n", @array);
  }
}
# cerrar el archivo.
close FILEHANDLE or die "No se pudo cerrar el archivo $file_name: $!";
# cerrar el otro.
close SALIDA or die "No se pudo cerrar el archivo ".$file_name."filtrado: $!";

print STDOUT "*********************************************************************************************\n";
print STDOUT "Saliendo...\n";