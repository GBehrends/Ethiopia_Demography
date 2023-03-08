
# Creating Table of Transition/Tranversion Ratio for each sample

# Establish list of TsTv summary files 
samples <- read.table(file = "sampleslist.txt")
samples <- samples$V1

# Calculate the weighted average Ts/Tv for each file 
tstv <- c()
for (x in 1:length(samples)){
	f <- read.table(file = paste0(samples[x], ".TsTv.summary"),
			sep = "\t", header = T) 
	f <- f[7,2] / f[8,2]
	tstv <- c(tstv, f)
	}
	
# Add sample names to table
tstv <- cbind.data.frame(samples, tstv)

# Save table to file 
write.table(mean_TsTv, file = "tstv.test", sep = "\t", 
		    row.names = F, quote = F, col.names = F)



