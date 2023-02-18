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
workdir=/lustre/scratch/gbehrend/Demog_ETH

# define input files from helper file during genotyping
sample=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/msmc/vcf/helper1.txt | tail -n1 )
depth=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/msmc/vcf/helper2.txt | tail -n1 )

# Make species sample directory to place all chromosome vcfs into 
mkdir ${workdir}/msmc/vcf/${sample} 

# Filter species sample vcf for MSMC2 and simplify it to contain the desired columns 
vcftools --gzvcf ${workdir}/02_vcf/${sample}.vcf.gz --minDP 6 --maxDP ${depth} --max-missing 1 --max-alleles 2  --remove-indels --recode --recode-INFO-all -c | bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%GT]\n ' > ${workdir}/msmc/vcf/${sample}/${sample}.simple.vcf

# Establish list of chromosomes inside of species sample vcf 
cut -f1 ${workdir}/msmc/vcf/${sample}/${sample}.simple.vcf | sort | uniq > ${workdir}/msmc/vcf/${sample}/chrom_list.txt

# Make chromosomal vcfs 
for i in $(cat ${workdir}/msmc/vcf/${sample}/chrom_list.txt); do grep "${i}" ${workdir}/msmc/vcf/${sample}/${sample}.simple.vcf | cut -f2,3,4,5 >  ${workdir}/msmc/vcf/${sample}/${i}.vcf ; done 

# Create directory to store vcfs that will not be included in further analyses 
mkdir ${workdir}/msmc/vcf/${sample}/excluded_chrom

# Include only vcfs > 1Mbp
for i in $(cat ${workdir}/msmc/vcf/${sample}/chrom_list.txt); do if (("$(tail -n 1 ${workdir}/msmc/vcf/${sample}/${i}.vcf | cut -f1)" < 100000)); then mv ${workdir}/msmc/vcf/${sample}/${i}.vcf ${workdir}/msmc/vcf/${sample}/excluded_chrom/${i}.vcf; fi; done

# Move Sex Chromosomes to excluded folder
for i in W Z; do mv ${workdir}/msmc/vcf/${sample}/Chromosome_${i}.vcf ${workdir}/msmc/vcf/${sample}/excluded_chrom/Chromosome_${i}.vcf; done 

# Move whole species vcf to excluded folder as well 
mv ${workdir}/msmc/vcf/${sample}/${sample}.simple.vcf  ${workdir}/msmc/vcf/${sample}/excluded_chrom/${sample}.simple.vcf 

# Gzip the excluded chromosomes to save space 
for i in $(ls ${workdir}/msmc/vcf/${sample}/excluded_chrom); do gzip ${workdir}/msmc/vcf/${sample}/excluded_chrom/${i}; done 
