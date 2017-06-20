#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
fname = args[1]
deg_fil=as.integer(args[2])
commu_size_fil=as.integer(args[3])
first=as.integer(args[4])
second=as.integer(args[5])
breaks=as.integer(args[6])
drops=as.integer(args[7])
weight=as.character(args[8])
#folder='~/project/dro_temp/n200l15000000b50n11n21deg30c30o1div0/'
# deg_fil=50
# commu_size_fil=20
# first=1
# second=3
# breaks=200
# drops=3

#setwd(folder)
filepattern=paste(fname,"_[0-9]*.edge",sep="")
print(filepattern)
files = dir(pattern=filepattern,full.names = TRUE)
print(files)
print(first)
print(second)
print(deg_fil)
print(commu_size_fil)
print(breaks)
print(drops)
print(weight)
library(igraph)
#lines=vector(mode='integer')
pipelines = function(file,deg_fil,commu_size_fil,first,second,breaks,drops,weight){
  print(file)
  #name_from = regexpr("part",file)
  name_to = regexpr(".edge",file)
  outfilename = substr(file,0,name_to-1)
  print("outfilename")
  print(outfilename)
  print("reading edge list")
  links <- read.table(file, header=F, 
                      col.names=c("from","to","rlen","linenum"),
                      colClasses = c("character","character",
                                     "integer","integer"))
	print("generate graph")  
  net <- graph_from_data_frame(d=links, directed=F)

 print("calculate deg") 
  deg <- degree(net,mode = 'all')
  #deg_frame <- data.frame(x=deg)
  
  # diff_deg <- diff(log(table(cut(deg,
  #                                seq(0,100,20)))
  #                      ,base=2))
  # fromname = names(diff_deg[(which(diff_deg>-1)-1)[1]])
  # 
  # filterfrom = regexpr(",",fromname)
  # filterfromnum = as.integer(substr(fromname,2,filterfrom-1))
  # 
  # 
  # deg_filtered_names = names(deg)[deg>=filterfromnum]
  deg_filtered_names = names(deg)[deg>=deg_fil]
  net_filtered <- induced_subgraph(net,deg_filtered_names,impl="create_from_scratch")
  print("calculate community")
  if(weight=="true"){
    print("use weight")
    commu = cluster_louvain(net_filtered,weights = E(net_filtered)$rlen)}
  else{
    print("do not use weight")
    commu = cluster_louvain(net_filtered)
  }
  
  commu_size <- as.integer(sizes(commu))
  #print(commu_size)
  
  #print(sum(commu_size>commu_size_fil))
  #sizes(commu)[commu_size>commu_size_fil]
  #print(commu_size_fil)
  commu_names = names(commu[commu_size>commu_size_fil] )
  print(length(commu_names))
  #print(length(commu))
  #print(sum(commu$membership=='626'))
  mhaplines=vector(mode='integer')
  
  
  printCommunity <- function(x,
                             net = net_filtered,
                             community = commu,
                             first,
                             second,
                             breaks,
                             drops){
    #browser()
    
    # print(first)
    # print(second)
    # print(breaks)
    #print(x)
    #print(community)
    
    nodes <- community$names[community$membership==x]
    # print(length(nodes))
    nodeSubgraph = induced_subgraph(net,nodes)
    sortedLenDiff = sort(diff(log(table(cut(E(nodeSubgraph)$rlen,
                                            seq(0,15000,breaks)
    )
    ),base=2)
    )
    )
    #print(nodeSubgraph)
    
    #print(seq(0,15000,breaks))
    
    #print(sortedLenDiff)
    
    
    testnames = names(sort(table(cut(E(nodeSubgraph)$rlen,
                                     seq(0,15000,breaks)
    )
    )[table(cut(E(nodeSubgraph)$rlen,
                seq(0,15000,breaks)
    )
    ) > 10],
    decreasing = TRUE))
    # print("testnames:")
    # print(testnames)
    
    allrangenames =names(table(cut(E(nodeSubgraph)$rlen,
                                   seq(0,15000,breaks)
    )))
    
    
    #notice the lenthghdiff number
    rangename = names(sortedLenDiff[!is.infinite(sortedLenDiff)])[1:drops]
    rangename = rangename[!is.na(rangename)]
    
    if(length(testnames) > 0 & length(rangename) > 0){
      #print(rangename)
      #print(length(rangename))
      if(length(rangename)==1){
        rangename = allrangenames[which(allrangenames==rangename)-1]
        
      }else{
        newrangenames = allrangenames[sapply(rangename,function(x){
          which(allrangenames==x)-1})]
        newrangenames = newrangenames[!is.na(newrangenames)]
        rangename = newrangenames
      }
      
      rangename <- union(rangename,testnames)
    }else{
      #print("none")
      return()
    }
    
   
    
    rangename=rangename[1:first]
    rangename = rangename[!is.na(rangename)]
    #print("rangename")
    # print(rangename)
    pos = sapply(rangename, function(x){
      regexpr(",",x) } )
    
    #print(pos)
    #print(rangename)
    fromLength = as.integer(substr(rangename,2,pos-1))
    #toLength = fromLength + breaks
    linenum <- sapply(fromLength,function(x){
      E(nodeSubgraph)$linenum[E(nodeSubgraph)$rlen > x & 
                                E(nodeSubgraph)$rlen < x + breaks]
      
    })
    #linenum <- E(nodeSubgraph)$linenum[E(nodeSubgraph)$rlen > fromLength & 
    #                                    E(nodeSubgraph)$rlen < toLength]
    if(is.list(linenum)){
      
      #print(linenum)
      allline=sapply(linenum,function(x){ x[1:second]})
      # print('1')
      #print(allline)
      linelist = apply(allline,2,function(x) x[1:second][!is.na(x[1:second])])
      alllines = sort(unlist(linelist))
      #result= sapply(linenum,length)
    }else{
      #print('2')
      #print(linenum)
      if(is.vector(linenum)){
        #browser()  
        # return()
        #print(linenum)
        alllines =linenum[1:second][!is.na(linenum[1:second])]
        #result=length(linenum)
        #print(length(result))
        #print(length(fromLength))
        #print(fromLength)
        
      }else{
        #print(is.matrix(linenum))
        #print(is.list(linenum))
        linelist = apply(linenum,2,function(x) x[1:second][!is.na(x[1:second])])
        alllines =linelist[1:second][!is.na(linelist[1:second])]
        # print(alllines)
        #result= apply(linenum,2,length)
      }
      
    }
    
    #allline=sapply(linenum,function(x){ x[1:3]})
    #linelist = apply(allline,2,function(x) x[1:3][!is.na(x[1:3])])
    #alllines = sort(unlist(linelist))
    
    
    #alllines = paste(paste(as.character(alllines),collapse = "p;"),"p",sep ="")
    #names(result)=paste(fromLength,fromLength+breaks,sep="-")
    #write(alllines,file=filename)
    rm(nodeSubgraph)
    return(alllines)
    
  }             
  
  filename = paste(outfilename,".line",sep="")
  templines = sapply(commu_names,printCommunity,first=first,second=second,breaks=breaks,drops=drops)
  print(filename)
  #print(templines)
  mhaplines=unlist(templines)
  
  mhaplines = sort(mhaplines)
  mhaplines =unique(mhaplines)
  print(length(mhaplines))
  alllines = paste(paste(as.character(mhaplines),collapse = "p;"),"p",sep ="")
  write(alllines,file=filename)
  rm(commu,links,net,deg)
}
#pipelines = function(file,deg_fil,commu_size_fil,first,second)
library(parallel)
mclapply(files,pipelines,deg_fil=deg_fil,
         commu_size_fil=commu_size_fil,
         first=first,
         second=second,
         breaks=breaks,
         drops=drops,
         weight=weight,
         mc.cores=4)		
