Calculate per site depth of coverage and plot it. This will be used to determine thresholds of minimum depth of coverage 
and maximum depth of coverage for sites to be kept during the variant calling and filtering.  

Step 1: Calculate the per site read depth using bam files. For later plotting, only the third column with the read counts 
is needed; The "reduced.txt" outputs only have this column. Doing this also greatly reduces the file size. 
