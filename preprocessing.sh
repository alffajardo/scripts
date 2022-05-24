#!/bin/bash


##reoorient images

fslreorient2std sub-04165_T1w.nii.gz anat
fslreorint2std sub-04165_task-rest_bold.nii.gz func

## preprocess T1W

bet sub-04165_T1w.nii.gz highres_bet -f 0.33 -R -B

#### correct fmri motion correction

mcflirt -in func -o func_mocor -mats -plots -report -spline_final
##

### slice timing correction  ## interleaved aquisition

slicetimer -i func_mocor.nii.gz -o func_mocor_stc --odd -v

### create mean func

fslmaths func_mocor_stc.nii.gz -Tmean mean_functional

## perform bet in mean_funcional

bet mean_functional.nii.gz mean_functional -f 0.4 -m

### multiply functional for bet_mask

fslmaths mean_functional -bin -mul func_mocor_stc func_mocor_stc_bet

##register functional mean volume to T1

mkdir segmentation

cp mean_functional.nii.gz segmentation
cp highres_bet.nii.gz segmentation  

flirt -in mean_functional -ref highres_bet -out func2highres -omat func2highres.mat -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp trilinear

## invert matrix

convert_xfm func2highres.mat -omat highres2func.mat -inverse

## outpuy highres in functional space for segmentation

flirt -in highres_bet -out highres2func -ref mean_functional.nii.gz -applyxfm -init highres2func.mat 

## segmentation of T1 in functional space

fast  -v -t 1 -n 3 -H 0.1 -I 4 -l 20.0 --nopve -o highres2func highres2func

## get masks of csf gm and wm

fslmaths highres2func_seg.nii.gz -thr 1 -uthr 1 -bin  csf_mask
fslmaths highres2func_seg.nii.gz -thr 2 -uthr 2 -bin  gm_mask
fslmaths highres2func_seg.nii.gz -thr 3 -uthr 3 -bin wm_mask
### multiply segmentation mask for func_mask 
fslmaths mean_functional.nii.gz -bin -mul csf_mask csf_mask 
fslmaths mean_functional.nii.gz -bin -mul gm_mask gm_mask 
fslmaths mean_functional.nii.gz -bin -mul wm_mask wm_mask 
## create folder to work with regresors
mkdir ../regressors
cp *mask* ../regressors
cd ..

cp  func_mocor_stc_bet.nii.gz regressors
cp func.nii.gz regressors/raw_func.nii.gz

mv sub-04165_task-rest_mocor.mat regressors

### nuisance regressors
cd regressors

### calculate motion outliers based on framewise displacement metric

fsl_motion_outliers -i raw_func.nii.gz -o outliers -s FD.txt --fd -v --thresh=0.25

if [ ! -f outliers ]
  then
  touch outliers
fi
cat outliers | sed 's/  / /g' >> motion_outliers.mat ; rm outliers

### lineal detrend regressor
nvols=$(fslnvols func_mocor_stc_bet.nii.gz)
vols=$(seq -s ' ' 01 $nvols)



for v in $vols; do echo $v >> lineal.mat; done

### cuadratic detrending 
for c in $vols; do echo "$c^2" | bc >> quadratic.mat; done
###

### calculate wm mean
fslmeants -i func_mocor_stc_bet.nii.gz -o wm_mean -m wm_mask
cat wm_mean | cut -d ' ' -f 1 >> wm_mean.mat ; rm wm_mean

## calculate csf mean

fslmeants -i func_mocor_stc_bet.nii.gz -o csf_mean -m csf_mask
cat csf_mean | cut -d ' ' -f 1 >> csf_mean.mat ; rm csf_mean
##calculate wm first 5 components 

fslmeants -i func_mocor_stc_bet.nii.gz --eig --order=5 -v -m wm_mask -o wm

cat wm | sed 's/  / /g' | cut -d ' ' -f 1,2,3,4,5 > wm_5components.mat ; rm wm

## Calculate csf compcor 
fslmeants -i func_mocor_stc_bet.nii.gz --eig --order=5 -v -m csf_mask -o csf

cat csf | sed 's/  / /g' | cut -d ' ' -f 1,2,3,4,5 > csf_5components.mat ; rm csf

### calculate friston parameters with an R script
cp ../func_mocor.par .

cat func_mocor.par | sed 's/  / /g' | cut -d ' ' -f 1,2,3,4,5,6 > motion_parameters.mat
calc_friston24.R motion_parameters.mat 

## create matrix of regression

paste -d ' ' lineal.mat quadratic.mat csf_mean.mat wm_mean.mat csf_5components.mat wm_5components.mat friston24.mat motion_outliers.mat  > nuisance_mat.txt

## transform matrix for fsl glm

Text2Vest  nuisance_mat.txt nuisance.mat

### perform regression to obtain residuals
fsl_glm -i func_mocor_stc_bet.nii.gz  -d nuisance.mat --out_res=residuals_mocor_stc_bet
mv residuals_mocor_stc_bet.nii.gz ..
mkdir params
mv *.mat* params
rm *.nii.gz 
mv FD.txt params
rm *
cd ..

### create a new mask

fslmaths residuals_mocor_stc_bet.nii.gz -abs -bin -Tmean func_mask

### apply bandpass_filter (with afni)

3dBandpass -input residuals_mocor_stc_bet.nii.gz -prefix residuals_mocor_stc_bet_bandapassed.nii.gz -band 0.01 0.08 -nodetrend -mask func_mask.nii.gz 

### create smoothed image

fslmaths residuals_mocor_stc_bet_bandapassed.nii.gz -kernel gauss 1.6985138 -fmean -mul func_mask.nii.gz residuals_mocor_stc_bet_bandapassed_fwhm4.nii.gz


######################################################################
######################################################################
######################################################################



#### try linear and no linear registration to standar space 

flirt -in  highres_bet.nii.gz -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -omat highres2std.mat -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12

flirt -in mean_functional.nii.gz -ref highres_bet.nii.gz -omat func2standard2.mat -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 

convert_xfm -concat func2standard1.mat -omat func2standard.mat func2standard2.mat

flirt -in residuals_mocor_stc_bet_bandapassed.nii.gz -out residuals_mocor_stc_bet_bandapassed_std_linear -ref /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -applyxfm -init func2standard.mat -interp trilinear

#### non linear registration 
flirt -in  highres_bet.nii.gz -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -omat highres2standard_dof12.mat -out highres2std.nii.gz -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12

fnirt --iout=highres2std_nonlinear.nii.gz --in=highres_bet.nii.gz --aff=highres2standard_dof12.mat --cout=highres2standard_warp --iout=highres2standard_nonlinear --jout=highres2highres_jac --config=T1_2_MNI152_2mm --ref=$FSLDIR/data/standard/MNI152_T1_2mm  --warpres=10,10,10

convertwarp --ref=$FSLDIR/data/standard/MNI152_T1_2mm_brain --premat=func2standard2.mat --warp1=highres2standard_warp --out=func2standard_warp

applywarp --ref=$FSLDIR/data/standard/MNI152_T1_2mm_brain --in=residuals_mocor_stc_bet_bandapassed.nii.gz  --out=residuals_mocor_stc_bet_bandapassed_std_nonlinear.nii.gz  --warp=example_func2standard_warp



