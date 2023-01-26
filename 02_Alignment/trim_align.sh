#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=make_bam
#SBATCH --partition=quanah
#SBATCH --nodes=1 --ntasks=12
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-?

module load intel java bwa samtools singularity

export SINGULARITY_CACHEDIR="<singularity direactory>/singularity-cachedir"

# define main working directory
workdir=?

# provide list of species reads files and their respective reference assembly that they'll be aligned to
species=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/01_bam/samplelist | tail -n1 )
ref=$(head -n${SLURM_ARRAY_TASK_ID} ${workdir}/01_bam/speciesref | tail -n1 )

# unzip reference assembly
gunzip <path to reference assembly directory>/${ref}

# Replace characters that won't be accepted when converting sam to bam format. There might be others, check the log files to be sure
# if it doesn't convert sam to bam later. 
sed -i 's/:/ /g' /lustre/work/gbehrend/demo_ref/${ref%*\.gz}
sed -i 's/_/ /g' /lustre/work/gbehrend/demo_ref/${ref%*\.gz}
sed -i 's/Chromosome /Chromosome_/g' /lustre/work/gbehrend/demo_ref/${ref%*\.gz}
sed -i 's/Superscaffold /Superscaffold_/g' /lustre/work/gbehrend/demo_ref/${ref%*\.gz}

# Index the reference assemblies  
samtools faidx -f <path to reference assembly directory>/${ref%*\.gz} -o <path to reference assembly directory>/${ref%*\.gz}
bwa index <path to reference assembly directory>/${ref%*\.gz}

# run bbduk (Quality trim left and right of read, minimum kmer length to cover ends of reads is 7, kmer size if 25, quality threshold to trim set to phred score of 10, and trim the leftmost 10 bases)
bbduk.sh in1=${workdir}/00_fastq/${species}_R1.fastq.gz in2=${workdir}/00_fastq/${species}_R2.fastq.gz out1=${workdir}/01_cleaned/${species}_R1.fastq.gz out2=${workdir}/01_cleaned/${species}_R2.fastq.gz minlen=50 ftl=10 qtrim=rl trimq=10 ktrim=r k=25 mink=7 ref=/lustre/work/jmanthey/bbmap/resources/adapters.fa hdist=1 tbo tpe

# run bwa mem
bwa mem -t 12 <path to reference assembly directory>/${ref%*\.gz} ${workdir}/01_cleaned/${species}_R1.fastq.gz ${workdir}/01_cleaned/${species}_R2.fastq.gz > ${workdir}/01_bam/${species}.sam

# convert sam to bam
samtools view -b -S -o ${workdir}/01_bam/${species}.bam ${workdir}/01_bam/${species}.sam

# remove sam
${workdir}/01_bam/${species}.sam

# clean up the bam file
singularity exec $SINGULARITY_CACHEDIR/gatk_4.2.3.0.sif gatk CleanSam -I ${workdir}/01_bam/${species}.bam -O ${workdir}/01_bam/${species}_cleaned.bam

# remove the raw bam
rm ${workdir}/01_bam/${species}.bam

# sort the cleaned bam file
singularity exec $SINGULARITY_CACHEDIR/gatk_4.2.3.0.sif gatk SortSam -I ${workdir}/01_bam/${species}_cleaned.bam -O ${workdir}/01_bam/${species}_cleaned_sorted.bam --SORT_ORDER coordinate

# remove the cleaned bam file
rm ${workdir}/01_bam/${species}_cleaned.bam

# add read groups to sorted and cleaned bam file
singularity exec $SINGULARITY_CACHEDIR/gatk_4.2.3.0.sif gatk AddOrReplaceReadGroups -I ${workdir}/01_bam/${species}_cleaned_sorted.bam -O ${workdir}/01_bam/${species}_cleaned_sorted_rg.bam --RGLB 1 --RGPL illumina --RGPU unit1 --RGSM ${species}

# remove cleaned and sorted bam file
rm ${workdir}/01_bam/${species}_cleaned_sorted.bam

# remove duplicates to sorted, cleaned, and read grouped bam file (creates final bam file)
singularity exec $SINGULARITY_CACHEDIR/gatk_4.2.3.0.sif gatk MarkDuplicates --REMOVE_DUPLICATES true --MAX_FILE_HANDLES_FOR_READ_ENDS_MAP 100 -M ${workdir}/01_bam/${species}_markdups_metric_file.txt -I ${workdir}/01_bam/${species}_cleaned_sorted_rg.bam -O ${workdir}/01_bam/${species}_final.bam

# remove sorted, cleaned, and read grouped bam file
rm ${workdir}/01_bam/${species}_cleaned_sorted_rg.bam

# index the final bam file
samtools index ${workdir}/01_bam/${species}_final.bam

# Gzip the reference assembly
gzip <path to reference assembly directory>/${ref%*\.gz}

