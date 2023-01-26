#!/bin/bash 
#SBATCH --job-name=rename_chrom
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err
#SBATCH --partition=nocona
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --array=1

# Iterate through list of assembly prefixes
array=$( head -n${SLURM_ARRAY_TASK_ID} chrom_list.txt | tail -n1 )

# Unzip assembly
gunzip ${array}_genomic.fna.gz 

# Replace chromosome names with simpler list of names for uniformity amongst species 
while read n k; do sed -i "/$k/ c\>$n" ${array}_genomic.fna; done < ${array}_chrom_name.txt

# Rezip the assembly to save space
gzip ${array}_genomic.fna
