# MSMC2 on Single Individuals (Non-phased Genotypes)

Step 1: Create samplelist.txt and depthlist.txt files in the MSMC2 VCF directory. These will serve to identify the 
sample prefixes and the maximum depth of coverage threshold to be used for each sample. Maximum depth of coverage 
limit was determined by visually inspecting the depth of coverage plots. Run the 01_Filter.sh script. 

Step 2: Concenate all species' samp_list.txt files together and all species chrom_list.txt files together (files thaat were generated at the end of 01_Filter.sh). Run the 02_Make_Chrom.sh script. This will parse all scaffolds in the VCFs and isolate those larger than 1Mbp, saving them to a new file. 

Step 3: Run the 03_Simplify.sh script to sort and simplify scaffold VCFs into a format for MSMC2. 

Step 4: 04_Make_Scaffolds_Bootstrap.sh. This script will generate the msmc2 scaffolds and all their bootstraps for each sample.

Step 5: Concatenate all species helper1 and helper2 files into a helper1.txt file and helper2.txt file into main working directory using 05_Make_Helper.sh. 

Step 6: Run 06_Run_MSMC2.sh. 


