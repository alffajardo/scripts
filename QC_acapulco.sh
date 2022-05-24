#!/usr/bin/env bash


database=$1
# --------------Assess if the arguments provided exist-------------------------

## Make sure to provide a database_name directory
if [ ! -d "$database" ] || [ $# -eq 0 ]
then
    echo
    echo -e "\e[2;31mNo Valid arguments provided. Please provide a valid\
 database name or path.\e[0m"
    echo
    echo -e "\e[0;32mUSAGE: QC_acapulco.sh <PATH_TO_database>.\e[0m"
    echo
    echo -e  "\e[0;32mE.G: QC_acapulco.sh COC100\e[0m"
    echo
    echo
    echo "HELP":
    echo
echo -e "******************************************************************************************************************"
echo "*This program requieres 2 files:"
echo
echo "* 1: Anatomical raw (unprocessed) T1w files ( e.g ../FS_ya/COC100_sub-001_T1w.nii.gz).
* 2: ACAPULCO segmentation file in subject native space (e.g COC100_sub-001_T1w_n4_mni_seg_post_inverse.nii.gz)."
echo
echo "* Make sure that your working directory is the cohort directory (e.g COC)."
echo "* Also make sure that your enigma_cerebellum folder at least looks something similar to this:"

echo -e "\e[0;97m
enigma_cerebellum/
├── COC
│   └── COC100
│       └── COC100_sub-001_T1w
│           ├── COC100_sub-001_T1w_n4_mni_seg_post_inverse.nii.gz
│           └── COC100_sub-001_T1w_n4_mni_seg_post_volumes.csv
└── FS_ya
    └── COC100_sub-001_T1w.nii.gz"

echo -e "\e[0m"
echo "*****************************************************************************************************************"
echo
exit 1
fi

database_name=$(basename $database)

fsldir_exist=$(echo $FSLDIR)

# ---------------Check if FSLDIR  and FSLEYES exist ---------------------------
if [ -z "$fsldir_exist" ]
then
  echo -e  "\e[0;31mERROR: \$FSLDIR NOT FOUND!!!\e[0m"
  exit 1
elif [ ! -f "${FSLDIR}/bin/fsleyes" ]
then
  echo -e  "\e[0;31mERROR: NO FSLEYES INSTALATION FOUND!!!\e[0m"
  exit 1
fi
# -----------Check if csv database exists or create it  -----------------------

mkdir -p QC/

if [[ ! -f "QC/QC_${database_name}.csv" ]]
then
echo -e "\e[0;36m+ QC File For This database Doesn't Exist.\n
++ I Will Create The file: \e[0\e[1;32mQC/QC_${database_name}.csv \e[0m"
echo
echo -e "Database,Subject_ID,Checked,Segmentation Notes,Does mask include whole \
cerebellum?,Exclude?,Cohort" > QC/QC_${database_name}.csv
fi

cohort=$(echo ${database_name:0:3})

## ---------------------GENERATE A SUBJECTS LIST ------------------------------

## Get all the subjects in the cohort /
find -maxdepth 3 -type d -name "${database_name}_*" -exec basename {} \; \
| cut -d '_' -f 2  | sort > tmp.${database_name}_all_subs.txt

## list of all done subjects
cat QC/QC_${database_name}.csv | cut -d ',' -f 2 | tail -n +2 \
> tmp.${database_name}_done_subs.txt

# To do subjects
to_do=$(awk 'FNR==NR {a[$0]++; next} !($0 in a)' \
tmp.${database_name}_done_subs.txt tmp.${database_name}_all_subs.txt)

if [ "$(cat tmp.${database_name}_done_subs.txt | wc -w)" -lt 1 ]
then
  to_do=$(cat tmp.${database_name}_all_subs.txt)
else
  to_do=$(awk 'FNR==NR {a[$0]++; next} !($0 in a)' \
  tmp.${database_name}_done_subs.txt tmp.${database_name}_all_subs.txt)
fi

# -------------------- Print information about current cohort -----------------
echo
echo -e "\e[0;93m+++ THIS DATABASE HAS" "\e[4;97m$(echo $to_do | wc -w) \e[0m"\
 "\e[0;93mSUBJECTS TO GO: \e[0m"
echo -e "\e[3;93m"
echo $to_do
echo -e "\e[0m"

## remove temporary files------------------------------------------------------

rm tmp.${database_name}_*

# ------------ Start a foor loop to iterate over each subject -----------------

for subj in $to_do
do
echo
echo -e "\e[1;33m++++ SEARCHING FOR DATA MATCHED WHITH SUBJECT-ID:\
 \e[6;97m${subj}\e[0m"
 echo ...
sleep 1s

# -------------------------- Search the necessary images. ---------------------
cd ..
t1_image=$( find $PWD -maxdepth 3 -name "*${subj}*.nii*" | grep $database_name)
cd $cohort
acapulco_image=$(find $database_name -name "*${subj}*_T1w_n4_mni_seg_post_inverse.nii.gz")
echo

# ------- Evaluate if the files exist ----------------------------------------

if [[ ! -f $t1_image ]] || [[ ! -f $acapulco_image ]]
then
  if [[ ! -f $t1_image ]]
  then
  echo
  echo -e "\e[0;97mAnatomical T1 raw file was not  found\e[0m"
 unset both_images
elif [[ ! -f $acapulco_image ]]
then
echo
echo -e "\e[0;97m ACAPULCO Segmentation "4_mni_seg_post_inverse.nii.gz"\
 file mas was not found\e[0m"
unset both_images
fi
else
  echo
  echo -e "\e[0;36m +++++  FILES FOUND: \n
  "$(basename $t1_image)"
  "$(basename $acapulco_image)"
  \e[0m"
  both_images=1
  echo
  echo -e "\e[0;36m LAUNCHING FSLEYES...\e[0m"
  echo
fi

# -------------------- Control flow for both images missing

# ---------------------- OPEN IMAGES WITH FSLEYES -----------------------------
if [[ "$both_images" -eq 1 ]]
then
fsleyes ${t1_image} ${acapulco_image} --overlayType label --lut random_big \
--outline --outlineWidth 3 ${acapulco_image} --overlayType volume --alpha 50 \
--cmap random &
sleep 2s
echo
echo
echo
echo "FSLEYES DETACHED FROM TERMINAL"
sleep 1s
clear
# ---------- Program workflow to fill QC database -----------------------------

request_answers=1
while [ "$request_answers" -eq 1 ]
do
  clear
  echo
  echo -e "\e[1;35mWrite down your Segmentation Notes:\e[0m"
  echo
  echo -e "\e[2;35mE.g., list here individual lobules that have been under or \
  overincluded,if they were detected as an outlier, if segmentation failed etc.\
  Write 'Exclude' followed by the lobule(s) to be excludede\e[0m"
  echo -e "\e[1;32m"
  read Segmentation_notes
  clear
  echo -e "\e[0m"
  clear
  echo
  echo
  echo  $Segmentation_notes
  echo
  clear
  echo
  echo -e "\e[1;35mDoes the mask include the whole cerebellum? (yes / no)\e[0m"
  echo -e "\e[1;32m"
  read cerebellum_included
  clear
  echo
  echo -e "\e[1;35mExclude? (yes /no):\e[0m"
  read exclude
  clear
  echo
  echo
  echo "Printing Summary..."
  sleep 1s
  echo
  echo
  echo -e "\e[4;32mSummary:\e[0m"
  echo -e "\e[1;32m"
  echo Database: $database_name
  echo Subject-ID: $subj
  echo Cohort: $cohort
  echo Segmentation Notes: $Segmentation_notes
  echo Complete Cerebellum included in the mask?: $cerebellum_included
  echo Exclude Subject?: $exclude
echo
echo -e "\e[1;33mDo you wish to save your answers (yes/no)?\e[0m"
echo
read confirmation

#--------------------------- Control flow for confirmation --------------------

while ! [[ "$confirmation" == "yes" || "$confirmation" == "no" ]]
do
  echo  -e "\e[0;35m\n '$confirmation' is not a valid answer.\
Please type a valid option\e[0m""\e[3;35m[ yes/no ]\e[0m"
   sleep 0.5s
   echo
  echo -e "\e[1;33mDo you wish to save your answers (yes/no)?\e[0m"
  echo
  read confirmation

done

# --------------------- Save answers in the  QC files -------------------------
 if [ "$confirmation" == "yes" ]
  then
    echo "$database_name,$subj,yes,$Segmentation_notes,$cerebellum_included\
,$exclude,$cohort" >> QC/QC_${database_name}.csv
  echo
  echo -e "\e[1;34m+++ YOUR ANSWERS HAVE BEEN SAVED!!!!!!\n"
  echo
  echo "You may close the fsleyes viewer now."
  unset confirmation
  echo -e "\e[0m"
  sleep 1
  clear
  echo
  let request_answers=0

  echo -e "\e[1;33mDo you wish to check next subject(yes/no)?\e[0m"
  echo
  read next

  while ! [[ "$next" == "yes" || "$next" == "no" ]]
  do
    echo  -e "\e[0;35m\n '$next' is not a valid answer.\
  Please type a valid option: \e[0m""\e[3;35m(yes/no)\e[0m"
     sleep 0.5s
     echo
    echo -e "\e[1;33mDo you to next check next subject (yes/no)?\e[0m"
    echo
    read next
  done

  if [ "$next" == "yes" ]
  then
     clear
     echo " OK, I will open next subject!"
     unset next
     sleep 1
     clear
     continue

   elif [ "$next" == "no" ]
   then
     request_answers=1
     n=$(cat QC/QC_${database_name}.csv | grep -v ",Subject_ID," | wc -l)
     echo
  echo -e "\e[1;34m+++ GOOD!!You have completed\e[0m" \
  "\e[1;97m"$n" \e[0m""\e[1;34msubjects from this cohort.\n
Program exits now.!!!\e[0m"
   exit 0
  fi
# ---------------- Return to the begining of the questions ---------------------
elif [ "$confirmation" == "no" ]
then
  echo
  echo -e "\e[1;34m+++ OK THEN !!!! SO PLEASE RE-ENTER QC INFORMATION...\e[0m"

unset confirmation
echo $confirmation
sleep 1s
clear
fi

# -----------------------------------------------------------------------------
done # End of  confirmation while loop
fi # finishes if for $both_images
done # End of  subject iteraation for loop-------------------------------------

exit
