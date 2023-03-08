# Creating Table of Mean Transition/Tranversion Ratio for each 
# Sample and each Window Size 

# Establish list of TsTv summary files 
summaries <- list.files(pattern = "summary")
samples <- gsub("\\.TsTv\\.summary", "", summaries)

# Calculate the weighted average Ts/Tv for each file 
tstv <- c()
for (x in 1:length(summaries)){
	f <- read.table(file = summaries[x], sep = "\t", header = T) 
	f <- f[7,2] / f[8,2]
	tstv <- c(tstv, f)
	}
	
# Add sample names to table
tstv <- cbind.data.frame(samples, tstv)

# Save table to file 
write.table(mean_TsTv, file = "tstv", sep = "\t", 
		    row.names = F, quote = F, col.names = F)
