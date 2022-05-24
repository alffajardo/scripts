#!/bin/bash 
## this script searches for a given pattern and substitute for another given partter

pattern=$1
sub_string=$2

files=$(ls | grep $pattern)

for i in $files

 do 
    newname=$(echo $i | sed -se "s/$pattern/$sub_string/g")

    mv $i $newname

 done
