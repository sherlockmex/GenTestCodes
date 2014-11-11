#!/usr/bin/perl
#
# @File ProcessError.pl
# @Author Angel
# @Created 8/11/2014 10:06:19 PM
#

use strict;
use warnings;
use Digest::SHA qw(sha256_hex);
use Config::Tiny;

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
    print "file_filtered = ruta_file_filtered   # Archivo base filtrado\n";
    print " file_pattern = ruta_file_pattern    # Archivo de patrones de coincidencia\n";
    print " file_headers = ruta_file_headers    # Archivo de encabezados por cada patron de coincidencia\n";
    print "  file_alerts = ruta_file_alerts     # Archivo base de alertas ya enviadas\n";
    print "pattern_block = patron_inicio_bloque # Patron de inicio de bloque\n";
    print " pattern_date = patron_fecha         # Patron de busqueda de fecha\n";
    print " pattern_sust = patron_sustitucion   # Patron de sustitucion para fecha\n";    
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
    my $file_filtered = $_[0];
    my $file_pattern  = $_[1];
    my $file_headers  = $_[2];
    my $file_alerts   = $_[3];
    my $pattern_block = $_[4];
    my $pattern_date  = $_[5];
    my $pattern_sust  = $_[6];

    # cargar del archivo de configuración
    my $Config = Config::Tiny->new;
    # cargar el config.
    $Config = Config::Tiny->read( $config_name );
    # leer propiedades.
    $$file_filtered = $Config->{$section_name}->{file_filtered};
    $$file_pattern  = $Config->{$section_name}->{file_pattern};
    $$file_headers  = $Config->{$section_name}->{file_headers};
    $$file_alerts   = $Config->{$section_name}->{file_alerts};
    $$pattern_block = $Config->{$section_name}->{pattern_block};
    $$pattern_date  = $Config->{$section_name}->{pattern_date};
    $$pattern_sust  = $Config->{$section_name}->{pattern_sust};
    # validar los argumentos.
    muestra_ayuda("file_filtered") unless (defined($$file_filtered));
    muestra_ayuda("file_pattern") unless (defined($$file_pattern));
    muestra_ayuda("file_headers") unless (defined($$file_headers));
    muestra_ayuda("file_alerts") unless (defined($$file_alerts));
    muestra_ayuda("pattern_block") unless (defined($$pattern_block));
    muestra_ayuda("pattern_date") unless (defined($$pattern_date));
    muestra_ayuda("pattern_sust") unless (defined($$pattern_sust));
}

=begin comment
 Función que carga las variables globales.
=cut
sub carga_global_params {
    my $config_name   = shift;
    my $process_date  = $_[0];
    my $actual_date   = $_[1];
     # cargar del archivo de configuración
    my $Config = Config::Tiny->new;
    # cargar el config.
    $Config = Config::Tiny->read( $config_name );
    # leer propiedades.
    $$process_date = $Config->{GLOBAL}->{process_date};
    $$actual_date = $Config->{GLOBAL}->{actual_date};
    print "Fecha de proceso global: :".(defined($$process_date) ? $$process_date : "").":\n";
    print "Fecha actual: :".(defined($$actual_date) ? $$actual_date : "").":\n";
}

=begin comment
 Función que carga los errores desde un archivo.
=cut
sub carga_patterns {
  my ($file) = @_;
  open FILEHANDLE, "<".$file or die "No se pudo abrir el archivo $file: $!";

  my @array_patterns;
  while (<FILEHANDLE>) {
    chomp($_);
    if (length($_)) {
      # print ":", $_ , ":";
      push (@array_patterns, $_);
    }
  }
  return @array_patterns;
}

=begin comment
 Función que busca los patrones de un arreglo en otro arreglo.
=cut
sub encuentra_patrones {
  my @array = @{$_[0]};
  my @array_patterns = @{$_[1]};
  my $primer_patron = $_[2];
  my $indice_patron = $_[3];

  my $cuenta_errores = 0;
  my $cuenta_este_error = 0;
  #print "Arreglo a buscar:\n", join("", @array), "\n";
  #print "Arreglo de errores:\n", join("\n", @array_patterns), "\n";
  # recorrer el arreglo de errores para buscarlos en el arreglo de entrada.
  my $indice_errores = 0;
  foreach(@array_patterns) {
    my $error = $_;
    #print "Buscando error :$error:\n";
    my @este_error = grep(/$error/, @array);
    my $len_este_error = @este_error;
    #print "Resultado de grep: :", join("", @este_error), ": -> $len_este_error\n";
    if ($len_este_error > 0) {
        #print "Este error es: :", join(":", @este_error), ":\n";
        if (length($$primer_patron) == 0) {
            #print "Fijando primero error a $este_error[0]\n";
            $$primer_patron = $error;
            $$indice_patron = $indice_errores;
        } else {
            #print "El primer error ya tiene valor :$$primer_patron:\n";
        }
    } else {
        #print "No se encontro :$error:\n";
    }
    $cuenta_errores += @este_error;
    $indice_errores += 1;
  }
  #print "Errores encontrados en el bloque: $cuenta_errores\n";
  return $cuenta_errores > 0;
}

=begin comment
 Función que calcula el id del bloque.
=cut
sub calcula_id {
  my (@array) = @_;
  
  my $digest;
  my $sha = Digest::SHA->new(256);
  for (@array) {
    $sha->add($_);
  }
  $digest = $sha->hexdigest;
  return $digest;
}

=begin comment
 Función que calcula la fecha del bloque.
=cut
sub obten_fecha { 
  my $pattern_date = shift;
  my $pattern_sust = shift;
  my @array = @_;
  my $date = localtime();
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
  my $fecha = sprintf("%04d%02d%02d", $year+1900, $mon+1, $mday);
  if ( $array[0] =~ /$pattern_date/ ) {
    $fecha = eval($pattern_sust);
  }
  return $fecha;
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
 Función que procesa las alertas.
=cut
sub procesa_alerta {
    my $id = shift;
    my $error = shift;
    my $header = shift;
    my $file_alertas = shift;
    my @array = @_;
    my $alerta_encontrada=undef;
    # primero abrimos el archivo de alertas.
    open ALERTHANDLE, "<".$file_alertas or print "El archivo de alertas $file_alertas no pudo abrirse: $!\n";
    while (<ALERTHANDLE>) {
        chomp($_);
        # print "Linea leida :$_:\n";
        if ($_ eq $id) {
            print "Alerta ya lanzada!";
            $alerta_encontrada=1;
            last;
        }
    }
    # cerrar el archivo
    close ALERTHANDLE;
    # si no lo encontro, procesa alerta.
    unless ($alerta_encontrada) {
        print "Procesando alerta";
        # El codigo del procesamiento.

        print "Alerta ID: $id\nError: $error\nEncabezado: $header\n".
            "Archivo alertas: $file_alertas\nBloque\n".
            "----- BEGIN BLOQUE -----\n", join("", @array), 
            "\n----- END BLOQUE -----\n";

        # si puede procesarse la alerta, agregar el ID al final del archivo
        open ALERTHANDLE, ">>".$file_alertas or 
            print "El archivo de alertas $file_alertas no puede abrirse: $!\n";
        print ALERTHANDLE $id,"\n";
        close ALERTHANDLE;
        # print "Alerta procesada, Id $id guardado\n";
    }
}

# Valida los argumentos
valida_args @ARGV;

my $config_file;
my $section_config;

$config_file = $ARGV[0];
$section_config = $ARGV[1];

# Parámetros globales.
my $process_date;
my $actual_date;

# Cargar parámetros
my $file_filtered;
my $file_pattern;
my $file_alerts;
my $file_headers;
my $pattern_block;
my $pattern_date;
my $pattern_sust;

print "***** Cargando parametros globales ******\n";
carga_global_params $config_file, \$process_date, \$actual_date;

$process_date = obten_fecha_actual unless defined($process_date);
$actual_date = obten_fecha_actual unless defined($actual_date);

print "Fecha de operacion = :$process_date:\n";
print "Fecha actual = :$actual_date:\n";

print "***** Cargando parametros ******\n";
carga_params $config_file, $section_config, \$file_filtered, 
    \$file_pattern, \$file_headers, \$file_alerts, 
    \$pattern_block, \$pattern_date, \$pattern_sust;

my @array_patterns;
my @array_headers;

# el archivo viene seguido de la fecha....
my $fecha_proceso = $process_date;

# el nombre del archivo filtrado cambia...
$file_filtered .= ".".$actual_date;

# así como el nombre del archivo de alertas.
$file_alerts .= ".".$actual_date;

print STDOUT "Ejecutando lectura sobre\n[$file_filtered]\n".
"archivo de coincidencias [$file_pattern]\n".
"archivo de encabezados por coincidencia [$file_headers]\n".
"archivo de alertas [$file_alerts]\n".
"con patron de bloque [$pattern_block]\n".
"patron de fecha [$pattern_date]\n".
"patron de sustitucion [$pattern_sust]\n";

print "Cargando patrones de coincidencia del archivo $file_pattern\n";
@array_patterns = carga_patterns($file_pattern);
print "Patrones cargados :", scalar(@array_patterns), "\n";

print "Cargando encabezados por cada patron de coincidencia del archivo $file_headers\n";
@array_headers = carga_patterns($file_headers);
print "Encabezados cargados :", scalar(@array_headers), "\n";

print "Los patrones leidos son: \n----- BEING PATTERNS -----\n:", 
    join(":\n:", @array_patterns), ":\n----- END PATTERNS -----\n";

print "Los encabezados leidos son: \n----- BEING HEADERS -----\n:", 
    join(":\n:", @array_headers), ":\n----- END HEADERS -----\n";

print "Abriendo archivo a buscar: $file_filtered\n";
open FILEHANDLE, "<".$file_filtered or die "No se pudo abrir el archivo ".$file_filtered;

my @array;
my $num_bloques=0;

my $primer_patron = "";
my $indice_patron = -1;
my $id;
my $fecha_bloque;

while(<FILEHANDLE>) {
  # si la línea no cumple el patrón de bloque, agregarla al arreglo
  my $line=$_;  
  unless ($line=~/$pattern_block/) {
    # es parte del error
    push(@array, $line);    
  } else {
    # es un patrón reportable.
    # Solo si tiene alguno de los patrones del archivo.
    $primer_patron = "";
    $indice_patron = -1;
    if (encuentra_patrones(\@array, \@array_patterns, \$primer_patron, \$indice_patron)) {
        # Calcular el id del bloque.
        $id = calcula_id(@array);
        print "El id del bloque es: $id\n";
        # Calcular la fecha del bloque.
        $fecha_bloque = obten_fecha($pattern_date, $pattern_sust, @array);
        print "La fecha del bloque es: $fecha_bloque\n";
        # Compararla con la fecha del proceso
        print "La fecha de proceso es: $fecha_proceso\n";
        if ($fecha_bloque == $fecha_proceso) {
            print "Fechas iguales, el bloque se procesa!\n";
            print "El patron encontrado es :$primer_patron:\n";
            print "El indice del patron es :$indice_patron:\n";
            print "El header que le corresponde es :$array_headers[$indice_patron]:\n";
            # procesar el bloque
            print "Procesando alertas:\n";
            procesa_alerta $id, $primer_patron, $array_headers[$indice_patron], $file_alerts, @array;
            print "alerta procesada\n";
        } else {
            print "La fecha del bloque es :$fecha_bloque:, no es igual a :$fecha_proceso:, no se procesa\n";
        }
    }
    # limpiar el arreglo.
    undef(@array);
    # colocar ahora la linea que es parte del error.
    push(@array, $line);
    $num_bloques += 1;
  }
}

# al final, si tenemos algo en el arreglo, que siempre lo tendremos, que 
# cumpla tambien con el patron, imprimirlo
print STDOUT "Validando ultimo bloque\n";
if (@array > 0) {
  $primer_patron = "";
  $indice_patron = -1;
  print STDOUT "El bloque tiene datos\n";
  if (encuentra_patrones(\@array, \@array_patterns, \$primer_patron, \$indice_patron)) {
    # Calcular el id del bloque.
    $id = calcula_id(@array);
    print "El id del bloque es: $id\n";
    # Calcular la fecha del bloque.
    $fecha_bloque = obten_fecha($pattern_date, $pattern_sust, @array);
    print "La fecha del bloque es: $fecha_bloque\n";
    # Compararla con la fecha del proceso
    print "La fecha del proceso es: $fecha_proceso\n";
    if ($fecha_bloque == $fecha_proceso) {
        print "Fechas iguales, el bloque se procesa!\n";
        print "El patron encontrado es :$primer_patron:\n";
        print "El indice del patron es :$indice_patron:\n";
        print "El header que le corresponde es :$array_headers[$indice_patron]:\n";
        # procesar el bloque
        print "Procesando alertas:\n";
        procesa_alerta $id, $primer_patron, $array_headers[$indice_patron], $file_alerts, @array;
        print "alerta procesada\n";
    } else {
        print "La fecha del bloque es :$fecha_bloque:, no es igual a :$fecha_proceso:, no se procesa\n";
    }
  } else {
    print "El bloque no tiene alguno de los errores\n";
  }
}

# cerrar el archivo
close FILEHANDLE or die "No se pudo cerrar el archivo $file_filtered: $!";
