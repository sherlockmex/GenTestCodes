#!/usr/bin/perl

# ReadErrorBlockPlain
# v 1.2
# Busqueda de errores como bloques en archivos -> filtrado hacia archivo rotado.

use strict;
use warnings;
use Digest::SHA::PurePerl qw(sha256_hex);
use Config::Tiny;
use File::Tail;

=begin comment
 Función que muestra la ayuda y se sale.
=cut
sub muestra_ayuda {
    my $param_falta = shift;
    print "\n<ERROR> Falta definir parametro [$param_falta]\n\n" if defined($param_falta);
    print "Uso: ".__FILE__." <config_file> <seccion>\n";
    print "donde config_file -> Archivo de configuracion\n";
    print "          seccion -> Seccion de Configuracion dentro del archivo\n";
    print "\n";
    print "Las secciones deben estar formadas asi:\n\n";
    print "[seccion]\n";
    print "file_source   = ruta_file_source     # Archivo origen\n";
    print "file_filtered = ruta_file_filtered   # Archivo filtrado\n";
    print "pattern_block = patron_inicio_bloque # Patron de inicio de bloque\n";
    print "file_display  = ruta_file_display    # Archivo de patrones de coincidencia\n";
    print "file_omit     = ruta_file_omit       # Archivo de patrones de omision\n";
    exit -1;
}

=begin comment
Función que valida los argumentos y si no son los adecuados, muestra la ayuda del programa y luego se sale.
=cut
sub valida_args {
  my @args = @_;
  # print join(",", @args), "\n";
  if (@args < 2) {
    muestra_ayuda;
  }
}

=begin comment
 Función que carga parametros.
=cut
sub carga_params {
    my $config_name   = shift;
    my $section_name  = shift; 
    my $file_source   = $_[0];
    my $file_filtered = $_[1];
    my $pattern_block = $_[2];
    my $file_display  = $_[3];
    my $file_omit     = $_[4];
    my $delimiter     = $_[5];

    # cargar del archivo de configuración
    my $Config = Config::Tiny->new;
    # cargar el config.
    $Config = Config::Tiny->read( $config_name );
    # leer propiedades.
    $$file_source   = $Config->{$section_name}->{file_source};
    $$file_filtered = $Config->{$section_name}->{file_filtered};
    $$pattern_block = $Config->{$section_name}->{pattern_block};
    $$file_display  = $Config->{$section_name}->{file_display};
    $$file_omit     = $Config->{$section_name}->{file_omit};
    $$delimiter     = $Config->{$section_name}->{delimiter};
    # validar los argumentos.
    muestra_ayuda("file_source") unless (defined($$file_source));
    muestra_ayuda("file_filtered") unless (defined($$file_filtered));
    muestra_ayuda("pattern_block") unless (defined($$pattern_block));
    muestra_ayuda("file_display") unless (defined($$file_display));
    muestra_ayuda("file_omit") unless (defined($$file_omit));
}

=begin comment
 Función que carga patrones desde un archivo.
=cut
sub carga_patrones {
  my ($file) = @_;
  open FILEHANDLE, "<".$file or die "No se pudo abrir el archivo $file: $!";

  my @array;
  while (<FILEHANDLE>) {
    chomp($_);
    if (length($_)) {
      # print ":", $_ , ":";
      push (@array, $_);
    }
  }
  return @array;
}

=begin comment
 Función que devuelve numero de coincidencias en un arreglo, de los
 valores de otro arreglo.
=cut
sub cuenta_coincidencias {
    my @array = @{$_[0]};
    my @array_patterns = @{$_[1]};

    my $cuenta_coincidencias = 0;

    foreach(@array_patterns) {
        my $pattern = $_;
        # print "Buscando patron :$pattern:\n";
        my @este_patron = grep(/$pattern/, @array);
        my $len_este_patron = @este_patron;
        # print "Resultado de grep: :", join("", @este_patron), ": -> $len_este_patron\n";
        $cuenta_coincidencias += $len_este_patron;
    }
    # print "Numero de coincidencias: $cuenta_coincidencias\n";
    return $cuenta_coincidencias;
}

=begin comment
 Función que calcula la fecha actual.
=cut
sub obten_fecha_actual { 
  my $date = localtime();
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
  my $fecha = sprintf("%04d%02d%02d", $year+1900, $mon+1, $mday);
  return $fecha;
}

=begin comment
 Función que escribe un bloque a un archivo, poniéndole de sufijo la fecha para
simular el rotado.
=cut
sub escribe_bloque_filtrado_rotadofecha {
    my $file_filtered = shift;
    my $delimiter = shift;
    my $first_time = shift;
    my @array = @_;
    my $sufijo_fecha = obten_fecha_actual;

    # Abrir archivo.
    if ($first_time) {
        open OUTPUT_FILTERED, ">$file_filtered.$sufijo_fecha" or die "No se pudo abrir el archivo $file_filtered.$sufijo_fecha: $!";
    } else {
        open OUTPUT_FILTERED, ">>$file_filtered.$sufijo_fecha" or die "No se pudo abrir el archivo $file_filtered.$sufijo_fecha: $!";
    }
    # Escribir el arreglo.
    print OUTPUT_FILTERED join("", @array);
    # e imprimir el delimitador, si está definido.
    print OUTPUT_FILTERED $delimiter, "\n" if defined $delimiter;
    # cerrar el archivo.
    close OUTPUT_FILTERED or die "No se pudo cerrar el archivo $file_filtered.$sufijo_fecha: $!";;    
}

=begin comment
Funcion principal.
 @param ARGV La lista de parametros de la linea de comandos.
=cut
# args: ($ARGV)
# valida los argumentos
valida_args @ARGV;

my $config_file = $ARGV[0];
my $section_config = $ARGV[1];

# Cargar parametros.
my $file_source; 
my $file_filtered; 
my $pattern_block; 
my $file_display; 
my $file_omit; 
my $delimiter;

my $first_filtered = 1;

print "***** Cargando parametros ******\n";
carga_params $config_file, $section_config, \$file_source, \$file_filtered,
    \$pattern_block, \$file_display, \$file_omit, \$delimiter;

# ejecutar el procedimiento.
print STDOUT "Ejecutando lectura sobre[$file_source]\n".
"Salida filtrada hacia [$file_filtered]\n".
"con patron de bloque [$pattern_block]\n".
"archivo de patron de despliegue [$file_display]\n".
"archivo de patron de omision [$file_omit]\n".
"y delimitador [".(defined $delimiter ? $delimiter : "")."]\n";

print "Cargando patrones a filtrar\n";
my @array_display = carga_patrones($file_display);
print "Patrones a filtrar (".scalar(@array_display)."):\n:", join(":\n:", @array_display), ":\n";

print "Cargando patrones a omitir\n";
my @array_omit = carga_patrones($file_omit);
print "Patrones a omitir (".scalar(@array_omit)."):\n:", join(":\n:", @array_omit), ":\n";

print STDOUT 
  "**********************************************************************\n";

my $file;
$file=File::Tail->new(name=>$file_source, maxinterval=>30, adjustafter=>7, interval=>1, tail=>-1);
# open FILEHANDLE, "<".$file_source or die "No se pudo abrir el archivo $file_source: $!";
# open SALIDA, ">".$file_filtered or die "No se pudo abrir el archivo $file_filtered: $!";
# mientras haya datos en el archivo...
# un arreglo para guardar las lineas del error.
my @array;
my @array_num_lineas;
my $num_linea = 0;
my @id;
# while(<FILEHANDLE>) {
my $line;
while(defined($line=$file->read)) {
  # si la linea no cumple el patron de error, agregarla al arreglo
  # my $line=$_;  
  unless ($line=~/$pattern_block/) {
    # es parte del error
    push(@array, $line);    
    push(@array_num_lineas, $num_linea);
  } else {
    # es un nuevo error.
    # imprimir el error. Solo si tiene el patron de despliegue
    # if (grep(/$pattern_display/, @array) > 0) {
    if (cuenta_coincidencias(\@array, \@array_display) > 0) {
      # unless (grep(/$pattern_omit/, @array) > 0) {
      unless (cuenta_coincidencias(\@array, \@array_omit) > 0) {
        # obtener el ID usando el hash.
        my $digest;
        my $sha = Digest::SHA::PurePerl->new(256);
        for (@array) {
            $sha->add($_);
        }
        $digest = $sha->hexdigest;
        print STDOUT "{", $digest, "} -> ";
        print STDOUT join(":", @array_num_lineas), "\n";
        # a la salida va el bloque
	# print SALIDA join("", @array);
        escribe_bloque_filtrado_rotadofecha $file_filtered, $delimiter, $first_filtered, @array;
        if ($first_filtered) {
            $first_filtered = undef;
        }
	# e imprimir el delimitador, si está definido.
	# print SALIDA $delimiter, "\n" if defined $delimiter;
      }
    }
    # limpiar el arreglo.
    undef(@array);
    # tambien el de las lineas.
    undef(@array_num_lineas);
    # colocar ahora la linea que es parte del error.
    push(@array, $line);
    # tambien el numero de linea
    push (@array_num_lineas, $num_linea);
  }
  $num_linea += 1;
}
# al final, si tenemos algo en el arreglo, que siempre lo tendremos, que 
# cumpla tambien con el patron, imprimirlo
print STDOUT "Validando ultimo bloque\n";
if (@array > 0) {
    print STDOUT "El bloque tiene datos\n";
    # if (grep(/$pattern_display/, @array) > 0) {
    if (cuenta_coincidencias(\@array, \@array_display) > 0) {
        print STDOUT "El bloque cumple con alguno de los patrones :".join(":", @array_display).":\n";
        # unless (grep(/$pattern_omit/, @array) > 0) {
        unless (cuenta_coincidencias(\@array, \@array_omit) > 0) {
            print STDOUT "El bloque no tiene el patron de omision :".join(":", @array_omit).":\n";
            #print SALIDA join("", @array);
            # imprimir el delimitador.
            #print SALIDA $delimiter, "\n" if defined $delimiter;
            escribe_bloque_filtrado_rotadofecha $file_filtered, $delimiter, $first_filtered, @array;
        } else {
            print STDOUT "El bloque SI tiene algunos de los patrones de omision :".join(":", @array_omit).":\n";
        }
    }
}
# cerrar el archivo.
close $file or die "No se pudo cerrar el archivo $file_source: $!";
# close FILEHANDLE or die "No se pudo cerrar el archivo $file_source: $!";
# cerrar el otro.
# close SALIDA or die "No se pudo cerrar el archivo $file_filtered: $!";

print STDOUT "*********************************************************************************************\n";
print STDOUT "Saliendo...\n";
