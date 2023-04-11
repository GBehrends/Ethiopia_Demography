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
sample=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/02_vcf/samplelist | tail -n1 )
depth=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/02_vcf/depthlist | tail -n1 )

# Filter using vcftools
vcftools --gzvcf ${workdir}/02_vcf/${sample}.vcf.gz --minDP 6 --maxDP ${depth} --max-missing 1 --max-alleles 2 \
--remove-indels --recode --recode-INFO-all --out ${workdir}/03_vcf/${sample}

# Establish list of chromosomes inside of species sample vcf 
grep -v "#" ${workdir}/03_vcf/${sample}.recode.vcf | cut -f1  | sed 's/ //g' | sort | uniq > ${workdir}/03_vcf/${sample}_chrom_list.txt

# Create helper file with sample name to pair with the chromlist
for i in $(cat ${workdir}/03_vcf/${sample}_chrom_list.txt); do echo ${sample} >> ${workdir}/03_vcf/${sample}_samp_list.txt; done 
