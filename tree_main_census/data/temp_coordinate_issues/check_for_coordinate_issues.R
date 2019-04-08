#finding wrong quadrats/coordinates per year


## quick check 2008 ####
read.csv("scbi.stem1.csv")
#scbi.stem1 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_main_census/data/census-csv-files/scbi.stem1.csv")

scbi.stem1$lx <- scbi.stem1$gx - 20*((scbi.stem1$quadrat %/% 100) - 1)
scbi.stem1$ly <- scbi.stem1$gy - 20*((scbi.stem1$quadrat %% 100) - 1)

scbi.stem1$lx <- round(scbi.stem1$lx, digits=1)
scbi.stem1$ly <- round(scbi.stem1$ly, digits=1)

check_2008 <- scbi.stem1[scbi.stem1$lx <0 | scbi.stem1$lx>20 | scbi.stem1$ly<0 | scbi.stem1$ly>20, ]

## quick check 2013 ####
read.csv("scbi.stem2.csv")
#scbi.stem2 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_main_census/data/census-csv-files/scbi.stem2.csv")

scbi.stem2$tags_comb <- paste0(scbi.stem2$tag, "_", scbi.stem2$StemTag)

scbi.stem2$lx <- scbi.stem2$gx - 20*((scbi.stem2$quadrat %/% 100) - 1)
scbi.stem2$ly <- scbi.stem2$gy - 20*((scbi.stem2$quadrat %% 100) - 1)

scbi.stem2$lx <- round(scbi.stem2$lx, digits=1)
scbi.stem2$ly <- round(scbi.stem2$ly, digits=1)

check_2013 <- scbi.stem2[scbi.stem2$lx <0 | scbi.stem2$lx>20 | scbi.stem2$ly<0 | scbi.stem2$ly>20, ]

## quick check 2018 ####
scbi.stem3 <- read.csv("scbi.stem3_TEMPORARY.csv") #from github
#scbi.stem3 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_main_census/data/scbi.stem3_TEMPORARY.csv")

scbi.stem3$tag <- gsub("_[[:digit:]]", "", scbi.stem3$Tree_ID_Num)

library(data.table)
setnames(scbi.stem3, old=c("Tree_ID_Num", "SiteID", "DBHcm", "SPPCODE"), new=c("tags_comb", "quadrat", "dbh", "sp"))

scbi.stem3$lx <- scbi.stem3$gx - 20*((scbi.stem3$quadrat %/% 100) - 1)
scbi.stem3$ly <- scbi.stem3$gy - 20*((scbi.stem3$quadrat %% 100) - 1)

scbi.stem3$lx <- round(scbi.stem3$lx, digits=1)
scbi.stem3$ly <- round(scbi.stem3$ly, digits=1)

check_2018 <- scbi.stem3[scbi.stem3$lx <0 | scbi.stem3$lx>20 | scbi.stem3$ly<0 | scbi.stem3$ly>20, ]

## compare the years ####
check_2008$tag %in% check_2013$tag
check_2013$tag %in% check_2018$tag

#because 2008 and 2013 are identical, I'm only rbinding 2013 and 2018
need <- setdiff(colnames(check_2013), colnames(check_2018))
extra <- setdiff(colnames(check_2018), colnames(check_2013))
check_2013[, extra] <- NA
check_2018[, need] <- NA
combine <- rbind(check_2013, check_2018)

#some tag/stemtag combos are duplicated between 2013 and 2018
combine <- combine[!duplicated(combine$tags_comb), ]
combine$year <- ifelse(combine$tag %in% check_2018$tag & combine$tag %in% check_2013$tag, 
                       c("2008, 2013, 2018"), 
                       ifelse(combine$tag %in% check_2013$tag & !(combine$tag %in% check_2018$tag), c("2008, 2013"), combine$year))

combine <- combine[, c(1:4,21,5:8,22:23,27, 9:20,24:26,28)]

write.csv(combine, "combined_years.csv", row.names=FALSE)
