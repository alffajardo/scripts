#!/bin/bash
skel=/misc/penfield/rcruces/database/epilepsia/tbss/stats/mean_FA_skeleton
var=`echo *corrp* | awk '{print $1}'`
if [ -f $var ]
	then 
		var=`echo *corrp*`
	else
		echo -e "\n\033[38;5;160m[ERROR]... There is no niiftis here :/\n\033[0m"
		exit 0
fi

for i in ${var}*; do
	max=`fslstats ${i} -R | awk '{print $2}'`
# Comparación de puntos flotantes en bash con AWK
	sig=`awk -v max=$max 'BEGIN { print (max >= 0.95) ? "YES" : "NO" }'`
	if [ "$sig" == "YES" ]
		then
    	echo -e "\n\033[38;5;75m[INFO] ...I found significative values in \033[38;5;45m${i}\033[0m \033[38;5;75mp=${max}, let's TRY:\033[1;33m"
	echo "fsleyes $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz  ${i} -cm red-yellow -dr 0.95 1 &
"
	fi
done
