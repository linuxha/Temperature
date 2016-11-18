#!/bin/bash

############################################################################
# Nothing fancy, just keep 2 days of backups
############################################################################
if [ -f "temp.png.1" ]; then
    cp temp.png1 temp.png.2
fi
cp temp.png temp.png.1

#
cd ${HOME}/dev/Temperature/temperature

for i in *.dat.1
do
    nom=$(basename $i .dat.1)
    cp $i $nom.dat.2
done 2>/dev/null

for i in *.dat
do
    cp $i $i.1
done
