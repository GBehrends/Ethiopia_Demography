# MSMC2 on Single Individuals (Non-phased Genotypes)

Step 1: Create samplelist.txt and depthlist.txt files in the MSMC2 VCF directory. These will serve to identify the 
sample prefixes and the maximum depth of coverage threshold to be used for each sample. Maximum depth of coverage 
limit was determined by visually inspecting the depth of coverage plots. Run the 01_Filter.sh script. 

Step 2: Run the 02_Make_Chrom_VCF.sh script. This will split each sample VCF into chromosomal VCFs and sort the 
chromosomal VCFs by size, gzipping those less than 1Mbp and storing them in a separate directory. 

Step 3: 03_Make_Scaffolds_Bootstrap.sh. This script will generate the msmc2 scaffolds and all their bootstraps for each sample.

Step 4: Concatenate all species helper1 and helper2 files into a helper1.txt file and helper2.txt file into main working directory using 04_Make_Helper.sh. 

Step 5: Run 05_Run_MSMC2.sh. 


