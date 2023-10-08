#!/bin/bash

vlpp_dir=/project/rrg-villens/dataset/PreventAD/pet/derivatives/vlpp_preproc_2022/Jan2023/vlpp_tau
subject_id=$1
afni_c=/scratch/afajardo/containers/afni.sif

# ------- 
echo  -e "++ Started at $(date)"
echo 
if [ -d  ${subject_id}.tmp ]; then

echo "++ ${subject_id}.tmp dir exists! Removing it..."
rm -rvf ${subject_id}.tmp

else 
echo "++ creating ${subject_id}.tmp dir"

fi
sleep 1.5s 
echo 
mkdir ${subject_id}.tmp

echo 


cp -v  $PWD/wm_mask_ero_v1.nii.gz ${subject_id}.tmp/wm_mask.nii.gz
cp -v  mean_anat_brain.nii.gz ${subject_id}.tmp/template.nii.gz
cp -v  ${vlpp_dir}/${subject_id}/anat/${subject_id}_T1w.nii.gz ${subject_id}.tmp
cp -v  ${vlpp_dir}/${subject_id}/mask/${subject_id}_roi-brain_mask.nii.gz ${subject_id}.tmp/sub_mask.nii.gz 

cd ${subject_id}.tmp

# mask the subject image

fslmaths ${subject_id}_T1w.nii.gz -mul sub_mask.nii.gz anat.nii.gz

# reorient anat to tpl

fslreorient2std anat.nii.gz anat.nii.gz

# linear registration
echo
echo "++ 1. Linear Registration to template"
flirt -v \
-in  anat.nii.gz \
-ref template.nii.gz \
-omat anat2tpl_affine.mat \
-out anat2tpl.nii.gz \
-bins 256 \
-cost corratio \
-searchrx -90 90 \
-searchry -90 90 \
-searchrz -90 90 \
-dof 12

echo
echo "++ Done"
echo 

#calcualte afine transformation

convert_xfm -omat tpl2anat_affine.mat -inverse  anat2tpl_affine.mat
echo

# use non-linear registration
echo "++ Starting non-linear registration"

fnirt -v \
--iout=anat2tpl_warp \
--in=anat.nii.gz \
--aff=anat2tpl_affine.mat \
--cout=anat2tpl_warpfield \
--jout=anat2tpl_jac \
--ref=template.nii.gz \
--warpres=10,10,10
echo
echo "++Done"

# Calculate inverse warp
echo
echo "++ Obtaining Inverse Warp Field "

invwarp  -v \
-w anat2tpl_warpfield.nii.gz \
-o tpl2anat_warpfield \
-r anat


# apply the transformation

"echo ++ Generating Mask"

applywarp -v \
--ref=anat.nii.gz \
--in=wm_mask.nii.gz \
--out=wm_mask_in_${subject_id} \
--warp=tpl2anat_warpfield.nii.gz 

# binarize mask
fslmaths wm_mask_in_${subject_id} -bin wm_mask_in_${subject_id}

# reorient 2 original space
singularity exec $afni_c \
 3dresample -input wm_mask_in_${subject_id}.nii.gz \
-master ${subject_id}_T1w.nii.gz \
-prefix  wm_mask_in_s${subject_id}_resampled.nii.gz 

#  overwrite mask 

mv wm_mask_in_sub-${subject_id}.nii.gz  ../wm_mask_in_${subject_id}.nii.gz 

cd ..

echo "++ Finished  at $(date)"
exit 0
