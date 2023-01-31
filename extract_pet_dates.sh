#!/bin/bash


# Script intended to extract the dates and converted it to the right format as requested in the QC file for the PREVENT-AD PET scans. 


# Extract the dates

# Arguments

subject_id=$1
tracer='NAV'
session='ses-01'






dates=$(ls *NAV*ses-01*| rev | cut -d _ -f 1 | rev)

# Fix the dates the old school

fixed_dates=$(echo $dates | sed "s/Jan/-01-/g" |     sed "s/Feb/-02-/g" |  sed "s/Mar/-03-/g" |    sed "s/Apr/-04-/g" |      sed "s/May/-05-/g" | sed "s/Jun/-06-/g" | sed "s/Jul/-07-/g" |     sed "s/Aug/-08-/g" |     sed "s/Sep/-09-/g" |     sed "s/Oct/-10-/g" |   sed "s/Nov/-11-/g" |sed "s/Dec/-12-/g")

for d in $fixed_dates
do
day=$(echo $d | cut -d '-' -f 1)
month=$(echo $d | cut -d '-' -f 2)
year=$(echo $d | cut -d '-' -f 3)

echo $year-$month-$day

done


exit
