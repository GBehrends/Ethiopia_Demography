# Run the following interactively to combine all chromosomal heterozygosity calculations by species
# and then sort by chromosome and chromosome position 
#!/bin/sh

# run on an interactive session 
interactive -c 1 

# Define working directory 
workdir=<main directory> 

# Combine tsv files into species heterozygosity tables 
for i in $(cat samplelist.txt); 
  do echo "${i}" > ${workdir}/het/${i}_het.tsv; 
  for x in $(ls ${i});
    do  tail -n +2 ${i}/${x} >> ${workdir}het/${i}_het.tsv; done ; done 
 
 
# Sorting the heterozygosity tables 
# Iterate through each chromosome and place the species header in the sorted file  
for i in $(cat samplelist.txt); do     
  echo "${i}" > ${workdir}/${i}_sorted.tsv;

  # Make single digit chromosome numbers begin with 0 for easy sorting 
  for x in {1..9}; 
    do sed -i "s/_${x}:/_0${x}:/g" ${workdir}/${i}_het.tsv; done 
  
  # Remove the header on the orignal file before sorting it and placing it in
  # the sorted file 
  sed '1d' ${workdir}/${i}_het.tsv | sort -k1  >> ${workdir}/${i}_sorted.tsv; done
 
