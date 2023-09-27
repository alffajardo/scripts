#!/bin/bash
#Creator: Alfonso Fajardo
# Date

help(){
echo -e "\e[0;33m"
 echo " USAGE: $0 [flags]"
 echo ""
 echo " COMPULSORY ARGUMENTS:" 
 echo " -s: PARTICIPANT ID"
 echo " -p: PATH TO PET SCAN" 
 echo " -f: PATH TO FREESURFER RECON-ALL OUTPUT"
 echo " -h: Display this help information"
echo -e "\e[0m"

}

if [ $# -eq 0 ] ; then
help
exit 0
fi

# --------- Validate compulsory arguments

# Case optional flags
optstring=":s:p:f:h"

while getopts $optstring options ; do

    case $options in
        s) subject_id=${OPTARG}
        ;;
        p) petscan_dir=${OPTARG}
        ;; 
        f) freesurfer_dir=${OPTARG}
        ;;
        h) help
           exit 0 
        ;;
        ?) 
        echo -e "\e[0;31mERROR: Invalid option -${OPTARG}\e[0m"
        exit 1 
        ;;
    esac

done

echo ""

# ---------------CHECK IF PARTICIPANTS.TSV EXIST------------------------


if [[ -f "participants.tsv" ]] ;then
echo "++ participants.tsv Exists: Appending to existing file..."

else
sleep 1s 

echo  "++ Creating TSV file"
echo -e  "participant_id"\\t"fs_dir"\\t"pet_dir"\\t"Anat_normalization_QC"\\t"Template_normalization_QC" > participants.tsv

fi


## check if conpulsory arguments exists 
if [ -z $subject_id ]; then
 echo -e "\e[0;31mERROR: SUBJECT_ID variable  has not been set.\e[0m"
 exit 1
fi

## --------- Check if pet Scan exist ------------

if   [ ! -d $petscan_dir ] || [ -z $petscan_dir ]; then
    echo -e "\e[0;31mERROR: PET SCAN DIR $petscan_dir not found.\e[0m"
    exit 1
fi

## --------- Check if freesurfer dir  exist ------------

if  [ ! -d $freesurfer_dir ] || [ -z $freesurfer_dir ]; then
    echo -e "\e[0;31mERROR: recon-all (FREESURFER) output $freesurfer_dir not found.\e[0m"
    exit 1
fi


# Now append to the variables to the directory
echo "
 SUBJECT ID: $subject_id
 PET SCAN DIR: $petscan_dir
 FREESURFER DIR: $freesurfer_dir 
"

echo -e $subject_id\\t$freesurfer_dir\\t$petscan_dir >> participants.tsv
sleep 1s
echo "++DONE!!"

exit 0
