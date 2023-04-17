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

# Assemble contigs from reads that only mapped to UCE regions during the whole genome 
# mapping with BWA mem  
phyluce_assembly_assemblo_spades \
    --conf ${workdir}/contig_assembly/${sample}/${sample}.config \
    --output ${workdir}/contig_assembly/${sample} \
    --cores 8
    
# Check quality of each assembly and store it in the assembly folder for the sample
phyluce_assembly_get_fasta_lengths \
    --input ${workdir}/contig_assembly/${sample}/contigs/${sample}.contigs.fasta \
    --csv > ${workdir}/contig_assembly/${sample}/${sample}_Assemb_Qual.csv

# Make directory for final UCE outputs 
mkdir -p ${workdir}/final_UCEs/${sample}/

# Match contigs to the same tetrapod UCE probes used to extract UCE sequences from each
# reference assembly in the 02_Extract_UCE.sh script 
phyluce_assembly_match_contigs_to_probes \
   --contigs contig_assembly/${sample}/contigs/ \
   --probes ${workdir}/reference_probes/uce-5k-probes.fasta \
   --output ${workdir}/final_UCEs/${sample}/

# Get contig counts  
echo "[all]" > ${workdir}/final_UCEs/${sample}/taxon-set.config 
echo "${sample}" >> ${workdir}/final_UCEs/${sample}/taxon-set.config 
   
#phyluce_assembly_get_match_counts \
   --locus-db ${workdir}/final_UCEs/${sample}/probe.matches.sqlite \
   --taxon-list-config ${workdir}/final_UCEs/${sample}/taxon-set.config  \
   --taxon-group 'all' \
   --incomplete-matrix \
   --output ${workdir}/final_UCEs/${sample}/all-taxa-incomplete.conf

# Get fasta files for UCEs
phyluce_assembly_get_fastas_from_match_counts \
   --contigs ${workdir}/contig_assembly/${sample}/contigs/ \
   --locus-db ${workdir}/final_UCEs/${sample}/probe.matches.sqlite/ \
   --match-count-output ${workdir}/final_UCEs/${sample}/all-taxa-incomplete.conf \
   --output ${workdir}/final_UCEs/${sample}/${sample}_incomplete.fasta \
   --incomplete-matrix ${workdir}/final_UCEs/${sample}/${sample}_incomplete.incomplete \
   --log-path ${workdir}/final_UCEs/



