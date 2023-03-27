#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=chrom_vcf 
#SBATCH --nodes=1 --ntasks=6
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-?

# Establish the working directory 
workdir=?

# Maximum number of array jobs that can be submitted to cluster at a time 
MAX_JOBS=1000

# Set the number of runs that each SLURM task should do. Samplist contains total number of runs needed  
RUNS="$(wc -l < samp_list.txt)"
PER_TASK="$(expr ${RUNS} / ${MAX_JOBS} + 1)"

# Calculate the starting and ending values for this task based
# on the SLURM task and the number of runs per task.
START_NUM=$(( ($SLURM_ARRAY_TASK_ID - 1) * $PER_TASK + 1 ))
END_NUM=$(( $SLURM_ARRAY_TASK_ID * $PER_TASK ))

# Run the loop of runs for this task.
for (( run=$START_NUM; run<=$END_NUM; run++ )); do
        echo This is SLURM task $SLURM_ARRAY_TASK_ID, run number $run

        sample=$( head -n${run} samp_list.txt | tail -n1 )

        chrom=$( head -n${run} chrom_list.txt | tail -n1 )
        
        # Create folder to store scaffold VCFs 
        if(("$(ls ${workdir}/03_vcf | grep "${sample}_Scaffolds" | wc -l )" == 0)); 
        then mkdir ${workdir}/03_vcf/${sample}_Scaffolds; fi

        # Creater header file for each sample
        if(("$(ls ${workdir}/03_vcf/${sample}_Scaffolds | grep "header.txt" | wc -l )"  == 0));
        then grep "#" ${workdir}/03_vcf/${sample}.recode.vcf >>  ${workdir}/03_vcf/${sample}_Scaffolds/header.txt; fi 
        
        # Make VCF that only has scaffolds ≥ 1Mbp
        if(("$(grep -w -m 1 "contig=<ID=${chrom}" ${workdir}/03_vcf/${sample}.recode.vcf | grep -o '[0-9]*'| sed -n '$p')" >= 1000000)); 
        then grep -w "${chrom}" ${workdir}/03_vcf/${sample}.recode.vcf | grep -v "#" > ${workdir}/03_vcf/${sample}_Scaffolds/${chrom}.filtered.vcf;
        cat ${workdir}/03_vcf/${sample}_Scaffolds/header.txt ${workdir}/03_vcf/${sample}_Scaffolds/${chrom}.filtered.vcf > ${workdir}/03_vcf/${sample}_Scaffolds/${chrom}.vcf;
        rm ${workdir}/03_vcf/${sample}_Scaffolds/${chrom}.filtered.vcf; fi 
        
          # Indicate that the job is complete once the final run is done. 
        if ((${run}==${END_NUM})); then echo "Task Complete"; fi; done
        
