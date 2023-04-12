#!/bin/bash
echo ---------------------------
echo ---------------------------
echo
echo "++ STARTING..."
echo ...
echo ...
sleep 1s
module load VilleneuveLab

echo
echo "++ Checking for compulsory arguments..."
echo
sleep 1s



# Compulsory arguments. mak sure this is all correct before running the script
Subject_id=$1 # Subject ID
tracer=TAU
Normalized_data_dir=/project/ctb-villens/projects/PreventAD/pet_normalised_scaled_vlpp

work_dir=/project/ctb-villens/projects/PreventAD/pet_longitudinal_slopes
output_dir=${work_dir}/${tracer}_$(date +%Y_%m_%d)

date=$(date)
years=$(cat ${work_dir}/${tracer}_years.txt  | grep $Subject_id  | cut -d ' ' -f 2)

# Check for important directories to exist
mkdir -p $output_dir

if  [ ! -f "${work_dir}/${tracer}_years.txt"  ] ; then

echo -e "\e[0;31m++ Error:${work_dir}/${tracer}_years.txt NOT FOUND!\e[0m"
exit 1

# check for the existence of data dir
if  [ ! -d "${Normalized_data_dir}"  ] ; then

echo -e "\e[0;31m++ Error:${Normalized_data_dir} NOT FOUND!\e[0m"
exit 1

session1=$(find $Normalized_data_dir -name "2MNI_${Subject_id}_${tracer}_ses-01*.nii*" | cat | head -n 1)
session2=$(find $Normalized_data_dir -name "2MNI_${Subject_id}_${tracer}_ses-02*.nii*" | cat | head -n 1)

####

fi
echo -e  "\e[6;37m++ Summary:\e[0m"
echo -e "\e[3;37m++ Date: $date
++ Working directory: $work_dir
++ Tracer: $tracer
++ Subject ID: $Subject_id
++ PET Scan Session 1: $(basename $session1)
++ PET Scan Session 2: $(basename $session2)
++ Years between PET scan: $years
++ Output Directory: $output_dir\e[0m"

if    [  -z $session1   ]  ||  [  -z $session2 ] ; then
echo
echo -e  "\e[1;31m++ Error: Normalized file(s) for subject $Subject_id missing in working directory.\e[0m"
echo
exit 1
fi

# Generating Script
echo
echo -e "\e[1;38m++ Generating MATLAB job script...\e[0m"
echo

## line to avoid complict in the name of the matlab script since it cannot contain the "-" chararacter
suffix_name=$(echo $Subject_id | cut -d '-' -f 2 )


echo  "%-----------------------------------------------------------------------
% Job saved on $date by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.util.imcalc.input = {
                                        '$session1,1'
                                        '$session2,1'
                                        };
matlabbatch{1}.spm.util.imcalc.output = 'Rate_change_${Subject_id}_${tracer}_ref_infcereb';
matlabbatch{1}.spm.util.imcalc.outdir = {'$output_dir'};
matlabbatch{1}.spm.util.imcalc.expression = '(i2-i1)/$years';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
" > ${output_dir}/script_${suffix_name}.m

echo  "% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {'${output_dir}/script_${suffix_name}.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'PET');
spm_jobman('run', jobs, inputs{:});" > ${output_dir}/job_${tracer}_${suffix_name}.m





echo -e "\e[6;38m++ Script Saved!!!\e[0m"
sleep 2s 
echo
echo  -e "\e[0;38m++ Creating Slurm Script...\e[0m"


echo -e "#!/bin/bash
#SBATCH --job-name ${Subject_id}_${tracer}_slope
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --account=ctb-villens
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
​
module load VilleneuveLab
" >  ${output_dir}/${Subject_id}_${tracer}_slope.sbatch


echo matlab -batch \"run '('\'${output_dir}/job_${tracer}_${suffix_name}.m\'')'\" >>  ${output_dir}/${Subject_id}_${tracer}_slope.sbatch

sleep 1s 
echo
echo -e "\e[6;38m++ Sending Slurm script. WAIT..\e[0m"

sbatch   ${output_dir}/${Subject_id}_${tracer}_slope.sbatch

echo 
echo ++ Please Wait...
sleep 2s
squeue -u $USER
sleep 1s 


echo
echo ++ DONE! Check the output folder within few minutes.




exit 0

