## Creating a maximimum clade credibillity UCE phylogeny for study samples 

Before beginning, be sure that all of your reference assembly fasta file names are all lowercase. 
At one point in Phyluce, outputs become lowercase, and it is simpler to use the same reference 
assembly list. 

Step_1: 01_Extract_Probes.sh \
Uses a standard tetrapod UCE data set (from the authors of Phyluce) to extract UCE regions 
from the input references assemblies outlined in the "references" list. 

Step_2: 02_UCE_bam.sh \
Creates a bed file outlining the chromosome start and stop positions for all UCEs found in 
the reference assemblies. It then uses samtools to isolate the UCE regions in the bam files for 
each sample(from the 02_Alignment section). These extracted bam regions are then converted to 
UCE fastq files. 

Step_3: 03_Extract_Sample_UCEs.sh \
Assembles the sequences from UCE fastq files for each sample into contigs and matches those 
contigs to the original tetrapod UCE probeset. 

Step_4: 04_Make_UCE_List.sh \
Creates a list of all possible UCEs contained in all samples. 

Step_5: 05_Align_UCEs.sh \
Checks if a UCE in contained in all samples. If the UCE sequence is in all samples, an alignment 
is made using MUSCLE. 

Step_6: 06_RAxML.sh \
Quality trims the alignments and generates a gene trees for UCEs that were kept previously.   
