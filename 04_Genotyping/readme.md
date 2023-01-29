Genotyping each representative from each species using their respective reference assemblies and filtering the vcf files
for downstream analyses. 

Step 1: 01_Call_Variants.sh uses bcftools mpileup and call commands to genotype. Uses three helper files with helper1.txt 
outlining sample prefixes, helper2.txt outlining maximum depth of coverage thresholds for sites to be kept, and helper3.txt
for which reference assembly to use per slurm task. Examples of these files are provided. 

Step 2: 02_Filter_Variants uses vcftools to futher filter variants especially to remove indels and missing data. Since 
genotyping is done per individual, no missing data is allowed for either analyses.
