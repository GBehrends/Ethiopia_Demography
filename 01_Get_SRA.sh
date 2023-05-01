#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=get_sra 
#SBATCH --nodes=1 --ntasks=6
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=3


# Define the working directory 
workdir=/lustre/scratch/gbehrend/Demog_ETH

# Define the slurm array variable
sra=$( cut -f2 ${workdir}/Mutation_Rates/Quartet_Species_SRA.tsv | head -n${SLURM_ARRAY_TASK_ID} | tail -n1 )
species=$( cut -f1 ${workdir}/Mutation_Rates/Quartet_Species_SRA.tsv | head -n${SLURM_ARRAY_TASK_ID} | tail -n1 )

# Downloading SRAs from list 
/lustre/work/gbehrend/sratoolkit.3.0.1-centos_linux64/bin/fastq-dump-orig.3.0.1 \
 --accession ${sra} --gzip --split-files --outdir ${workdir}/00_fastq

# Renaming the SRA fastqs
mv ${workdir}/00_fastq/${sra}_1.fastq.gz ${workdir}/00_fastq/${species}_R1.fastq.gz
mv ${workdir}/00_fastq/${sra}_2.fastq.gz ${workdir}/00_fastq/${species}_R2.fastq.gz
