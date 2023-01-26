#!/bin/bash
#SBATCH --chdir=./
#SBATCH --job-name=satsuma
#SBATCH --partition=nocona
#SBATCH --nodes=1 --ntasks=128
#SBATCH --time=48:00:00
#SBATCH --mem=450G
#SATCH --array=1

module load gcc

workdir=/lustre/scratch/gbehrend/Demog_ETH

target=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/ref/target.txt | tail -n1 )
query=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/ref/query.txt | tail -n1 )

cd ${workdir}/ref

export SATSUMA2_PATH=/lustre/scratch/gbehrend/Demog_ETH/satsuma2/bin

gunzip ${workdir}/ref/${target}_genomic.fna.gz
gunzip ${workdir}/ref/${query}_genomic.fna.gz

${workdir}/satsuma2/bin/Chromosemble -t ${workdir}/ref/${target}_genomic.fna \
-q ${workdir}/ref/${query}_genomic.fna \
-o ${workdir}/ref/satsuma_out \
-n 120 \
-s 1

gzip ${workdir}/ref/${target}_genomic.fna
gzip ${workdir}/ref/${query}_genomic.fna
