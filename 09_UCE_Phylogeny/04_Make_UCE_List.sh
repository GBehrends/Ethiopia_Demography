# Define working directory 
workdir=<main wowkring directory> 

# Create a list of UCEs found in all samples UCE fasta files 
for i in $(cat samplelist); do grep ">" ${workdir}/UCEs/final_UCEs/${i}/${i}_incomplete.fasta >> ${workdir}/UCEs/final_UCEs/x; done 
cut -f1 ${workdir}/UCEs/final_UCEs/x -d "_" | sort | uniq | sed 's/>uce-//g' >> ${workdir}/UCEs/UCE_list.txt
rm ${workdir}/UCEs/final_UCEs/x
