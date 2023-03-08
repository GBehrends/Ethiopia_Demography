# Calculating Runs of Homozygosity using ROHan

Step 1: Run 01_TsTv.sh. This will calculate the genome-wide transition to tranversion 
ratio for each sample and will be used as an input parameter for ROHan. Be sure to have 
sampleslist.txt and references.txt files in your directory outlining the sample IDs and 
reference assemblies, respectively. 

Step 2: Run the 02_Make_TsTv.r script to generate a list of TsTv ratios for each sample. Output
file will be named "tstv."

Step 3: Run 03_Run_ROHan.sh. This will run ROHan using your list of reference assemblies 
(references.txt), list of sample IDs (sampleslist.txt), and the list of tstv ratios (tstv). 
