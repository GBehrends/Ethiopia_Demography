#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=call_variant 
#SBATCH --partition=quanah
#SBATCH --nodes=1 --ntasks=8
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=2-17 

# Activate conda environment containing bcftools
. ~/conda/etc/profile.d/conda.sh
conda activate vcftools

# Define main working directory
workdir=/lustre/scratch/gbehrend/Demog_ETH

# Provide helper file with species, respective reference assemblies, and --max-depth threshold 
species=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/02_vcf/helper1.txt | tail -n1 )
max=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/02_vcf/helper2.txt | tail -n1 )
ref=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/02_vcf/helper3.txt | tail -n1 )

# Unzip the reference assembly 
# gunzip /lustre/work/gbehrend/demo_ref/${ref} 

# Run bcftools mpileup to call variants in the bam files
bcftools mpileup -f /lustre/work/gbehrend/demo_ref/${ref%*\.gz} ${workdir}/01_bam/${species}_final.bam \
--max-depth ${max} --skip-indels -q 20 -Ou | bcftools call -m -Oz -o ${workdir}/02_vcf/${species}.vcf.gz
 
# Gzip the reference assembly
gzip /lustre/work/gbehrend/demo_ref/${ref%*\.gz}
