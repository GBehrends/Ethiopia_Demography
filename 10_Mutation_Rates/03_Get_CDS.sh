#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=get_CDS
#SBATCH --partition=quanah
#SBATCH --nodes=1 --ntasks=2
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-3


# Define the working directory
workdir=/lustre/scratch/gbehrend/Demog_ETH/Mutation_Rates

# Define reference assembly and annotation file in slurm array
ref=$( cut -f1 ${workdir}/CDS_List.tsv | head -n${SLURM_ARRAY_TASK_ID} | tail -n1 )
gff=$( cut -f2 ${workdir}/CDS_List.tsv | head -n${SLURM_ARRAY_TASK_ID} | tail -n1 )


# Activate Conda environment containing gffread
. ~/conda/etc/profile.d/conda.sh
conda activate phyluce-1.7.2

# Use gffread to extract CDS regions from the reference assembly and create a BED file for
# those regions
gffread -g /lustre/work/gbehrend/demo_ref/CDS_Quartets/${ref} \
/lustre/work/gbehrend/demo_ref/CDS_Quartets/${gff} \
-C \
--bed \
-o ${workdir}/${ref%\.fna}.bed

# Isolate non-overlapping coding regions from bed file 
sort -k1,1 -k2,2n ${workdir}/${ref%\.fna}.bed > ${workdir}/${ref%\.fna}.bed.sorted
bedtools merge -i ${workdir}/${ref%\.fna}.bed.sorted -c 1 -o count > counted
awk '/\t1$/{print}' counted > filtered
bedtools intersect -a ${workdir}/${ref%\.fna}.bed.sorted  -b filtered -wa > \
${wokdir}/${ref%/.fna}_filtered.bed

# Remove intermediate files 
rm ${workdir}/${ref%\.fna}.bed.sorted
rm filtered
rm counted
