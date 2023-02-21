#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=cat_vcf  
#SBATCH --nodes=1 --ntasks=4
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-17


# Define the working directory 
workdir=?

# define input files from helper file during genotyping
sample=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/het/samplelist.txt | tail -n1 )

# Cat large enough vcfs to make a vcf without sex chromosomes
for i in $(ls ${workdir}/msmc/vcf/${sample}/*vcf | grep -v "Chromosome_Z" | grep -v "Chromosome_W"); do 
cat ${i} >> ${workdir}/het/${sample}.vcf; done

# Add sex chromosomes and make a different file
for i in Z W; do 

# If sex chromosomes were too small and gzipped 
zcat ${workdir}/msmc/vcf/${sample}/excluded_chrom/Chromosome_${i}.vcf.gz >> ${workdir}/msmc/vcf/${sample}/${sample}_sex.vcf;
zcat ${workdir}/msmc/vcf/${sample}/excluded_chrom/PseudoChromosome_${i}.vcf.gz >> ${workdir}/msmc/vcf/${sample}/${sample}_sex.vcf; 

# If sex chromosomes were not too small and were kept 
cat ${workdir}/msmc/vcf/${sample}/Chromosome_${i}.vcf >> ${workdir}/msmc/vcf/${sample}/${sample}_sex.vcf;
cat ${workdir}/msmc/vcf/${sample}/PseudoChromosome_${i}.vcf >> ${workdir}/msmc/vcf/${sample}/${sample}_sex.vcf; done

cat ${workdir}/msmc/vcf/${sample}/${sample}_sex.vcf ${workdir}/het/${sample}.vcf > ${workdir}/het/${sample}_sex.vcf

# Remove concatenated sex chromosome file 
rm ${workdir}/msmc/vcf/${sample}/${sample}_sex.vcf

