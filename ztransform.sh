#!/bin/bash

## Script to transorm value into  Z  scores throgh Fisher's transform

string=$1

dataset=$(ls | grep $string )
 
for i  in  $dataset

 do 
          zname=${i/'.nii.gz'/'_Z.nii.gz'}

         3dcalc -a $i  -expr 'atanh(a)'  -prefix $zname


done
