#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=contig_assembly
#SBATCH --nodes=1 --ntasks=8
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-<number of samples> 


# Activate conda environment containing Phyluce-1.7.2  
. ~/conda/etc/profile.d/conda.sh
conda activate phyluce-1.7.2 

# Define the working directory 
workdir=/lustre/scratch/gbehrend/Demog_ETH/UCEs

# Establish array list 
sample=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/samplelist | tail -n1 )

# Make directory for spades outputs 
mkdir ${workdir}/contig_assembly/${sample}

# Make phyluce configuration file for the current sample 
echo "[samples]" > ${workdir}/contig_assembly/${sample}/${sample}.config
echo "${sample}:${workdir}/fastq_UCE/${sample}/" >> \
${workdir}/contig_assembly/${sample}/${sample}.config

#  Assemble UCE mapped reads into contigs 
phyluce_assembly_assemblo_spades \
    --conf ${workdir}/contig_assembly/${sample}/${sample}.config \
    --output ${workdir}/contig_assembly/${sample} \
    --cores 8

# Check quality of each assembly and store it in the assembly folder for the sample
phyluce_assembly_get_fasta_lengths \
--input ${workdir}/contig_assembly/${sample}/contigs/${sample}.contigs.fasta \
--csv > ${workdir}/contig_assembly/${sample}/${sample}_Assemb_Qual.csv


