#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
fname = args[1] 
#files = dir(pattern=fname,full.names = TRUE)

#print(files)
writelinename <- function(file){
filename = paste(file,".sed",sep="")
linenum <- read.table(file,as.is = TRUE)
linenum <- linenum$V1

linenum = paste(paste(as.character(linenum),collapse = "p;"),"p",sep ="")
write(linenum,file=filename)
}
#sapply(files,writelinename)
writelinename(fname)
