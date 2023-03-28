#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=Ts/Tv
#SBATCH --nodes=1 --ntasks=12
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=2-17


# activate conda environment with vcftools 
. ~/conda/etc/profile.d/conda.sh
conda activate vcftools

# Define the working directory 
workdir=/lustre/scratch/gbehrend/Demog_ETH/

# Define array list 
sample=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/msmc/vcf/helper1.txt | tail -n1 )

# Calculate the TS/TV ratio on VCFs containing scaffolds that passed the ≥1MBP size filtering
vcftools --vcf ${workdir}/het/${sample}.het.vcf --TsTv-summary --out ${workdir}/ROHan/${sample}
