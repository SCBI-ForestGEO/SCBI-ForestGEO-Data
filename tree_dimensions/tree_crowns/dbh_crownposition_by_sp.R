# analysis for Ian paper

## This analysis uses a very specific subset of cored trees, starting only with the 14 species used in Ryan Helcoski's paper (which is 726 individuals (725 tags, 1 multistem)). 

## Of these, those with a dbh of 0 in 2018 were assigned the dbh in 2013, and assumed to have a crown position of "C" (if dbh>350mm) or "I" (if dbh<=350 but dbh>0), if there wasn't a crown position measured.

## The remaining individuals with dbh=0 (meaning they died 2013 and prior) were filtered out. Individuals with a crown position of NA were also filtered out (bc some of them are labeled as fallen, or as DN this year). By this point all of AJ's (SMSC student) measurements of "CF" (couldn't find) from fall 2018 have been converted.

## After all this filtering, the graphs finally show the remaining 664 individuals (663 tags plus 1 multistem).

#which cores used in final chronologies ####
#these cores used in Ryan's paper
setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data_private/tree_cores/chronologies/current_chronologies")

chronology_list <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data_private/tree_cores/chronologies/chronology_list.csv")

library(stringr)
complete <- subset(chronology_list, status=="complete")
chron <- levels(factor(complete$chronology))
chronsp <- str_extract(chron, "[a-z]+")

file_list <- list.files("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data_private/tree_cores/chronologies/current_chronologies", pattern="_drop.csv")

library(data.table)
merged <- rbindlist(fill=TRUE, lapply(file_list, fread))
merged <- merged[,c("tag","sp")]

mergedchron <- subset(merged, sp %in% chronsp)


#dataframe subsets ####
setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns")

dendrofull <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns/dendro_cored_full.csv")

dendrosub <- merge(dendrofull, mergedchron)
dendrosub <- dendrosub[order(dendrosub[,1]),]

## makes sure there are no duplicates
## this code says give me the tag numbers for the duplicated stemID
dendrosub$tag[duplicated(dendrosub$stemID)]

## for trees that have dbh2018=0, give them dbh2013.
dendrosub$dbh2018 <- ifelse(dendrosub$dbh2018 == 0, dendrosub$dbh2013, dendrosub$dbh2018)

##assume dead trees that have dbh>0 and a crown.position value of CF (AJ couldn't find), have a crown.position of "I" if under 350mm, and C if over 350mm.
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

## separate chronologies by canopy position

highcan <- subset(dendrosub, crown.position == "D" | crown.position == "C")
lowcan <- subset(dendrosub, crown.position == "I" | crown.position == "S")

## separate trees by dbh (above and below 35cm)
highdbh <- subset(dendrosub, dbh2018>350)
lowdbh <- subset(dendrosub, dbh2018<=350)


#graphs #####
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
ggplot(data = dendro2018) +
  aes(x = sp,fill = crown.position, weight = dbh2018/100) +
  geom_bar() +
  scale_y_continuous(breaks=c(0,350,1500)) +
  labs(title = "DBH and Crown Position by Sp",
       x = "sp",
       y = "dbh2018 (mm)") +
  theme_minimal()
dev.off()



finalsp <- levels(factor(dendro2018$sp))


totals$crown.S <- length(which(litu$crown.position=="S"))

library(stringr)

totals <- data.frame(finalsp)

# for intraannual
for (j in seq(along=finalsp)){
  spname = finalsp[[j]]
  totals$crown.S <- ifelse(sum(dendro2018$crown.position == "S")

}













library(data.table)
testr <- dendro2018[ ,c("sp", "crown.position")]
testr$ <

library(dplyr)
test$C <- testr %>% 
  add_count(sp, crown.position=="c")
test <- test[!(duplicated(test)),]





