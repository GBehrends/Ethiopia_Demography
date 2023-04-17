################################################################################
# Plotting Windowed Heterozygosity
################################################################################
library(ggplot2)
library(cowplot)

# Gather list of tsv files containing windowed heterozygosity calculations  
setwd("<path to directory containing the heterozygosity tables (tsv)>")
x_files <- list.files(paste0(getwd(), "/Windowed_Het/"), 
                      pattern = "sorted.tsv")

# Loop through each tsv file
for (x in 1:length(x_files)){
  
  # Read in tsv 
  data <- read.table(file = paste(getwd(), "/Windowed_Het/",x_files[x], 
                                  sep = ""),
                     sep = "\t", header = T, row.names = NULL)
  
  # Get name of species and make title for it 
  spec <- colnames(data)[2]
  spec <- sapply(strsplit(spec, "_EB"), "[[", 1)
  title <- gsub("_", " ", spec)
  
  # Name column on the position
  colnames(data)[1] <- "Position"
  colnames(data)[2] <- "Observed_Heterozygosity"
  
  # Subset data by those scaffolds which are chromosomes
  data <- data[grep("Chromosome", data$Position),]
  
  # Create chromosome column 
  data$Chromosome <- sapply(strsplit(data$Position, ":"), "[[", 1)
  data$Chromosome <- sapply(strsplit(data$Chromosome, "_"), "[[", 2)
  
  # Order data frame by chromosome
  data <- data[order(data$Position),]
  
  # Calculate the mean heterozygosity 
  avg_het <- round(mean(data$Observed_Heterozygosity), 3)
  
  # Establish breaks on the x axis by chromosome
  chrom <- unique(data$Chromosome)
  break_list <- c()
  for (c in 1:length(chrom)){
    center <- grep(paste("Chromosome_",chrom[c], ":", sep = ""),data$Position)
    center <- median(center)
    break_list <- c(break_list, data$Position[center])
  }
  
  # Plot the results 
  if(x == length(x_files)){
    yeuh <- colnames(data)[1]
  } else {
    yeuh <- ""
  }
  
  p <- ggplot(data = data, aes(x = Position, y = Observed_Heterozygosity,
                               fill = Chromosome)) + 
    geom_bar(stat = "identity") + 
    ggtitle(title) +  
    theme(legend.position = "none",
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          plot.title = element_text(face = "italic"),
          plot.caption.position = "panel",
          plot.background = element_blank(),
          panel.background = element_blank(),
          panel.grid = element_blank()) +
    ylab("") + 
    xlab(yeuh) + 
    #labs(caption = paste("(mean: ", avg_het, ")", sep = "")) + 
    scale_fill_manual(breaks = unique(data$Chromosome),
                      values = rep(c("red", "black"), 
                                   length(unique(data$Chromosome)))) +
    scale_x_discrete(breaks = break_list,
                     labels = chrom) 
  
  # Assign plot to its own name 
  assign(paste0(spec, "_Plot"), p)
  
}


# Facet  wrap the resulting plots 
p <- plot_grid(plotlist = mget(ls(pattern = "_Plot")), ncol = 1)

# Save the plot as a pdf 
pdf(file = "/Volumes/T7/Ethiopia_Demography/het/facet_caption.pdf",
    width = 20, height = 36)
plot(p)
dev.off()

