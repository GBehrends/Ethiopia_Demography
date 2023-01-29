#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=filt_vcf 
#SBATCH --nodes=1 --ntasks=12
#SBATCH --partition quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-?


# activate conda environment with vcftools 
. ~/conda/etc/profile.d/conda.sh
conda activate vcftools

# define input files from helper file during genotyping
input_array=$( head -n${SLURM_ARRAY_TASK_ID} helper1.txt | tail -n1 )

# define main working directory
workdir=<working directory>

# Filter for MSMC and observed heterozygosity
vcftools --gzvcf ${workdir}/02_vcf/${input_array}.vcf.gz  --max-missing 1 --max-alleles 2  --max-maf 0.49 --remove-indels --recode --recode-INFO-all --out ${workdir}/het_vcf/${input_array}
