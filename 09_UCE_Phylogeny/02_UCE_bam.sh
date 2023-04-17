
#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=intersect
#SBATCH --nodes=1 --ntasks=8
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-<number of samples> 

# Activate conda environment containing samtools 
. ~/conda/etc/profile.d/conda.sh
conda activate samtools

# Define the working directory
workdir=<main working directory> 

# Establish array list
ref=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/UCEs/reflist.txt | tail -n1 )
sample=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/01_bam/samplelist | tail -n1 )

# Creating a bed file for each reference assembly's UCE probes 
grep ">" ${workdir}/reference_probes/${ref}_probes/${ref}.fasta | cut -f2,3 -d "|" | sed 's/contig://g' | \
sed 's/slice://g' | sed 's/|/\t/g' | sed 's/-/\t/g' | sed 's/Pseudo//g' | grep -v -e "Chromosome_W" -e \
"Chromosome_Z" > ${workdir}/reference_probes/${ref}.bed

# Using samtools to subset sample alignments to whole reference genomes by UCEs 
# found in the reference genome
mkdir -p ${workdir}/UCEs/bam_UCE/
samtools view -b -h -L ${workdir}/UCEs/reference_probes/${ref}.bed \
${workdir}/01_bam/${sample}_final.bam > ${workdir}/UCEs/bam_UCE/${sample}_UCE.bam

# Sort subsetted bam files 
samtools sort -n ${workdir}/UCEs/bam_UCE/${sample}_UCE.bam -o ${workdir}/UCEs/bam_UCE/${sample}_UCE.sorted.bam 

# Convert sorted bam files to fastq
samtools fastq --threads 8 ${workdir}/UCEs/bam_UCE/${sample}_UCE.sorted.bam \
-1 ${workdir}/UCEs/fastq_UCE/${sample}/${sample}_R1.fastq.gz \
-2 ${workdir}/UCEs/fastq_UCE/${sample}/${sample}_R2.fastq.gz \
-0 /dev/null -s /dev/null -n 

# rm intermediate sorted file 
rm ${workdir}/UCEs/bam_UCE/${sample}_UCE.sorted.bam 



