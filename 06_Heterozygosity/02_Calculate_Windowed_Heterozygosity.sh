#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=het
#SBATCH --nodes=1 --ntasks=2
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-?

# Define the working directory
workdir=?

# define input files for hetcalc.r
sample=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/het/helper1.txt | tail -n1 )
scaffold=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/het/helper2.txt | tail -n1 )
result=$(echo ${scaffold} | cut -d '/' -f8 | sed 's/\.vcf//g')

# Load R
module load intel R

# Run hetcalc.r
Rscript ${workdir}/het/hetcalc.r ${scaffold} 100000 ${workdir}/het/${sample}/${sample}__${result} TRUE TRUE 
