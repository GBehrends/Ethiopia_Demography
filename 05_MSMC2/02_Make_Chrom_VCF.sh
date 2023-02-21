
#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=chrom_vcf 
#SBATCH --nodes=1 --ntasks=6
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-1000

# Establish the working directory
workdir=?

# Set the number of runs that each SLURM task should do. 
TOTAL_RUNS="$(wc -l < samp_list.txt)"

# Identify your SLURM task limit 
MAX_JOBS=1000

# Set the number of runs that each SLURM task should do. 
PER_TASK="$(expr ${TOTAL_RUNS} / MAX_JOBS + 1)"

# Calculate the starting and ending values for this task based
# on the SLURM task and the number of runs per task.
START_NUM=$(( ($SLURM_ARRAY_TASK_ID - 1) * $PER_TASK + 1 ))
END_NUM=$(( $SLURM_ARRAY_TASK_ID * $PER_TASK ))

# Run the loop of runs for this task.
for (( run=$START_NUM; run<=$END_NUM; run++ )); do
        echo This is SLURM task $SLURM_ARRAY_TASK_ID, run number $run

        sample=$( head -n${run} ${workdir}/msmc/vcf/samp_list.txt | tail -n1 )

        chrom=$( head -n${run} ${workdir}/msmc/vcf/chrom_list.txt | tail -n1 )
        
        # Make chromosomal VCFs
        zcat ${workdir}/msmc/vcf/${sample}.simple.vcf.gz | grep ${chrom} | cut -f2,3,4,5 >  ${workdir}/msmc/vcf/${sample}/${chrom}.vcf;
        
        # Size select chromosomes greater than 1Mbp; PLace the rest into the excluded chrom directory. 
        if (("$(tail -n 1 ${workdir}/msmc/vcf/${sample}/${chrom}.vcf | cut -f1)" < 100000)); then 
        mv ${workdir}/msmc/vcf/${sample}/${chrom}.vcf ${workdir}/msmc/vcf/${sample}/excluded_chrom/${chrom}.vcf; 
        
        # Gzip excluded chromsomes that were too small 
        gzip ${workdir}/msmc/vcf/${sample}/excluded_chrom/${chrom}.vcf; fi;
        
        # Indicate that the job is complete once the final run is done. 
        if ((${run}==${END_NUM})); then echo "Task Complete"; fi; done
