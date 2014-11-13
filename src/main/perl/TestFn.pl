#!/usr/bin/perl
#
# @File TestFn.pl
# @Author Leticia
# @Created 9/11/2014 05:37:21 PM
#

use strict;
use warnings;
use Digest::SHA::PurePerl qw(sha256_hex);
use Config::Tiny;

=begin comment
 Función que busca los errores de un arreglo en otro arreglo.
=cut
sub encuentra_errores {
  my @array = @{$_[0]};
  my @array_errors = @{$_[1]};
  my $primer_error = $_[2];
  my $cuenta_errores = 0;
  my $cuenta_este_error = 0;
  #print "Arreglo a buscar:\n", join("", @array), "\n";
  #print "Arreglo de errores:\n", join("\n", @array_errors), "\n";
  # recorrer el arreglo de errores para buscarlos en el arreglo de entrada.
  foreach(@array_errors) {
    my $error = $_;
    #print "Buscando error :$error:\n";
    my @este_error = grep(/$error/, @array);
    my $len_este_error = @este_error;
    #print "Resultado de grep: :", join("", @este_error), ": -> $len_este_error\n";
    if ($len_este_error > 0) {
        #print "Este error es: :", join(":", @este_error), ":\n";
        if (length($$primer_error) == 0) {
            #print "Fijando primero error a $este_error[0]\n";
            $$primer_error = $error;
        } else {
            #print "El primer error ya tiene valor :$$primer_error:\n";
        }
    } else {
        #print "No se encontro :$error:\n";
    }
    $cuenta_errores += @este_error;
  }
  #print "Errores encontrados en el bloque: $cuenta_errores\n";
  return $cuenta_errores > 0;
}

=begin comment
 Función que calcula la fecha del bloque.
=cut
sub obten_fecha { 
  my $pattern_date = shift;
  my @array = @_;
  my $date = localtime();
  #print "Patron de fecha :$pattern_date:\n";
  #print "Bloque:\n----- BEGIN BLOQUE -----\n".join("", @array)."----- END BLOQUE -----\n";
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
  my $fecha = sprintf("%04d%02d%02d", $year + 1900, $mon, $mday);
  # print "Fecha actual: $fecha\n";
  if ( $array[0] =~ /$pattern_date/ ) {
  # if ($array[0] =~ /.*\[([0-9]{2})\/([0-9]{2})\/([0-9]{4}) ([0-9]{2}):([0-9]{2}):([0-9]{2})].*/ ) {
    $fecha = $3.$2.$1;
  }
  # print "Fecha encontrada: $fecha\n";
  return $fecha;
}

=begin comment
 Función que procesa las alertas.
=cut
sub procesa_alerta {
    my $id = shift;
    my $error = shift;
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

        print "Alerta ID: $id\nError: $error\nArchivo alertas: $file_alertas\nBloque\n----- BEGIN BLOQUE -----\n", join("", @array), "\n----- END BLOQUE -----\n";

        # si puede procesarse la alerta, agregar el ID al final del archivo
        open ALERTHANDLE, ">>".$file_alertas or print "El archivo de alertas $file_alertas no puede abrirse: $!\n";
        print ALERTHANDLE $id,"\n";
        close ALERTHANDLE;
        # print "Alerta procesada, Id $id guardado\n";
    }
}

=begin comment
 Función que calcula el id del bloque.
=cut
sub calcula_id {
  my (@array) = @_;
  
  my $digest;
  my $sha = Digest::SHA::PurePerl->new(256);
  for (@array) {
    $sha->add($_);
  }
  $digest = $sha->hexdigest;
  return $digest;
}

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
        print "Buscando patron :$pattern:\n";
        my @este_patron = grep(/$pattern/, @array);
        my $len_este_patron = @este_patron;
        print "Resultado de grep: :", join("", @este_patron), ": -> $len_este_patron\n";
        $cuenta_coincidencias += $len_este_patron;
    }
    print "Numero de coincidencias: $cuenta_coincidencias\n";
    return $cuenta_coincidencias;
}

=begin comment
 Función que calcula la fecha actual.
=cut
sub fecha_actual { 
  my $date = localtime();
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
  my $fecha = sprintf("%04d%02d%02d", $year+1900, $mon, $mday);
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
    my $sufijo_fecha = fecha_actual;

    # Abrir archivo.
    if ($first_time) {
        open FILEHANDLE, ">$file_filtered.$sufijo_fecha" or die "No se pudo abrir el archivo $file_filtered.$sufijo_fecha: $!";
    } else {
        open FILEHANDLE, ">>$file_filtered.$sufijo_fecha" or die "No se pudo abrir el archivo $file_filtered.$sufijo_fecha: $!";
    }
    # Escribir el arreglo.
    print FILEHANDLE join("", @array);
    # e imprimir el delimitador, si está definido.
    print FILEHANDLE $delimiter, "\n" if defined $delimiter;
    # cerrar el archivo.
    close FILEHANDLE or die "No se pudo cerrar el archivo $file_filtered.$sufijo_fecha: $!";;    
}


my @array = ("ERROR [29/09/2014 15:07:44] (ExceptionProcessor.java:process:42) - se genero un error \n", "Quarter of a deadlock situation\n", "Dime an Unparseable number\n","Nickel\n");
my @array_errors = ("deadlock situation", "Unparseable number");
my $primer_error = "";

push (@array, localtime()."\n");

my $result = encuentra_errores(\@array, \@array_errors, \$primer_error);

print "El resultado: ", $result ? "true" : "false", " y el primer error es :$primer_error:\n";

my $patron = ".*\\[([0-9]{2})\\/([0-9]{2})\\/([0-9]{4}) ([0-9]{2}):([0-9]{2}):([0-9]{2})].*";

my $date = obten_fecha($patron, @array);
print "Fecha $date\n";

$date = obten_fecha($patron, @array_errors);
print "Fecha $date\n";

print "Procesa alerta\n";
procesa_alerta calcula_id(@array), $array_errors[0], "alertas.idx", @array;

my $file_source; 
my $file_filtered; 
my $pattern_block; 
my $file_display; 
my $file_omit; 
my $delimiter;

print "***** Cargando parametros ******\n";
carga_params "Config.ini", "SCO", \$file_source, \$file_filtered,
    \$pattern_block, \$file_display, \$file_omit, \$delimiter;

print "***** Parametros leidos ******\n";
print "Archivo fuente      :$file_source:\n";
print "Archivo filtrado    :$file_filtered:\n";
print "Patron de bloque    :$pattern_block:\n";
print "Archivo de busqueda :$file_display:\n";
print "Archivo de omision  :$file_omit:\n";
print "Delimitador         :$delimiter:\n" if defined($delimiter);

print "Cargando patrones a filtrar\n";
my @array_display = carga_patrones($file_display);
print "Patrones a filtrar (".scalar(@array_display)."):\n:", join(":\n:", @array_display), ":\n";

print "Cargando patrones a omitir\n";
my @array_omit = carga_patrones($file_omit);
print "Patrones a omitir (".scalar(@array_omit)."):\n:", join(":\n:", @array_omit), ":\n";

print "Contando coincidencias de filtrado\n";
my $coincidencias_filtrado = cuenta_coincidencias(\@array, \@array_display);
print "# coincidencias filtrado encontrado = $coincidencias_filtrado\n";

print "Contando coincidencias de omision\n";
my $coincidencias_omit = cuenta_coincidencias(\@array, \@array_omit);
print "# coincidencias omitir encontrado = $coincidencias_omit\n";

print "Por escribir la primera vez el archivo rotado\n";
my $primera_vez = 1;
escribe_bloque_filtrado_rotadofecha $file_filtered, $delimiter, $primera_vez, @array;
$primera_vez = undef;

print "Por escribir la segunda vez el archivo rotado\n";
escribe_bloque_filtrado_rotadofecha $file_filtered, $delimiter, $primera_vez, @array;

print "Por escribir la tercera vez el archivo rotado\n";

push (@array, localtime());

escribe_bloque_filtrado_rotadofecha $file_filtered, $delimiter, $primera_vez, @array;

