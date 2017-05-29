#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)
library(igraph)
#lines=vector(mode='integer')
  
links <- read.table('new.edge', header=F, 
                    col.names=c("from","to","rlen","linenum"),
                    colClasses = c("character","character",
                                   "integer","integer"))

print("generate graph")
net <- graph_from_data_frame(d=links, directed=F)
print("calculate degree")
deg <- degree(net,mode = 'all')

#deg_filtered_names = names(deg)[deg>=deg_fil]
commu = cluster_louvain(net)

commu_size <- as.integer(sizes(commu))


#filter <- ceiling(log(num,2))-1
#print(filter)
commu_names = names(commu[commu_size>=2])
#print(length(commu_names))
#print(commu$names)
#print(commu_names)
printCommunity <- function(x){
  nodes <- commu$names[commu$membership==x]
  nodeSubgraph = induced_subgraph(net,nodes)
  E(nodeSubgraph)[1]$linenum
}    
lines <- sapply(commu_names,printCommunity)


lines = sort(lines)
lines =unique(lines)

#alllines = paste(paste(as.character(lines),collapse = "p;"),"p",sep ="")
#write(alllines,file='new.line.sed')
write.table(lines,file='new.line',row.names = FALSE,col.names = FALSE)
