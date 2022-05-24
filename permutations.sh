#!/usr/bin/bash/

# File: permutations.sh

# This script runs  a glm permutation test on FSL 5.0.11. the # of permutations is fsl default (5000). Need to specify filowing posicional arguments:

# $1 -- 4dfile
# $2 - design matrix
# $3 contrast matrix
# $4  ftest matrix
# $5 output directory <dir>/<output name>
# $6 mask
file=$1
design_mat=$2
contrast=$3
f_test=$4
output= $5
mask=$6

fsl5
randomise -i $file -o $output -d $design_mat -t $contrast -f $f_test -m $mask  -T
