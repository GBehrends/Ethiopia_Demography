# Establish the arguments to interpret 
args <- commandArgs(trailingOnly = T)


################################################################################
#### HetCalc: R Version                                                        
#                                                                              
# A function for calculating observed heterozygosity (Ho) on large VCF files. 
# Works with biallelic, triallelic, and quadrallelic SNPs. 
#  
#   
# Usage: HetCalc(file, n, output, windowed, progress)
#
## Options:                                                                    
# n -> number of VCF file lines to read in at a time                                    
# file -> path to VCF input file                                               
# output -> output object name  
# windowed -> if "= TRUE", calculates in windows of size "n"
# progress -> print progress to screen if "TRUE"
#
# Author: Garrett Behrends 04/2023
################################################################################

HetCalc <- function(file, n, output, windowed, progress){
  
  con <- file
  c.lines <- 0
  n <- as.numeric(n)
  
  # List possible genotype calls 
  HetGenos <- paste("0/1|0\\|1|1/0|1\\|0|0/2|0\\|2|2/0|2\\|0|0/3|3/0|0\\|3",
                    "|3\\|0|1/2|1\\|2|2/1|2\\|1|1/3|1\\|3|3/1|3\\|1|2/3|2\\|3|",
                    "3/2|3\\|2", sep = "")
  
  # If calculations are to be done in windows
  if(windowed == TRUE){
 
    # Begin reading in specified number of VCF lines 
    while(TRUE){
      x <- scan(file = con, nlines = n, skip = c.lines, what = "complex",
                sep = "\n", fileEncoding = "UTF-8")

      # Show progress if selected for in options 
      if(progress == TRUE){
        print(paste("Read in ", n + c.lines, " lines...",
                    sep = ""))
      }
   
      # Stop if the end of VCF is reached 
      if(length(x) == 0){ 
        break 

        # If end of VCF not reached - continue
      } else if(length(grep("#", x, invert = T)) == 0){
     
          # If by some chance the last line has the sample ID header in it:
          if(length(grep("#CHROM", x)) > 0){
            
            # Make sample IDs list 
            ID <- grep("#", x, value = T)
            ID <- ID[length(ID)]
            ID <- unlist(strsplit(ID, "\t"))
            ID <- ID[10:length(ID)]
            
          }
          
          # Skip header lines with "#" and continue reading   
          c.lines <- c.lines + length(grep("#", x))
          
          if(progress == TRUE){
          print(paste0("Skipped ", c.lines, "in header..."))
          }
          
        # If there is only a proportion of header lines in input, get the 
        # sample IDs and then start the next window where genotypes begin 
       } else if(length(grep("#", x)) > 0){
          
          ID <- grep("#", x, value = T)
          ID <- ID[length(ID)]
          ID <- unlist(strsplit(ID, "\t"))
          ID <- ID[10:length(ID)]
          
          # Skip header lines with "#" and continue reading 
          c.lines <- c.lines + length(grep("#", x))
          
          if(progress == TRUE){
          print(paste0("Skipped ", c.lines, "in header..."))
          }
          
        } else if(length(grep("#", x)) == 0){
          
          # When there are no hashes, read in genotyping table for the full 
          # window size 
          x <- read.table(text = x, sep = "\t", header = F)
          
          # Establish all unique chromosome IDs in the window and select the 
          # first chromosome in the dataframe to run calculations 
          chrom <- as.character(unique(x[1])[1,])
          
          # If there is more than one chromosome, Ho calculation will be done 
          # for the first chromosome in the window, and the next window will 
          # start when the next chromosome does in the current window  
          x <- x[grepl(chrom, x$V1),]
          start_pos <- x[1,2]
          end_pos <- x[nrow(x), 2]
          x <- x[10:ncol(x)]
          names(x) <- NULL
          
          # Create HetCount table
          HetCount <- matrix(0, ncol = ncol(x))
          HetCount <- as.data.frame(HetCount)
          colnames(HetCount) <- ID
          
          # Count heterozygous calls 
          for (i in 1:ncol(x)){
            HetCount[i] <- length(grep(HetGenos, as.character(unlist(x[i])))) 
          }
          
          # Establish a count of total genotyped sites in window  
          TotalSites <- nrow(x)
          print(paste("Ho @ ", chrom[1], ":", start_pos, "/", end_pos, 
                      sep = ""))
          print(HetCount/TotalSites)
          HetCount <- HetCount/TotalSites
          HetCount <- as.data.frame(HetCount)
          
          # Create final results starting table if on the first run 
          if(exists("Het") == FALSE){
            Het <- matrix(nrow = 0, ncol = length(ID))
            Het <- as.data.frame(Het)
            colnames(Het) <- ID
          }
          
          Het <- rbind(Het, HetCount)
          rownames(Het)[nrow(Het)] <- paste(chrom[1], ":", start_pos, "/", 
                                            end_pos, sep = "")
          c.lines <- c.lines + n
        }
      }

    # If windows is false, a VCF-wide Ho is calculated 
  } else {
    
    Het <- NULL
    
    # Begin reading in specified number of VCF lines 
    while(TRUE){
      x <- scan(file = con, nlines = n, skip = c.lines, what = "complex",
                sep = "\n", fileEncoding = "UTF-8")
      
      if(progress == TRUE){
        print(paste0("Read in ", n, " lines..."))
      }
      
      # Gather IDs for each sample in the VCF
      if(exists("ID") == FALSE){
        ID <- grep("#", x, value = T)
        ID <- ID[length(ID)]
        ID <- unlist(strsplit(ID, "\t"))
        ID <- ID[10:length(ID)]
      }
      
      # Stop if the end of VCF is reached 
      if(length(x) == 0){ 
        break 
        
        # If end of VCF not reached - continue
      } else {
        x <- grep("#", x, invert = T, value = T)
        x <- read.table(text = x, sep = "\t", header = F)
        x <- x[(10:ncol(x))]
        names(x) <- NULL
        print(nrow(x))
        
        # Begin a table of Ho information which includes the sample IDs
        # if not specified yet
        if (exists("HetCount") == FALSE) {
          HetCount <- matrix(0, ncol = ncol(x))
          HetCount <- as.data.frame(HetCount)
          names(HetCount) <- ID
          
          for (i in 1:ncol(x)){
            HetCount[i] <- length(grep(HetGenos, as.character(unlist(x[i]))))  
          }
        } else {
          for (i in 1:ncol(x)){
            HetCount[i] <- HetCount[i] + length(grep(HetGenos, 
                                                     as.character(unlist(x[i]))))  
          }
        }
      } 
      
      # Establish a count of total genotyped sites if not present 
      if (exists("TotalSites") == FALSE){
        TotalSites <- nrow(x)
        print(paste0("Ho at line ", TotalSites, ":"))
        print(HetCount/TotalSites)
        Het <- t(HetCount/TotalSites)
        colnames(Het) <- "Ho"
        c.lines <- c.lines + n
        
        # If total genotyped sites count in present, add to it 
      } else {
        TotalSites <- TotalSites + nrow(x)
        print(paste0("Ho at line ", TotalSites, ":"))
        print(HetCount/TotalSites)
        Het <- t(HetCount/TotalSites)
        colnames(Het) <- "Genome-wide_Ho"
        c.lines <- c.lines + n
      }
    }
  }
  
  # Write output file  
  assign(x = "out", value = Het, envir = .GlobalEnv)
  write.table(x = out, file = paste0(output, ".tsv"), sep = "\t", quote = F, 
              row.names = T, col.names = TRUE, append = FALSE)
}


# Run HetCalc with arguments supplied on the command line 
HetCalc(file = args[1], n = args[2], output = args[3], windowed = args[4], 
        progress = args[5])
