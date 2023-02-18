#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=cat_vcf  
#SBATCH --nodes=1 --ntasks=4
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=2-17


# Define the working directory 
workdir=/lustre/scratch/gbehrend/Demog_ETH

# define input files from helper file during genotyping
sample=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/msmc/vcf/helper1.txt | tail -n1 )

# Cat vcfs that were large enough to be kept; They will be used to calculate heterozygosity.
# Also add sex chromosomes to assess their impact on heterozygosity.  
for i in $(ls ${workdir}/msmc/vcf/${sample}/*vcf); do 
cat ${i} >> ${workdir}/het/${sample}.vcf; done

zcat ${workdir}/msmc/vcf/${sample}/excluded_chrom/Chromosome_W.vcf.gz >> ${workdir}/het/${sample}.vcf
zcat ${workdir}/msmc/vcf/${sample}/excluded_chrom/Chromosome_Z.vcf.gz >> ${workdir}/het/${sample}.vcf
zcat ${workdir}/msmc/vcf/${sample}/excluded_chrom/PseudoChromosome_W.vcf.gz >> ${workdir}/het/${sample}.vcf
zcat ${workdir}/msmc/vcf/${sample}/excluded_chrom/PseudoChromosome_Z.vcf.gz >> ${workdir}/het/${sample}.vcf

