#!/bin/bash
#SBATCH --job-name=msmc_to_vcf
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err
#SBATCH --partition=nocona
#SBATCH --nodes=1
#SBATCH --ntasks=18
#SBATCH --array=1-?

module load gcc/10.1.0
module load r/4.0.2

# Set working directory
workdir=? 

# Array to go through all six species
array=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/samplelist | tail -n1 )


sed "s/sample/${array}/g" ${workdir}/vcf_to_msmc.r > ${workdir}/${array}_msmc.r

Rscript ${workdir}/${array}_msmc.r
