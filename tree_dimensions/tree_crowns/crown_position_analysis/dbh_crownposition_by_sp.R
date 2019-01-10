# analysis for Ian paper

## This analysis uses a very specific subset of cored trees (with data from dendro_cored_full.csv), starting only with the 14 species used in Ryan Helcoski's paper (which is 726 individuals (725 tags, 1 multistem)). 

## Of these, those with a dbh of 0 in 2018 were assigned the dbh in 2013, and assumed to have a crown position of "C" (if dbh>350mm) or "I" (if dbh<=350 but dbh>0), if there wasn't a crown position measured.

## The remaining individuals with dbh=0 (meaning they died 2013 and prior) were filtered out. Individuals with a crown position of NA were also filtered out (bc some of them are labeled as fallen, or as DN this year). By this point all of AJ's (SMSC student) measurements of "CF" (couldn't find) from fall 2018 have been converted.

## After all this filtering, the graphs finally show the remaining 664 individuals (663 tags plus 1 multistem).

#1 which cores used in final chronologies ####
#these cores used in Ryan's paper
setwd("E:/Github_SCBI/SCBI-ForestGEO-Data_private/tree_cores/chronologies/current_chronologies")

chronology_list <- read.csv("E:/Github_SCBI/SCBI-ForestGEO-Data_private/tree_cores/chronologies/chronology_list.csv")

library(stringr)
complete <- subset(chronology_list, chronology_status=="complete")
chron <- levels(factor(complete$chronology_name))
chronsp <- str_extract(chron, "[a-z]+")

##lines 23-30 were before 10 December. Lines 31-33 create the same result BUT allchron is missing any mention of quve cores. This needs to be fixed or we need the separate csv files back.
file_list <- list.files("E:/Github_SCBI/SCBI-ForestGEO-Data_private/tree_cores/chronologies/current_chronologies/complete", pattern="_drop.csv")

library(data.table)
merged <- rbindlist(fill=TRUE, lapply(file_list, fread))
merged <- merged[,c("tag","sp")]

mergedchron <- subset(merged, sp %in% chronsp)

allchron <- read.csv("E:/Github_SCBI/SCBI-ForestGEO-Data_private/tree_cores/cross-dated_cores_CSVformat/all_core_chronologies.csv")

allchron <- allchron[,c("tag", "sp")]
mergedchron <- subset(allchron, sp %in% chronsp)

#2 merging dendro_cored_full with #1, create "dendro_subset_ian_paper.csv" ####
setwd("E:/Github_SCBI/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns")

dendrofull <- read.csv("E:/Github_SCBI/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns/cored_dendroband_crown_position_data/dendro_cored_full.csv")

dendrosub <- merge(dendrofull, mergedchron)
dendrosub <- dendrosub[order(dendrosub[,1]),]

## make sure there are no duplicates
## this code says give me the tag numbers for the duplicated stemID
dendrosub$tag[duplicated(dendrosub$stemID)]

## for trees that have dbh2018=0, give them dbh2013.
dendrosub$dbh2018 <- ifelse(dendrosub$dbh2018 == 0, dendrosub$dbh2013, dendrosub$dbh2018)

##assume dead trees that have dbh>0 and a crown.position value of CF (AJ couldn't find), have a crown.position of "I" if under 350mm, and C if over 350mm.
dendrosub$crown.position <- ""
dendrosub$crown.position <- as.character(dendrosub$crown.position)
dendrosub$crown.position <- ifelse(dendrosub$dbh2018>0 & 
                                    dendrosub$dbh2018<=350 &
                                    dendrosub$tree.notes == "CF", 
                                    "I", dendrosub$crown.position)
dendrosub$crown.position <- ifelse(dendrosub$dbh2018>350 & 
                                    dendrosub$tree.notes == "CF", 
                                    "C", dendrosub$crown.position)

##subset by 
dendro2018 <- subset(dendrosub, dendrosub$dbh2018>0 & !(is.na(dendrosub$crown.position)))

write.csv(dendro2018, "dendro_subset_ian_paper.csv", row.names=FALSE)

#3 create new table with n trees by crown position ####

dendro2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns/dendro_subset_ian_paper.csv")

library(ggplot2)
library(dplyr)
library(tidyverse)

finalsp <- levels(factor(dendro2018$sp))
#

#get dbh min/max/mean for each crown position by species, then merge together
dbhmax <- aggregate(dendro2018$dbh2018, by=list(dendro2018$sp, dendro2018$crown.position), max)
dbhmin <- aggregate(dendro2018$dbh2018, by=list(dendro2018$sp, dendro2018$crown.position), min)
dbhavg <- aggregate(dendro2018$dbh2018, by=list(dendro2018$sp, dendro2018$crown.position), mean)
names(dbhmax) <- c("sp", "crown.position", "dbhmax.mm")
names(dbhmin) <- c("sp", "crown.position", "dbhmin.mm")
names(dbhavg) <- c("sp", "crown.position", "dbhavg.mm")
is.num <- sapply(dbhavg,is.numeric)
dbhavg[is.num] <- lapply(dbhavg[is.num], round, 1)

data_num <- list(dbhmin,dbhmax,dbhavg) %>% reduce(left_join, by=c("sp","crown.position"))

#get the number of each species per crown position
library(data.table)
count.crown <- addmargins(table(dendro2018$sp, dendro2018$crown.position),1)  
count.crown <- as.data.frame.matrix(count.crown)
setDT(count.crown, keep.rownames=TRUE)[]
count.crown <- setnames(count.crown, "rn", "sp")
count.crown <- count.crown[count.crown$sp %in% finalsp, ]

#now reformat crown position table, then merge everything together 
library(reshape)
count.crown <- melt(count.crown, id=(c("sp")))
count.crown <- setnames(count.crown, c("variable", "value"), c("crown.position", "n.trees"))
count.test <- merge(count.crown, data_num, by=c("sp", "crown.position"), all=TRUE)

write.csv(count.test, "chronologies_by_crownposition.csv", row.names=FALSE)

#4 graphs #####
setwd("E:/Github_SCBI/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns/crown_position_analysis")

dendro2018 <- read.csv("E:/Github_SCBI/tree-growth-and-traits/dendro_subset_ian_paper.csv")

library(ggplot2)
pdf(file="DBH_CrownPosition_by_all_sp.pdf", width=10)

## graph DBH abundance by canopy position
ggplot(data = dendro2018) +
  aes(x = dbh2018, fill = crown.position) +
  geom_histogram(bins = 50) +
  scale_fill_brewer(palette = "Paired") +
  scale_x_continuous(breaks=c(0,350,1500)) +
  labs(title = "DBH by Crown Position",
       x = "dbh2018 (mm)",
       y = "Count") +
  theme_minimal()

## graph DBH by canopy position and sp
ggplot(data = count.test) +
  aes(x = sp,fill = crown.position, weight = n.trees) +
  geom_bar() +
  labs(title = "Number of Crown Positions by Sp",
       x = "sp",
       y = "N.individuals") +
  theme_minimal()
dev.off()

##graphs for Ian analysis with 14 species by canopy/subcanopy
neilcores <- read.csv("E:/Github_SCBI/tree-growth-and-traits/core_list_for_neil.csv")

pdf("crownposition_graphs_by_sp.pdf", width=9)
ggplot(data = neilcores) +
  aes(x = dbh2018, fill = crown.position) +
  geom_histogram(bins = 50) +
  scale_fill_brewer(palette = "Paired") +
  scale_x_continuous(breaks=c(0,350,1500)) +
  labs(title = "DBH by Crown Position",
       x = "dbh2018 (mm)",
       y = "Count") +
  theme_minimal()

countsp <- read.csv("E:/Github_SCBI/tree-growth-and-traits/core_chronologies_by_crownposition.csv")

countsp <- countsp[, -c(4:6)]
countsp$crown.position <- gsub("C", "canopy", countsp$crown.position)
countsp$crown.position <- gsub("D", "canopy", countsp$crown.position)
countsp$crown.position <- gsub("S", "subcanopy", countsp$crown.position)
countsp$crown.position <- gsub("I", "subcanopy", countsp$crown.position)

countsp.test <- aggregate(countsp$n.trees, by=list(countsp$crown.position, countsp$sp), FUN=sum)

colnames(countsp.test) <- c("crown.position", "sp", "n.trees")

ggplot(data = countsp.test) +
  aes(x = sp,fill = crown.position, weight = n.trees) +
  geom_bar() +
  labs(title = "Number of Crown Positions by Sp",
       x = "sp",
       y = "N.individuals") +
  theme_minimal()
dev.off()

#5 list of cores to send to Neil (10 Dec 2018) ####

#from end of step #2
dendro2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns/dendro_subset_ian_paper.csv")

dendro2018$crown.position <- ifelse(dendro2018$crown.position=="C" | dendro2018$crown.position=="D", "canopy", "sub-canopy")

#order by tag and species

dendro2018 <- dendro2018[with(dendro2018, order(sp, crown.position)), ]

write.csv(dendro2018, "core_list_for_neil.csv", row.names=FALSE)
