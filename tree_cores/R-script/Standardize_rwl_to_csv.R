######################################################
# Purpose: Reformat .rwl files to csv
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created November 2018
######################################################

##this code is specifically for those .rwl files in the "complete" folder in Github (Forest-GEO-Data_private\tree_cores\chronologies\current_chronologies\complete). 

##For .rwl files in the "incomplete" folder (those that either .rwl or _drop.rwl), see bottom [the inside of the for-loop function remains the same, albeit a different write.csv output].

## in other words, watch out before doing CONTROL/COMMAND A

#1 create one csv with all chronologies in "complete" folder #####
#the formatting process is done within the for-loop

library(tools)
library(dplR)
library(data.table)
library(dplyr)
library(Rcurl)

dirs <- dir("tree_cores/chronologies/current_chronologies/complete")
dirs <- dirs[grepl("\\.rwl", dirs)]
mergedirs <- tempdir("tree_cores/chronologies/current_chronologies/complete/merged")

files <- file_path_sans_ext(dirs)
testFileName <- paste0(files, ".csv")

mergelist <- list()

for (i in seq(along=dirs)){
  org <- read.rwl(paste("tree_cores/chronologies/current_chronologies/complete", dirs[i], sep = '//'), format="tucson")
  
  ##transpose the dataframe
  transorg <- transpose(org)
  rownames(transorg) <- colnames(org)
  colnames(transorg) <- rownames(org)
  transorg <- setDT(transorg, keep.rownames = TRUE)[]
  setnames(transorg,1,"coreID")
  
  #create column with only numeric tag numbers, then order
  transorg$tag <- gsub("[^0-9]", "", transorg$coreID) 
  transorg$tag <- as.numeric(transorg$tag)
  transorg <- transorg %>% select(tag,everything())
  formatC(transorg$tag, width=6,format="d", flag="0") 
  #a shorter version of this is sprintf("%06d", transorg$tag)
  transorg <- transorg[order(tag),]
  
  transorg <- rbindlist(mget(ls(pattern="transorg")), idcol=TRUE)
  setnames(transorg, old=".id", new="sp")
  transorg <- transorg %>% select(tag, coreID, sp, everything())
  transorg$sp <- gsub("transorg", dirs[i], transorg$sp)
  transorg$sp <- gsub("_.*", "", transorg$sp)
  transorg$sp <- gsub(".rwl", "", transorg$sp)
  
  mergelist[[i]] <- data.frame(transorg, check.names=FALSE)
}  

mergedcores <- rbindlist(mergelist, fill=TRUE)
years <- c(colnames(mergedcores))
years <- years[order(years)]
setDT(mergedcores)
setcolorder(mergedcores, years)

##add status at time of coring. 2010-2011 cores were alive, 2016-2017 cores were dead
notes_2010 <- read.csv("tree_cores/measurement_files/measurement_notes_2010_chronology.csv")
tags10 <- notes_2010$tag

notes_2016 <- read.csv("tree_cores/measurement_files/measurement_notes_2016_17_chronology.csv")

mergedcores$status.at.coring <- ""
mergedcores <- mergedcores %>%
  select("tag","coreID","sp", "status.at.coring", everything())

Tag_2010_only <- setdiff(notes_2010$Tag, notes_2016$Tag)
Tag_2016_only <-  setdiff(notes_2016$Tag, notes_2010$Tag)
Tags_in_both <- intersect(notes_2010$Tag, notes_2016$Tag)

mergedcores$status.at.coring[mergedcores$tag %in% Tag_2010_only]<- "alive" # this is giving "alive" to those cored in 2010
mergedcores$status.at.coring[mergedcores$tag %in% Tag_2016_only]<- "dead" # this is giving "dead" to those cored in 2016
mergedcores$status.at.coring[mergedcores$tag %in% Tags_in_both]<- "dead" # when trees were cored both in 2010 and 2016, it means the ree was dead in 2026 so regardless it is a dying tree and we shouldn't use the last years of data

# remove cores that are supposedly cored in 2010 but have data passed 2010
mergedcores[mergedcores$status.at.coring          %in%"alive" & !is.na(mergedcores$'2011'), c("coreID", "2011")] # 5 trees do --> we delete those
mergedcores <- mergedcores[!mergedcores$coreID %in% mergedcores$coreID[mergedcores$status.at.coring          %in%"alive" & !is.na(mergedcores$'2011')] ]


write.csv(mergedcores, "tree_cores/all_core_chronologies.csv", row.names=FALSE)

############if need to write individual csvs to each species folder, use this code as the last function within the for loop
write.csv(transorg, file=paste(dirs[i], testFileName[i], sep = '//'), row.names=FALSE)

#
##
#2 use this space below for troubleshooting ####
##
#
## for files in the chronologies folder
setwd("tree_cores/chronologies/current_chronologies")

dirs <- dir("tree_cores/chronologies/current_chronologies", pattern=".rwl")

library(tools)
fileName <- file.path(dirs)
files <- file_path_sans_ext(fileName)
testFileName <- paste0(files, ".csv")

for (i in seq(along=fileName)){
  library(dplR)
  org <- read.rwl(fileName[i], format="tucson")
  
  ##transpose the dataframe
  library(data.table)
  transorg <- transpose(org)
  rownames(transorg) <- colnames(org)
  colnames(transorg) <- rownames(org)
  transorg <- setDT(transorg, keep.rownames = TRUE)[]
  setnames(transorg,1,"coreID")
  
  #create column with only numeric tag numbers, then order
  transorg$tag <- gsub("[^0-9]", "", transorg$coreID) 
  transorg$tag <- as.numeric(transorg$tag)
  
  library(dplyr)
  transorg <- transorg %>% select(tag,everything())
  formatC(transorg$tag, width=6,format="d", flag="0") 
  #a shorter version of this is sprintf("%06d", transorg$tag)
  transorg <- transorg[order(tag),]
  
  transorg <- rbindlist(mget(ls(pattern="transorg")), idcol=TRUE)
  setnames(transorg, old=".id", new="sp")
  transorg <- transorg %>% select(tag, coreID, sp, everything())
  transorg$sp <- gsub("transorg", fileName[i], transorg$sp)
  transorg$sp <- gsub("_.*", "", transorg$sp)
  transorg$sp <- gsub(".rwl", "", transorg$sp)
  

  write.csv(transorg, file=testFileName[i], row.names=FALSE)
}
