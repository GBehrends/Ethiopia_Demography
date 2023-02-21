#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=filt_vcf 
#SBATCH --nodes=1 --ntasks=12
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-17

# activate conda environment with vcftools 
. ~/conda/etc/profile.d/conda.sh
conda activate vcftools

# Define the working directory 
workdir=?

# define input file prefixes from helper file during genotyping
sample=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/msmc/vcf/samplelist.txt | tail -n1 )

# define the max depth of coverage threshold for each sample in a list  
depth=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/msmc/vcf/depthlist.txt | tail -n1 )

# Make species sample directory to place all chromosome vcfs into 
mkdir ${workdir}/msmc/vcf/${sample} 

# Filter species sample vcf for MSMC2 and simplify it to contain the desired columns 
vcftools --gzvcf ${workdir}/02_vcf/${sample}.vcf.gz --minDP 6 --maxDP ${depth} --max-missing 1 --max-alleles 2  --remove-indels --recode --recode-INFO-all -c | bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%GT]\n ' > ${workdir}/msmc/vcf/${sample}/${sample}.simple.vcf

# Establish list of chromosomes inside of species sample vcf 
cut -f1 ${workdir}/msmc/vcf/${sample}/${sample}.simple.vcf | sed 's/ //g' | sort | uniq > ${workdir}/msmc/vcf/${sample}/chrom_list.txt

# Create helper file with sample name to pair with the chromlist
for i in $(cat ${workdir}/msmc/vcf/${sample}/chrom_list.txt); do echo ${sample} >> ${workdir}/msmc/vcf/${sample}/samp_list.txt; done 

# Create directory to store vcfs that will not be included in further analyses 
mkdir ${workdir}/msmc/vcf/${sample}/excluded_chrom
