#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=Ts/Tv
#SBATCH --nodes=1 --ntasks=12
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-?


# activate conda environment with vcftools 
. ~/conda/etc/profile.d/conda.sh
conda activate vcftools

# Define the working directory 
workdir=?

# Define array list 
sample=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/ROHan/samplelist.txt | tail -n1 )

vcftools --gzvcf ${workdir}/02_vcf/${sample}.vcf.gz --TsTv-summary --out ${workdir}/ROHan/${sample}
