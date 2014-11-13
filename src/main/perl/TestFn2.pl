#!/usr/bin/perl
#
# @File TestFn2.pl
# @Author T41609
# @Created 13/11/2014 01:27:21 AM
#

use strict;
use warnings;
use Digest::SHA::PurePerl qw(sha256_hex);
use Config::Tiny;
use File::Tail;

=begin comment
 Funci�n que muestra la ayuda y se sale.
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
    print "  file_phones = ruta_file_phones     # Archivo con numeros de telefono para enviar SMSs\n";
    print "  file_emails = ruta_file_emails     # Archivo con correos electronicos para enviar correos\n";
    print "pattern_block = patron_inicio_bloque # Patron de inicio de bloque\n";
    print " pattern_date = patron_fecha         # Patron de busqueda de fecha\n";
    print " pattern_sust = patron_sustitucion   # Patron de sustitucion para fecha\n";    
    exit -1;
}

=begin comment
Funci�n que valida los argumentos y si no son los adecuados, muestra la ayuda del programa y luego se sale.
=cut
sub valida_args {
  my @args = @_;
  # print join(",", @args), "\n";
  if (@args < 2) {
    muestra_ayuda;
  }
}

=begin comment
 Funci�n que carga parametros.
=cut
sub carga_params {
    my $config_name   = shift;
    my $section_name  = shift; 
    my $file_filtered = $_[0];
    my $file_pattern  = $_[1];
    my $file_headers  = $_[2];
    my $file_alerts   = $_[3];
    my $file_phones   = $_[4];
    my $file_emails   = $_[5];
    my $pattern_block = $_[6];
    my $pattern_date  = $_[7];
    my $pattern_sust  = $_[8];

    # cargar del archivo de configuraci�n
    my $Config = Config::Tiny->new;
    # cargar el config.
    $Config = Config::Tiny->read( $config_name );
    # leer propiedades.
    $$file_filtered = $Config->{$section_name}->{file_filtered};
    $$file_pattern  = $Config->{$section_name}->{file_pattern};
    $$file_headers  = $Config->{$section_name}->{file_headers};
    $$file_alerts   = $Config->{$section_name}->{file_alerts};
    $$file_phones   = $Config->{$section_name}->{file_phones};
    $$file_emails   = $Config->{$section_name}->{file_emails};
    $$pattern_block = $Config->{$section_name}->{pattern_block};
    $$pattern_date  = $Config->{$section_name}->{pattern_date};
    $$pattern_sust  = $Config->{$section_name}->{pattern_sust};
    # validar los argumentos.
    muestra_ayuda("file_filtered") unless (defined($$file_filtered));
    muestra_ayuda("file_pattern") unless (defined($$file_pattern));
    muestra_ayuda("file_headers") unless (defined($$file_headers));
    muestra_ayuda("file_alerts") unless (defined($$file_alerts));
    muestra_ayuda("file_phones") unless (defined($$file_phones));
    muestra_ayuda("file_emails") unless (defined($$file_emails));
    muestra_ayuda("pattern_block") unless (defined($$pattern_block));
    muestra_ayuda("pattern_date") unless (defined($$pattern_date));
    muestra_ayuda("pattern_sust") unless (defined($$pattern_sust));
}

=begin comment
 Funci�n que carga las variables globales.
=cut
sub carga_global_params {
    my $config_name   = shift;
    my $process_date  = $_[0];
    my $actual_date   = $_[1];
     # cargar del archivo de configuraci�n
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
 Funci�n que calcula la fecha del bloque.
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
 Funci�n que calcula la fecha actual.
=cut
sub obten_fecha_actual { 
  my $date = localtime();
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
  my $fecha = sprintf("%04d%02d%02d", $year+1900, $mon+1, $mday);
  return $fecha;
}

sub obten_nombre_filtrado {
    # cargar de la configuracion
    my $config_file = $ARGV[0];
    my $process_date;
    my $actual_date;
    carga_global_params $config_file, \$process_date, \$actual_date;

    $actual_date = obten_fecha_actual unless defined($actual_date);

    my $file_filtered;
    my $section_config = $ARGV[1];
    carga_params $config_file, $section_config, \$file_filtered;

    return "$file_filtered.$actual_date";
}

# Valida los argumentos
valida_args @ARGV;

my $config_file;
my $section_config;

$config_file = $ARGV[0];
$section_config = $ARGV[1];

# Par�metros globales.
my $process_date;
my $actual_date;

# Cargar par�metros
my $file_filtered;
my $file_pattern;
my $file_alerts;
my $file_headers;
my $file_phones;
my $file_emails;
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
    \$file_phones, \$file_emails,
    \$pattern_block, \$pattern_date, \$pattern_sust;

my @array_patterns;
my @array_headers;
my @array_phones;
my @array_emails;

# el archivo viene seguido de la fecha....
my $fecha_proceso = $process_date;

# el nombre del archivo filtrado cambia...
$file_filtered .= ".".$actual_date;

# as� como el nombre del archivo de alertas.
$file_alerts .= ".".$actual_date;

print STDOUT "Ejecutando lectura sobre\n[$file_filtered]\n".
"archivo de coincidencias [$file_pattern]\n".
"archivo de encabezados por coincidencia [$file_headers]\n".
"archivo de alertas [$file_alerts]\n".
"archivo de telefonos [$file_phones]\n".
"archivo de emails [$file_emails]\n".
"con patron de bloque [$pattern_block]\n".
"patron de fecha [$pattern_date]\n".
"patron de sustitucion [$pattern_sust]\n";


my $nombre_filtrado = obten_nombre_filtrado;

print "El nombre filtrado es $nombre_filtrado\n";
