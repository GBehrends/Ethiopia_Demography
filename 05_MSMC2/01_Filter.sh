#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=cat_vcf  
#SBATCH --nodes=1 --ntasks=4
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-?

# Load environment 
. ~/conda/etc/profile.d/conda.sh
conda activate vcftools 

# Define the working directory 
workdir=? 

# define input files from helper file during genotyping
sample=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/msmc/vcf/helper1.txt | tail -n1 )
depth=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/msmc/vcf/helper2.txt | tail -n1 )

# Filter using vcftools
vcftools --gzvcf ${workdir}/02_vcf/${sample}.vcf.gz --minDP 6 --maxDP ${depth} --max-missing 1 --max-alleles 2 \
--remove-indels --recode --recode-INFO-all --out ${workdir}/03_vcf/${sample}