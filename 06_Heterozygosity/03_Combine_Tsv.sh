# Run the following command interactively to combine all chromosomal het calculations by species 
workdir=<main directory> 

for i in $(cat samplelist.txt); 
  do echo "${i}" > ${workdir}/het/${i}_het.tsv; 
  for x in $(ls ${i});
    do  tail -n +2 ${i}/${x} >> ${workdir}het/${i}_het.tsv; done ; done 
