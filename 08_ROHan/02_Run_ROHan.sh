#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=ROHan
#SBATCH --nodes=1 --ntasks=10
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=2-17


# Define the working directory 
workdir=?

# Define array list 
sample=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/ROHan/samplelist.txt | tail -n1 )
ref=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/ROHan/references.txt | tail -n1 )
tstv=$( head -n${SLURM_ARRAY_TASK_ID} ${workdir}/ROHan/tstv | tail -n1 )

# Make directory for each sample run through ROHan
mkdir ${workdir}/ROHan/${sample}_20k

# Make scaffolds list for each sample by listing the scaffold vcfs kept during the MSMC filtering step 
ls ${workdir}/msmc/vcf/${sample}/*vcf > ${workdir}/ROHan/${sample}_20k/${sample}_scaffolds.txt
sed -i "s,${workdir}/msmc/vcf/${sample}/,,g" ${workdir}/ROHan/${sample}_20k/${sample}_scaffolds.txt
sed -i "s,\.vcf,,g" ${workdir}/ROHan/${sample}_20k/${sample}_scaffolds.txt

# Run ROHan 
/lustre/scratch/gbehrend/Demog_ETH/ROHan/rohan/bin/rohan \
--rohmu 2e-5 --tstv ${tstv} --auto ${workdir}/ROHan/${sample}_20k/${sample}_scaffolds.txt \
--size 20000  -o ${workdir}/ROHan/${sample}_20k/${sample} -t 10 \
/lustre/work/gbehrend/demo_ref/${ref%\.gz} \
${workdir}/01_bam/${sample}_final.bam 

