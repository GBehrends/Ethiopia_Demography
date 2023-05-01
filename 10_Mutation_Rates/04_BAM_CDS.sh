#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=get_CDS
#SBATCH --partition=quanah
#SBATCH --nodes=1 --ntasks=8
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=3-21,23

# Activate environment containing samtools 
. ~/conda/etc/profile.d/conda.sh 
conda activate samtools 

# Define the working directory 
workdir=/lustre/scratch/gbehrend/Demog_ETH/Mutation_Rates

# Determine reference assembly for coding regions and corresponding species in array 
ref=$( cut -f2 ${workdir}/Alignment_List.txt | head -n${SLURM_ARRAY_TASK_ID} | tail -n1 )
species=$( cut -f1 ${workdir}/Alignment_List.txt | head -n${SLURM_ARRAY_TASK_ID} | tail -n1 )

# Extract coding regions from the species bam files using samtools 
samtools view -b -h -L ${workdir}/${ref%\.fna}_filtered.bed ${workdir}/bam/${species}_final.bam > \
${workdir}/CDS/${species}_CDS.bam

# Go into the working directory 
cd ${workdir}/CDS

# Sort subsetted bam files and convert them to fastq
samtools sort -n ${workdir}/CDS/${species}_CDS.bam -o ${workdir}/CDS/${species}_sorted.bam

# Convert the sorted bam file to fastqs
samtools fastq ${workdir}/CDS/${species}_sorted.bam \
--threads 8 \
-1 ${workdir}/CDS/${species}_R1.fastq.gz \
-2 ${workdir}/CDS/${species}_R2.fastq.gz \
-0 /dev/null -s /dev/null -n 

# Remove the subsetted bam file 
rm ${workdir}/CDS/${species}_CDS.bam

