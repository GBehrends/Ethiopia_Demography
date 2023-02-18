# Calculating genome-wide observed heterozygosity for each sample. 

Step 1: Make a directory called het in the main working directory then run 01_export_het_VCF.sh from 
the msmc/vcf directory to cat the chromosomes kept after size filtering. This will make a vcf with and without sex chromosomes 
for each species. 

Step 2: Run 02_Hetcalc.sh in the het directory. Submit is like this to iterate over all vcfs:

echo "for i in $(ls *vcf); do sed "s/sample/${i%\.vcf}/g" 02_HetCalc.sh | sbatch; done"
