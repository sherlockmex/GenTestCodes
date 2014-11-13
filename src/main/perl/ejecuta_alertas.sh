#!/bin/sh

# Script para ejecutar las alertas

if [ -z "$1" -o -z "$2" ]; then
  echo "Uso: $0 seccion_read seccion_filter"
  exit
fi

WORKDIR=~/Soporte_Indeval/mensajes_error
PERLLOCAL=$WORKDIR/lib_perl

PERLLIB=$PERLLOCAL/lib/site_perl/5.8.8/aix-thread-multi:$PERLLOCAL/lib/site_perl/5.8.8:$PERLLOCAL/lib/5.8.8/aix-thread-multi:$PERLLOCAL/lib/5.8.8

echo "Ejecutando filtrado..."
echo "PERLLIB=$PERLLIB perl $WORKDIR/ReadErrorBlockRotated.pl Config.ini $1 > $WORKDIR/log/ReadErrorBlockRotated.log &"
PERLLIB=$PERLLIB perl $WORKDIR/ReadErrorBlockRotated.pl Config.ini $1 > $WORKDIR/log/ReadErrorBlockRotated.log &

echo "Ejecutando proceso de alertas..."
echo "PERLLIB=$PERLLIB perl $WORKDIR/ProcessErrorRotated.pl Config.ini $2 > $WORKDIR/log/ProcessErrorRotated.log &"
PERLLIB=$PERLLIB perl $WORKDIR/ProcessErrorRotated.pl Config.ini $2 > $WORKDIR/log/ProcessErrorRotated.log &
 
echo "Ejecutando tail..."
tail -f $WORKDIR/log/ReadErrorBlockRotated.log $WORKDIR/log/ProcessErrorRotated.log
