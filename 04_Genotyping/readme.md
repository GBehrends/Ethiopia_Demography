Genotyping each representative from each species using their respective reference assemblies and filtering the vcf files
for downstream analyses. 

Step 1: 01_Call_Variants.sh uses bcftools mpileup and call commands to genotype. Uses three helper files with samplelist 
outlining sample prefixes, depthlist outlining maximum depth of coverage thresholds for sites to be kept, and helper3.txt
for which reference assembly to use per slurm task. Examples of these files are provided. 

The first filter for the VCFs outputted here will be found in the 05_MSMC directory. 
