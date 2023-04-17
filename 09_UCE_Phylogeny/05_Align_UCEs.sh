#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=muscle_align
#SBATCH --nodes=1 --ntasks=4
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-1000 

# Activate environment containing MUSCLE and Phyluce-1.7.2
. ~/conda/etc/profile.d/conda.sh
conda activate phyluce-1.7.2

# Define the working directory
workdir=/lustre/scratch/gbehrend/Demog_ETH/UCEs

# Set the number of runs that each SLURM task should do
RUNS="$(wc -l < ${workdir}/final_UCEs/UCE_list.txt)"
PER_TASK="$(expr ${RUNS} / 1000 + 1)"

# Calculate the starting and ending values for this task based
# on the SLURM task and the number of runs per task.
START_NUM=$(( ($SLURM_ARRAY_TASK_ID - 1) * $PER_TASK + 1 ))
END_NUM=$(( $SLURM_ARRAY_TASK_ID * $PER_TASK ))

# Run the loop of runs for this task.
for (( run=$START_NUM; run<=$END_NUM; run++ )); do
        echo This is SLURM task $SLURM_ARRAY_TASK_ID, run number $run

        uce=$( head -n${run} ${workdir}/final_UCEs/UCE_list.txt | tail -n1 )

        # Gather UCE fasta entry from each species and place it in a multispecies fasta for
        # that UCE
        for i in $(cat ${workdir}/samplelist); do
                sed -n -e "/>uce-${uce}_/,/>/ p" ${workdir}/final_UCEs/${i}/${i}_incomplete.fasta \
                | sed '2,${/^>.*/d;}' | sed "s/uce-${uce}_//g" |  sed "s/|uce-${uce}//g" >> \
                ${workdir}/final_UCEs/${uce}_all.fasta; done

        # Count number of species in samplelist and number of sequences in the multispecies
        # UCE fasta
        samples="$( wc -l < samplelist )"
        entries="$( grep ">" ${workdir}/final_UCEs/${uce}_all.fasta | wc -l )"

        # If all species are present, create an alignment with the multispecies UCE fasta
                if((${samples} == ${entries}));
                then muscle -align ${workdir}/final_UCEs/${uce}_all.fasta \
                -output ${workdir}/final_UCEs/${uce}.afa;
                rm ${workdir}/final_UCEs/${uce}_all.fasta;

                # If all species are not present, delete the fasta
                else rm ${workdir}/final_UCEs/${uce}_all.fasta;
                echo "${uce}_all.fasta contained only ${entries} species";
        fi;

done
        
