# Calculating Runs of Homozygosity using ROHan

Step 1: Create the sampleslist.txt and references.txt files that contain a list of sample IDs 
and reference assembly names used in the alignment step for each sample respectively. 

Step 2: Run the 01_TsTv.sh script. This will calculate the genome-wide transition to tranversion 
ratio for each sample and will be used as an input parameter for ROHan. 

Step 3: Run the 02_Run_ROHan.sh script. This will run ROHan given your reference assembly, sample, 
and the sample's Ts/Tv ratio. 
