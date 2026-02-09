job_preamble() {
    # Help function
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        cat << EOF
job_preamble - Generate SLURM job script with VLPP environment

Usage:
  job_preamble                    Interactive mode with prompts
  job_preamble -n NAME -t TIME -m MEM -c CPUS [-o FILE]    Non-interactive mode
  job_preamble -h or --help       Show this help message

Flags:
  -n, --name     Job name (default: unnamed_job)
  -t, --time     Time limit (default: 1:30:00)
  -m, --mem      Memory per CPU in GB (default: 18)
  -c, --cpus     CPUs per task (default: 1)
  -o, --output   Output file (prints to terminal if not specified)

Examples:
  job_preamble                            # Interactive mode
  job_preamble -n myjob -t 2:00:00 -m 32 -c 4
  job_preamble -n analysis -t 4:00:00 -m 24 -c 2 -o job.sh
  job_preamble --name test --time 1:00:00 --mem 16 --cpus 1 --output run.sh

Output: Creates a complete job script with SBATCH directives and VLPP environment setup
EOF
        return 0
    fi
    
    local default_job="unnamed_job"
    local default_time="1:30:00"
    local default_mem="18"
    local default_cpus="1"
    local default_output=""  # Empty means print to terminal
    
    local job_name=""
    local time=""
    local mem=""
    local cpus=""
    local output_file=""
    local interactive=true
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                job_name="$2"
                interactive=false
                shift 2
                ;;
            -t|--time)
                time="$2"
                interactive=false
                shift 2
                ;;
            -m|--mem)
                mem="$2"
                interactive=false
                shift 2
                ;;
            -c|--cpus)
                cpus="$2"
                interactive=false
                shift 2
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use job_preamble -h for help"
                return 1
                ;;
        esac
    done
    
    # Interactive mode or fill missing values
    if [ "$interactive" = true ] || [ -z "$job_name" ]; then
        echo -n "Job name [${default_job}]: "
        read -r input_job
        job_name="${input_job:-${job_name:-$default_job}}"
    fi
    
    if [ "$interactive" = true ] || [ -z "$time" ]; then
        echo -n "Time [${default_time}]: "
        read -r input_time
        time="${input_time:-${time:-$default_time}}"
    fi
    
    if [ "$interactive" = true ] || [ -z "$mem" ]; then
        echo -n "Memory per CPU (GB) [${default_mem}]: "
        read -r input_mem
        mem="${input_mem:-${mem:-$default_mem}}"
    fi
    
    if [ "$interactive" = true ] || [ -z "$cpus" ]; then
        echo -n "CPUs per task [${default_cpus}]: "
        read -r input_cpus
        cpus="${input_cpus:-${cpus:-$default_cpus}}"
    fi
    
    # Only ask for output file in interactive mode if not already specified
    if [ "$interactive" = true ] && [ -z "$output_file" ]; then
        echo -n "Output file [press Enter to print to terminal]: "
        read -r input_output
        output_file="$input_output"
    fi
    
    # Apply defaults if still empty (for non-interactive mode)
    job_name="${job_name:-$default_job}"
    time="${time:-$default_time}"
    mem="${mem:-$default_mem}"
    cpus="${cpus:-$default_cpus}"
    
    # Create logs directory if it doesn't exist
    mkdir -p "${PWD}/logs"
    
    # Generate the preamble
    local preamble=$(cat << EOF
#!/bin/bash
#SBATCH --job-name=${job_name}
#SBATCH --nodes=1
#SBATCH --cpus-per-task=${cpus}
#SBATCH --mem-per-cpu=${mem}G
#SBATCH --time=${time}
#SBATCH --account=def-villens
#SBATCH --output=${PWD}/logs/%x-%j.out

module --force purge
module load StdEnv/2020 
export VL_QUARANTINE_DIR='/project/def-villens/quarantine'
source /project/def-villens/quarantine/scripts/vl_set_vlpp_env2020

EOF
)
    
    # Output to file or terminal
    if [ -n "$output_file" ]; then
        echo "$preamble" > "$output_file"
        echo "Job script created: $output_file"
    else
        echo "$preamble"
    fi
}
