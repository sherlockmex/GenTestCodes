#!/usr/bin/perl
#
# @File ProcessErrorRotated.pl
# @Author Leticia 
# @Created 8/11/2014 10:06:19 PM
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
 Funci�n que carga los errores desde un archivo.
=cut
sub carga_patterns {
  my ($file, $pattern_validate) = @_;
  open FILEHANDLE, "<".$file or die "No se pudo abrir el archivo $file: $!";

  my @array_patterns;
  while (<FILEHANDLE>) {
    chomp($_);
    if (length($_)) {
      # print ":", $_ , ":";
      push (@array_patterns, $_) unless (defined($pattern_validate) && $_ !~ m/$pattern_validate/);
    }
  }
  return @array_patterns;
}

=begin comment
 Funci�n que busca los patrones de un arreglo en otro arreglo.
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
 Funci�n que calcula el id del bloque.
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

=begin comment
 Funci�n que procesa las alertas.
=cut
sub procesa_alerta {
    my $id = shift;
    my $error = shift;
    my $header = shift;
    my $file_alertas = shift;
    my $file_filtered = shift;
    my @array_phones = @{$_[0]};
    my @array_emails = @{$_[1]};
    my @array = @{$_[2]};
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

        #print "Alerta ID: $id\nError: $error\nEncabezado: $header\n".
        #    "Archivo alertas: $file_alertas\nBloque\n".
        #    "----- BEGIN BLOQUE -----\n", join("", @array), 
        #    "\n----- END BLOQUE -----\n";
            
        my $url = "10.100.129.3:7005";
        my $ruta_log = "~/Soporte_Indeval/salida/ProcessError.log";

	foreach (@array_phones) {
	    my $comando_sms = "sudo wget -a $ruta_log \"http://$url/mensajeria-webServices/WebServiceMensajeria?string=$_&string0=$header&operation.invoke=enviarMensajeSms\"";
	    
	    # print "Comando a ejecutar para enviar mensaje:\n".$comando_sms."\n";
	    
 	    my $output = qx/$comando_sms/;
	}

	# my $body = $file_filtered.":".$array[0];
	my $body = join("", @array); 
	$body =~ s/[\n\#]//g; 
	# print "Body generado: :$body:";

	foreach (@array_emails) {
	    my $comando_email = "sudo wget -a $ruta_log \"http://$url/mensajeria-webServices/WebServiceMensajeria?string=$_&string0=$header&string1=$body&operation.invoke=enviarMensajeSmtp\"";
	    # print "Comando a ejecutar para enviar correo:\n".$comando_email."\n";

	    my $output_email = qx/$comando_email/;
	}

	qx/rm -f WebServiceMensajeria*/;

        # si puede procesarse la alerta, agregar el ID al final del archivo
        open ALERTHANDLE, ">>".$file_alertas or 
            print "El archivo de alertas $file_alertas no puede abrirse: $!\n";
        print ALERTHANDLE $id,"\n";
        close ALERTHANDLE;
        # print "Alerta procesada, Id $id guardado\n";
    }
}

sub guarda_pid {
#    open PIDFILE, ">pid/";
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

print "Cargando patrones de coincidencia del archivo $file_pattern\n";
@array_patterns = carga_patterns($file_pattern);
print "Patrones cargados :", scalar(@array_patterns), "\n";

print "Cargando encabezados por cada patron de coincidencia del archivo $file_headers\n";
@array_headers = carga_patterns($file_headers);
print "Encabezados cargados :", scalar(@array_headers), "\n";

print "Cargando telefonos del archivo $file_phones\n";
@array_phones = carga_patterns($file_phones, "^[0-9]{10}\$");
print "Telefonos cargados :", scalar(@array_phones), "\n", join("\n", @array_phones), "\n";

print "Cargando emails del archivo $file_emails\n";
@array_emails = carga_patterns($file_emails, "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+\$");
print "Encabezados cargados :", scalar(@array_emails), "\n", join("\n", @array_emails), "\n";

print "Los patrones leidos son: \n----- BEING PATTERNS -----\n:", 
    join(":\n:", @array_patterns), ":\n----- END PATTERNS -----\n";

print "Los encabezados leidos son: \n----- BEING HEADERS -----\n:", 
    join(":\n:", @array_headers), ":\n----- END HEADERS -----\n";

print "Abriendo archivo a buscar: $file_filtered\n";
# open FILEHANDLE, "<".$file_filtered or die "No se pudo abrir el archivo ".$file_filtered;

my $fn_name = sub {
    # cargar de la configuracion
    my $config_file = $ARGV[0];
    my $process_date;
    my $actual_date;
    carga_global_params $config_file, \$process_date, \$actual_date;

    $actual_date = obten_fecha_actual unless defined($actual_date);

    my $file_filtered;
    my $section_config = $ARGV[1];
    carga_params $config_file, $section_config, \$file_filtered;

    # print "Archivo filtrado: $file_filtered.$actual_date\n";

    return "$file_filtered.$actual_date";
};

print "Se va a abrir archivo ".$fn_name->()."\n";

my $file;
$file=File::Tail->new(
	name=>$file_filtered, 
	maxinterval=>30, 
	adjustafter=>5, 
	interval=>1, 
	tail=>-1,
        reset_tail=>-1,
	name_changes=>\&$fn_name ) or 
		die "No se pudo abrir archivo $file_filtered (".$fn_name->().") $!";

my @array;
my $num_bloques=0;

my $primer_patron = "";
my $indice_patron = -1;
my $id;
my $fecha_bloque;

my $line;

# while(<FILEHANDLE>) {
while(defined($line=$file->read)) {
  # si la l�nea no cumple el patr�n de bloque, agregarla al arreglo
  # my $line=$_;  
  unless ($line=~/$pattern_block/) {
    # es parte del error
    push(@array, $line);    
  } else {
    # es un patr�n reportable.
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
            procesa_alerta $id, $primer_patron, $array_headers[$indice_patron], $file_alerts, $file_filtered, \@array_phones, \@array_emails, \@array;
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
        procesa_alerta $id, $primer_patron, $array_headers[$indice_patron], $file_alerts, $file_filtered, \@array_phones, \@array_emails, \@array;
        print "alerta procesada\n";
    } else {
        print "La fecha del bloque es :$fecha_bloque:, no es igual a :$fecha_proceso:, no se procesa\n";
    }
  } else {
    print "El bloque no tiene alguno de los errores\n";
  }
}

# cerrar el archivo
# close FILEHANDLE or die "No se pudo cerrar el archivo $file_filtered: $!";
close $file or die "No se pudo cerrar el archivo $file_filtered: $!";
