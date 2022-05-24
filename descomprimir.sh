#!/usr/bin/env bash
# File: descomprimir.sh
 
function descomprimir {
files=$(ls *.tar.gz)

for i in $files
do 

tar -xvf $i

done
}


