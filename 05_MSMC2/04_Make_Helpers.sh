#!/bin/sh
#SBATCH --chdir=./
#SBATCH --job-name=msmc2
#SBATCH --nodes=1 --ntasks=1
#SBATCH --partition=quanah
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=8G

#Establish working directory 
workdir=/lustre/scratch/gbehrend/Demog_ETH/msmc

for i in $(cat sampleslist.txt); do 
  cat ${sample}_demography/helper1.txt >> ${workdir}/msmc/helper1.txt;
  cat ${sample}_demography/helper2.txt >> ${workdir}/msmc/helper2.txt; done
  
