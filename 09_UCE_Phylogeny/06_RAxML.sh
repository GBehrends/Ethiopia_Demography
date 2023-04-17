#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=RAxML
#SBATCH --nodes=1 --ntasks=6
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=2-1000


# Activate environment containing trimal 
. ~/conda/etc/profile.d/conda.sh
conda activate phyluce-1.7.2

# Define the working directory
workdir=<main working directory> 

# Set the number of runs that each SLURM task should do by counting the number of output 
# alignment files 
RUNS="$(ls ${workdir}/final_UCEs/*afa | wc -l )"
PER_TASK="$(expr ${RUNS} / 1000 + 1)"

# Calculate the starting and ending values for this task based
# on the SLURM task and the number of runs per task.
START_NUM=$(( ($SLURM_ARRAY_TASK_ID - 1) * $PER_TASK + 1 ))
END_NUM=$(( $SLURM_ARRAY_TASK_ID * $PER_TASK ))

# Run the loop of runs for this task.
for (( run=$START_NUM; run<=$END_NUM; run++ )); do
        echo This is SLURM task $SLURM_ARRAY_TASK_ID, run number $run

        uce=$( head -n${run} ${workdir}/alignment_list.txt  | tail -n1 )
        
        # Use trimal to remove sites in alignments with >20% missing sequences. 
        trimal -in ${workdir}/final_UCEs/${uce}.afa \
        -gt 0.8 -out ${workdir}/final_UCEs/${uce}.fasta;
        
        # Run RAxML on the trimmed alignment 
        raxmlHPC-PTHREADS-SSE3 -T 6 -f a -x 150 \
        -m GTRCAT -p 253 -N 10 -s ${workdir}/final_UCEs/${uce}.fasta \
        -n ${uce}.tre -w ${workdir}/trees/;
done 


