 #!/bin/bash

#######################################
## COMMENTS ABOUT THIS SCRIPT: ########
#######################################

###################################################################################################################################################
# This script (REQUIRES AFNI) takes as arguments a 4d nifti file, a mask with rois, the desired output name,
# and a method. If the method is not set to pearson,this script will automatically apply de fisher z transform to the rho values of the matrix. 
# The result of running this code will be a correlation matrix in a .csv file (comma delimited) which is ideal to be loaded in Rstudio.                                                                                                                                                 
###################################################################################################################################################


fmri_file=$1
rois_mask=$2
prefix=$3
method=$4

nrois=$(3dBrickStat -slow -max $rois_mask )

brain_mask=/AFNI/abin/MNI152_T1_2mm_brainmask.nii.gz

if [ -f $brain_mask ] 
then


3dNetCorr -fish_z  -inset $fmri_file  -in_rois $rois_mask  -prefix  $prefix \
 -mask $brain_mask  -push_thru_many_zeros -allow_roi_zeros 

	if [ "$method" = "pearson" ]
	then
	min=7
	max=$((nrois+6))
	else
	min=$((nrois +8))
	max=$(cat ${prefix}_000.netcc |wc -l)
	fi

	if [  -f ${prefix}_000.netcc ]
	then
	fat_mat2d_plot.py -input  ${prefix}_000.netcc -prefix $prefix -dpi 200 -cbar plasma -cbar_off -xticks_off -yticks_off

   	cat ${prefix}_000.netcc | sed -ne "$min,$max"p | sed 's/ /''/g' | sed 's/  /,/g' | sed   's/	/,/g' | sed 's/4.0000/1.0000/g' > ${prefix}.csv 

	rm  ${prefix}*netcc
	rm  ${prefix}*roidat
	rm ${prefix}*dset

	fi

else
echo
echo -e "++ERROR: file $brain_mask doesn't exists. Set up the brain_mask variable within this script" 

exit 1

fi




exit



