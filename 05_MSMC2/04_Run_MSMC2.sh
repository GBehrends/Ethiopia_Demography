#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=msmc2
#SBATCH --nodes=1 --ntasks=2
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH --array=1-<number of samples> 

# Establish the working directory
workdir=? 

# Establish input file
input_array=$( head -n${SLURM_ARRAY_TASK_ID} helper1.txt | tail -n1 )

# Establish output file
output_array=$( head -n${SLURM_ARRAY_TASK_ID} helper2.txt | tail -n1 )

# Run MSMC2 
/lustre/scratch/gbehrend/EthiopianBirdsProject/MSMC2/msmc-tools/msmc2_linux64bit -I 0,1 -o ${output_array}  -i 20 -t 2 -p 1*2+20*1+1*2+1*3 ${input_array} 
