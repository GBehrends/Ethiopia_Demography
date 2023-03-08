
#!/bin/bash
#SBATCH --job-name=het_sample
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err
#SBATCH --partition=nocona
#SBATCH --nodes=1
#SBATCH --ntasks=4

# Set working directory 
workdir=?

# Calculate ratio of heterozygous genotypes vs all genotypes 
sample_END="$(head -n 1 ${workdir}/het/sample.vcf | awk '{print NF}')"
for ((x = 4; x <= sample_END; ++x)); do 
sample_Genotyped_Count="$( wc -l ${workdir}/het/sample.vcf | sed 's/ /\t/g' | cut -f1)"
sample_Het_Count="$(cut -f${x} ${workdir}/het/sample.vcf | grep -F -e '0/1' -e '1/0'  -e '0|1' -e '1|0' | wc -l | sed 's/ /\t/g' | cut -f1)"
echo " scale=10; ${sample_Het_Count} / ${sample_Genotyped_Count}" | bc >> sample_Obs_Het.txt; done


