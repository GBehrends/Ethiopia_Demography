#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=make_bam
#SBATCH --partition=quanah
#SBATCH --nodes=1 --ntasks=12
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=6

module load intel java bwa samtools singularity

export SINGULARITY_CACHEDIR="/lustre/work/gbehrend/singularity-cachedir"

# define main working directory
workdir=/lustre/scratch/gbehrend/Demog_ETH

# provide list of species reads files and their respective reference assembly that they'll be aligned to
species=$( cut -f1 ${workdir}/Mutation_Rates/Alignment_List.txt | head -n${SLURM_ARRAY_TASK_ID} | tail -n1 )
ref=$( cut -f2 ${workdir}/Mutation_Rates/Alignment_List.txt | head -n${SLURM_ARRAY_TASK_ID} | tail -n1 )

# run bbduk (Quality trim left and right of read, minimum kmer length to cover ends of reads is 7, kmer size if 25, quality threshold to trim set to phred score of 10, and trim the leftmost 10 bases)
/lustre/work/jmanthey/bbmap/bbduk.sh in1=${workdir}/00_fastq/${species}_R1.fastq.gz in2=${workdir}/00_fastq/${species}_R2.fastq.gz out1=${workdir}/Mutation_Rates/cleaned_fastq/${species}_R1.fastq.gz out2=${workdir}/Mutation_Rates/cleaned_fastq/${species}_R2.fastq.gz minlen=50 ftl=10 qtrim=rl trimq=10 ktrim=r k=25 mink=7 ref=/lustre/work/jmanthey/bbmap/resources/adapters.fa hdist=1 tbo tpe

# run bwa mem
bwa mem -t 12 /lustre/work/gbehrend/demo_ref/${ref} ${workdir}/Mutation_Rates/cleaned_fastq/${species}_R1.fastq.gz ${workdir}/Mutation_Rates/cleaned_fastq/${species}_R2.fastq.gz > ${workdir}/Mutation_Rates/bam/${species}.sam

# convert sam to bam
samtools view -b -S -o ${workdir}/Mutation_Rates/bam/${species}.bam ${workdir}/Mutation_Rates/bam/${species}.sam

# remove sam
rm ${workdir}/Mutation_Rates/bam/${species}.sam

# clean up the bam file
singularity exec $SINGULARITY_CACHEDIR/gatk_4.2.3.0.sif gatk CleanSam -I ${workdir}/Mutation_Rates/bam/${species}.bam -O ${workdir}/Mutation_Rates/bam/${species}_cleaned.bam

# remove the raw bam
rm ${workdir}/Mutation_Rates/bam/${species}.bam

# sort the cleaned bam file
singularity exec $SINGULARITY_CACHEDIR/gatk_4.2.3.0.sif gatk SortSam -I ${workdir}/Mutation_Rates/bam/${species}_cleaned.bam -O ${workdir}/Mutation_Rates/bam/${species}_cleaned_sorted.bam --SORT_ORDER coordinate

# remove the cleaned bam file
rm ${workdir}/Mutation_Rates/bam/${species}_cleaned.bam

# add read groups to sorted and cleaned bam file
singularity exec $SINGULARITY_CACHEDIR/gatk_4.2.3.0.sif gatk AddOrReplaceReadGroups -I ${workdir}/Mutation_Rates/bam/${species}_cleaned_sorted.bam -O ${workdir}/Mutation_Rates/bam/${species}_cleaned_sorted_rg.bam --RGLB 1 --RGPL illumina --RGPU unit1 --RGSM ${species}

# remove cleaned and sorted bam file
rm ${workdir}/Mutation_Rates/bam/${species}_cleaned_sorted.bam

# remove duplicates to sorted, cleaned, and read grouped bam file (creates final bam file)
singularity exec $SINGULARITY_CACHEDIR/gatk_4.2.3.0.sif gatk MarkDuplicates --REMOVE_DUPLICATES true --MAX_FILE_HANDLES_FOR_READ_ENDS_MAP 100 -M ${workdir}/Mutation_Rates/bam/${species}_markdups_metric_file.txt -I ${workdir}/Mutation_Rates/bam/${species}_cleaned_sorted_rg.bam -O ${workdir}/Mutation_Rates/bam/${species}_final.bam

# remove sorted, cleaned, and read grouped bam file
rm ${workdir}/Mutation_Rates/bam/${species}_cleaned_sorted_rg.bam

# index the final bam file
samtools index ${workdir}/Mutation_Rates/bam/${species}_final.bam

# Gzip the reference assembly
gzip /lustre/work/gbehrend/demo_ref/${ref}
