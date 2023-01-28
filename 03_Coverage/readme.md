Calculate per site depth of coverage and plot it. This will be used to determine thresholds of minimum depth of coverage 
and maximum depth of coverage for sites to be kept during the variant calling and filtering.  

Step 1: 01_Depth.sh calculates the per site read depth using bam files. For later plotting, only the third column with the read 
counts is needed; The "reduced.txt" outputs only have this column. Doing this also greatly reduces the file size. 

Step 2: 02_Plot_Depth.r plots depth of coverage across the genome for each sample and facet wraps all plots in a pdf. 
The plots are used to determine the maximum depth of coverage filter for variant calling. Maximum depth was determined 
by visually locating at what depth the right tail in the plots first flattened to a near zero frequency in the genome. 
