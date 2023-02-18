
#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=filt_vcf 
#SBATCH --nodes=1 --ntasks=12
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-17


# activate conda environment with vcftools 
. ~/conda/etc/profile.d/conda.sh
conda activate vcftools

# define input files from helper file during genotyping
sample=$( head -n${SLURM_ARRAY_TASK_ID} samplelist | tail -n1 )
depth=$( head -n${SLURM_ARRAY_TASK_ID} depthlist | tail -n1 )

# define main working directory
workdir=?

# Filter for MSMC and Observed Heterozygosity
vcftools --gzvcf ${workdir}/02_vcf/${sample}.vcf.gz  --minDP 6 --maxDP ${depth} --max-missing 1 --max-alleles 2   --remove-indels --recode --recode-INFO-all -c | bcftools query -f '%CHROM\t%POS\t%REF\t%ALT[\t%GT]\n ' > ${workdir}/msmc/vcf/${sample}.vcf 
