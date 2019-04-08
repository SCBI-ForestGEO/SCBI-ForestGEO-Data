#finding wrong quadrats/coordinates per year


## quick check 2008 ####
read.csv("scbi.stem1.csv")
scbi.stem1 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_main_census/data/census-csv-files/scbi.stem1.csv")

scbi.stem1$lx <- scbi.stem1$gx - 20*((scbi.stem1$quadrat %/% 100) - 1)
scbi.stem1$ly <- scbi.stem1$gy - 20*((scbi.stem1$quadrat %% 100) - 1)

scbi.stem1$lx <- round(scbi.stem1$lx, digits=1)
scbi.stem1$ly <- round(scbi.stem1$ly, digits=1)

check_2008 <- scbi.stem1[scbi.stem1$lx <0 | scbi.stem1$lx>20 | scbi.stem1$ly<0 | scbi.stem1$ly>20, ]

## quick check 2013 ####
read.csv("scbi.stem2.csv")
scbi.stem2 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_main_census/data/census-csv-files/scbi.stem2.csv")

scbi.stem2$tag <- as.character(scbi.stem2$tag)

scbi.stem2$lx <- scbi.stem2$gx - 20*((scbi.stem2$quadrat %/% 100) - 1)
scbi.stem2$ly <- scbi.stem2$gy - 20*((scbi.stem2$quadrat %% 100) - 1)

scbi.stem2$lx <- round(scbi.stem2$lx, digits=1)
scbi.stem2$ly <- round(scbi.stem2$ly, digits=1)

check_2013 <- scbi.stem2[scbi.stem2$lx <0 | scbi.stem2$lx>20 | scbi.stem2$ly<0 | scbi.stem2$ly>20, ]

## quick check 2018 ####
scbi.stem3 <- read.csv("scbi.stem3_TEMPORARY.csv") #from github
scbi.stem3 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_main_census/data/scbi.stem3_TEMPORARY.csv")

scbi.stem3$Tree_ID_Num <- gsub("_[[:digit:]]", "", scbi.stem3$Tree_ID_Num)

library(data.table)
setnames(scbi.stem3, old=c("Tree_ID_Num", "SiteID"), new=c("tag", "quadrat"))

scbi.stem3$lx <- scbi.stem3$gx - 20*((scbi.stem3$quadrat %/% 100) - 1)
scbi.stem3$ly <- scbi.stem3$gy - 20*((scbi.stem3$quadrat %% 100) - 1)

scbi.stem3$lx <- round(scbi.stem3$lx, digits=1)
scbi.stem3$ly <- round(scbi.stem3$ly, digits=1)

check_2018 <- scbi.stem3[scbi.stem3$lx <0 | scbi.stem3$lx>20 | scbi.stem3$ly<0 | scbi.stem3$ly>20, ]