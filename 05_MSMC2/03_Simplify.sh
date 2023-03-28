#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=simp_vcf 
#SBATCH --nodes=1 --ntasks=1
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-?


# Define the working directory 
workdir=/lustre/scratch/gbehrend/Demog_ETH

# Activate environment containing bcftools 
. ~/conda/etc/profile.d/conda.sh
conda activate vcftools

# Define array list 
sample=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/01_bam/samplelist | tail -n1 )

# Make directory for simplified scaffolds
mkdir ${workdir}/msmc/vcf/${sample}

# Sort and simplify VCF to the fields needed for MSMC2
for i in $(ls ${workdir}/03_vcf/${sample}_Scaffolds | grep "vcf" | grep -v "filtered"); do
bcftools sort ${workdir}/03_vcf/${sample}_Scaffolds/${i} -o ${workdir}/03_vcf/${sample}_Scaffolds/${i%\.vcf}.sorted.vcf;
bcftools query -f '%POS\t%REF\t%ALT[\t%GT]\n ' ${workdir}/03_vcf/${sample}_Scaffolds/${i} -o ${workdir}/03_vcf/${sample}_Scaffolds/${i%\.vcf}.simple.vcf;

# Remove intermediary sorted VCF file
rm ${workdir}/03_vcf/${sample}_Scaffolds/${i%\.vcf}.sorted.vcf;

# Remove spaces inserted in simplified VCF by bcftools 
sed -i 's/ //g' ${workdir}/03_vcf/${sample}_Scaffolds/${i%\.vcf}.simple.vcf;

# Move simplified VCF to MSMC2 directory
mv ${workdir}/03_vcf/${sample}_Scaffolds/${i%\.vcf}.simple.vcf ${workdir}/msmc/vcf/${sample}/${i%\.vcf}.simple.vcf;  done 
