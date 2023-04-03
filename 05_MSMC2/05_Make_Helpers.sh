#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=msmc2
#SBATCH --nodes=1 --ntasks=1
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G

# Establish working directory. 
workdir=/lustre/scratch/gbehrend/Demog_ETH/msmc

# Iterate through each sample from each species. 
for x in $(cat samplelist); 
do cd /lustre/scratch/gbehrend/Demog_ETH/msmc/${x}_demography/; \

  # Iterate through list of all of all directories per sample and insert *txt on the end to 
  # incorporate all scaffolds in each directory. 
  for i in $(find ~+ -type d | sed '1d' | sed 's,\./,,g'); 
  
    # Making a list of input files (scaffolds).  
    do echo "${i}/*txt" >> /lustre/scratch/gbehrend/Demog_ETH/msmc/helper1.txt; 
    
    # Making a list of output files (Final coalesence rate tables). These will go in the 
    # main species demography directory. 
    echo "${i}" | sed "s,${x}/,,g" >> /lustre/scratch/gbehrend/Demog_ETH/msmc/helper2.txt; done
    
    # Exit species demography directory to begin next species. 
    cd /lustre/scratch/gbehrend/Demog_ETH/msmc/;
   
   done


  
