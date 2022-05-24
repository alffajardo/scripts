#!/bin/bash
# generate correlation maps

### Required files
### functional image
### ROI mask
### AfNI comand: 3dTcorr1D -prefix <output.nii.gz>  -mask <func_mask.nii.gz> <imput.nii.gz > <timeseriesfile.ts>

func=$1
roi_mask=$2
output=$3


### Estract time series

fslmeants -i $func -m $roi_mask -o ${output}.ts

  
## compute 3dmap


3dTcorr1D -prefix ${output}_rmap.nii.gz  $func ${output}.ts



rm ${output}.ts

