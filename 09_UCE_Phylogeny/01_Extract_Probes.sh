#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=extract_UCEs
#SBATCH --nodes=1 --ntasks=12
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-<number of reference assemblies used> 

# Activate conda environment containing Phyluce-1.7.2 and faToTwoBit
. ~/conda/etc/profile.d/conda.sh
conda activate phyluce-1.7.2 

# Define the working directory 
workdir=/lustre/scratch/gbehrend/Demog_ETH/UCEs

# Define path to reference assembllies 
ref_path=<>

# Establish array list 
ref=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/ref/references | tail -n1 )

# Copy reference assembly to 2bit folder 
mkdir -p ${workdir}/ref/${ref}/
cp ${ref_path}/${ref}.fasta ${workdir}/ref/${ref}/

# Convert each reference assembly into 2bit format. Make sure that you have your 
faToTwoBit ${workdir}/ref/${ref}/${ref}.fasta ${workdir}/ref/${ref}/${ref}.2bit
mv ${workdir}/ref/${ref}/${ref}.2bit ${workdir}/ref/${ref}.2bit
rm -r ${workdir}/ref/${ref}/

# Determining UCE sequences in reference assemblies using UCE probe set
phyluce_probe_run_multiple_lastzs_sqlite  --db ${workdir}/reference_probes/${ref}.db \
--output ${workdir}/reference_probes/${ref}_lastz --scaffoldlist ${ref} \
--genome-base-path ${workdir}/ref --probefile ${workdir}/reference_probes/uce-5k-probes.fasta --cores 12

# Make config file for current reference genome 
echo "[scaffolds]" > ${workdir}/reference_probes/${ref}.config 
echo "${ref}:${workdir}/ref/${ref}/${ref}.2bit" >> ${workdir}/reference_probes/${ref}.config

# Extracting UCE sequences from the reference assemblies 
phyluce_probe_slice_sequence_from_genomes --lastz ${workdir}/reference_probes/${ref}_lastz \
--conf ${workdir}/reference_probes/${ref}.config --flank 1000 \
--name-pattern "uce-5k-probes.fasta_v_{}.lastz.clean" --output ${workdir}/reference_probes/${ref}_probes
