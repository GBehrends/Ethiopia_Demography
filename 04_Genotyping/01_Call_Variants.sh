#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=call_variant
#SBATCH --partition=quanah
#SBATCH --nodes=1 --ntasks=8
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-?

# Activate conda environment containing bcftools
. ~/conda/etc/profile.d/conda.sh
conda activate vcftools

# Define main working directory
workdir=<working directory> 
refdir=<reference directory>

# Provide helper file with species, respective reference assemblies, and --max-depth threshold
species=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/02_vcf/helper1.txt | tail -n1 ) # species prefix list
max=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/02_vcf/helper2.txt | tail -n1 ) # --max-depth filter list 
ref=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/02_vcf/helper3.txt | tail -n1 ) # reference assembly list 

# Unzip the reference assembly
gunzip ${refdir}/${ref}

# Run bcftools mpileup to call variants in the bam files
bcftools mpileup -f ${refdir}/${ref%*\.gz} ${workdir}/01_bam/${species}_final.bam \
--max-depth ${max} -q 20 -Ou | bcftools call -m -Oz -o ${workdir}/02_vcf/${species}.vcf.gz

# Gzip the reference assembly
gzip ${refdir}/${ref%*\.gz}
