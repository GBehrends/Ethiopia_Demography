# Aligning scaffold-level assemblies of congenerics to chromosomal assemblies of the next most closely related species to the study birds. 

## Step 1: 
- 01_rename_chrom_satsuma.sh is used to consistently name chromosomes across all assemblies for ease of later analyses. This uses
assembly_list.txt to loop over all assemblies. Each assembly will also need a file containing current and desired chromosome names. An
example of the latter is provided in chrom_example.txt. 

## Step 2: 
- 02_run_satsuma.sh is used to align assemblies with satsuma2. It takes target.txt and query.txt files which outline the chromosomal target 
assemblies and the query scaffold assemblies respectively. The script will output a new assembly named as (query)_psuedo.txt. 
