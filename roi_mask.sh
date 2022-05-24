#!/bin/bash



x=$1
y=$2
z=$3
r=$4
outbase=$5

atlas=$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz 

point_std=${outbase}_point_std.nii.gz

fslmaths $atlas -mul 0 -add 1 -roi $x 1 $y 1 $z 1 0 1 $point_std -odt float

sphere_std=${outbase}sphere${r}_std.nii.gz
fslmaths $point_std -kernel sphere $r -fmean $sphere_std -odt float

sphere_std_bin=${outbase}sphere${r}_std_bin.nii.gz
fslmaths $sphere_std -bin $sphere_std_bin

rm *point*
rm *std.nii.gz
