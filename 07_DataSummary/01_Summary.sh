#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=summary
#SBATCH --nodes=1 --ntasks=2
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1

# activate conda environment with vcftools 
. ~/conda/etc/profile.d/conda.sh
conda activate samtools

# Define the working directory and directory to place data set summary  
workdir=<workdir>
outdir=${workdir}/summary 

# define input files from helper file during genotyping
sample=$( head -n${SLURM_ARRAY_TASK_ID} ${outdir}/helper1.txt | tail -n1 )

# Raw read and base counts from slurm outputs during trim_align.sh step
grep "Input:" ${workdir}/01_bam/slurm-*_${SLURM_ARRAY_TASK_ID}.out | cut -f2 | sed 's/ reads //g' >> ${outdir}/reads
grep "Input:" ${workdir}/01_bam/slurm-*_${SLURM_ARRAY_TASK_ID}.out | cut -f4 |sed 's/ bases\.//g' >> ${outdir}/bases  

# Mapped reads counted from bam outputs 
samtools view -c ${workdir}/01_bam/${sample}_final.bam >> ${outdir}/mapped_reads

# Proportion of reads mapped
r=$(sed "${SLURM_ARRAY_TASK_ID}p" ${outdir}/reads)
m=$(sed "${SLURM_ARRAY_TASK_ID}p" ${outdir}/mapped_reads)
echo "scale=10; $m / $r" | bc  > ${outdir}/${sample}_out
grep "\." ${sample}_out | uniq >> proportion_mapped
rm ${sample}_out

# Sites genotyped after filtering 
zcat ${workdir}/msmc/vcf/${sample}/excluded_chrom/${sample}.simple.vcf.gz | wc -l >> ${outdir}/sites_kept
