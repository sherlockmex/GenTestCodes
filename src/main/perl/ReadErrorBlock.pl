#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

=begin comment
Una funcion que va guardando lineas en el arreglo
 hasta que pasamos al siguiente error. Una vez detectado
 el cambio de error, imprimir el arreglo y limpiarlo, 
 para guardar el siguiente error.
 Para la deteccion del cambio de error, se pasa un 
 patron para el inicio del error.
 @param line La linea a revisar.
 @param array El arreglo con las lineas previas.
 @param pattern El patron contra el que comparar la linea
 @param divisor El divisor a imprimir para separar bloques.
=cut
# args: ($line, @array, $pattern, $divisor)
sub print_error_block {
  # si la l�nea no cumple el patr�n de error, agregarla al arreglo
  my ($line, @array, $pattern, $divisor) = @_;
  # print "***** pattern->$pattern, divisor->$divisor\n" if defined $pattern and defined $divisor;
  unless ($line=~/^\#\#\#\#/) {
    # es parte del error
    push(@array, $line);    
  } else {
    # es un nuevo error.
    # imprimir el error.
    print join("\n", @array), "\n";
    # imprimir el divisor.
    print $divisor, "\n" if defined $divisor;
    # limpiar el arreglo.
    undef(@array);
    # colocar ahora la linea que es parte del error.
    push(@array, $line);
  }
}

=begin comment
Una funcion que lee un archivo, y va imprimiendo bloques de errores, 
 en vez de lineas.
 @param file_name El nombre del archivo a leer.
 @param pattern El patron a buscar para identificar comienzo de errores.
 @param divisor La cadena que se usara como divisor.
 
=cut
# args: ($file_name, $pattern, $divisor)
sub read_file_by_error {
  my ($file_name, $pattern, $divisor) = @_;
  open FILEHANDLE, $file_name or die "No se pudo abrir el archivo $file_name";
  # mientras haya datos en el archivo...
  # un arreglo para guardar las lineas del error.
  my @error_block=();
  my $num_linea = 0;
  while(<FILEHANDLE>) {
    print $num_linea, ":";
    print_error_block $_, \@error_block, $pattern, $divisor;
    $num_linea += 1;
  }
  # al final, si tenemos algo en el arreglo, que siempre lo tendremos, imprimirlo
  if (@error_block > 0) {
    print join("\n", @error_block);
  }
  # cerrar el archivo.
  close FILEHANDLE or die "No se pudo cerrar el archivo $file_name: $!";
}

=begin comment
Funci�n que muestra la ayuda del programa y luego se sale.
=cut
sub ayuda() {
  print "Uso: ".__FILE__." <archivo> <patron> <delimitador>\n";
  exit -1;
}

=begin comment
Funci�n principal.
 @param ARGV La lista de par�metros de la l�nea de comandos.
=cut
# args: ($ARGV)

if (@ARGV != 3) {
  # sin el n�mero apropiado de argumentos.
  ayuda();
}

# ejecutar el procedimiento.
my $file_name = $ARGV[0];
my $pattern = $ARGV[1];
my $divisor = $ARGV[2];
print "Ejecutando lectura sobre\n[$file_name]\ncon patron de error [$pattern]\ny divisor [$divisor]\n";
print "*********************************************************************************************\n";
read_file_by_error $file_name, $pattern, $divisor;
print "*********************************************************************************************\n";
print "Saliendo...\n";