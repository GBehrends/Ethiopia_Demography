
# Creating Table of Transition/Tranversion Ratio for each sample

# Establish list of sample IDs 
samples <- read.table(file = "sampleslist.txt")
samples <- samples$V1

# Extract the Ts/Tv for each sample's TsTv summary file
tstv <- c()
for (x in 1:length(samples)){
	f <- read.table(file = paste0(samples[x], ".TsTv.summary"),
			sep = "\t", header = T) 
	f <- f[7,2] / f[8,2]
	tstv <- c(tstv, f)
	}

# Save TsTv list to file 
write.table(mean_TsTv, file = "tstv", sep = "\t", 
		    row.names = F, quote = F, col.names = F)



