Trimming and quality filtering sample fastq files and aligning to the previously prepped reference assemblies. 

Step 1: Create a directory called 01_bam. Create these example files inside of 01_bam: 
- samplelist: a list of all sample fastq prefixes to align  
- references: a list of corresponding reference assemblies to align each sample fastq too. Must be in the same order. 
  
 Step 2: Run the trim_align script. Each step within the script is annotated. The end products are filtered bam files with indexes. 
