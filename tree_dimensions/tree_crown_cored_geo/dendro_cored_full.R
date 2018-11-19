# Merge to see all tree cores compared to tree surveys

## First files we're working with
cores <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/climate_sensitivity_cores/data/census_data_for_cored_trees.csv")

dendro_trees <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/dendro_trees.csv")


library(data.table)
setnames(cores, old=c("StemTag"), new=c("stemtag"))
setnames(dendro_trees, old=c("mortality.year"), new=c("status"))
library(tidyr)
dendro_trees$status <- ifelse(dendro_trees$status=="[:digit:]", "A", "D") #this ifelse code is backwards from what it should be but for some reason it's producing the right output.
dendro_trees$status <- replace_na(dendro_trees$status, "A")


dendro_trees$year.cored <-cores$year.cored[match(dendro_trees$tag,cores$tag)]

dendro_merge <- merge(dendro_trees, cores, by=c("tag", "stemtag", "sp", "quadrat", "treeID", "stemID", "status", "gx", "gy","year.cored"), all.x=TRUE, all.y=TRUE)

dendro_all <- dendro_merge[c(1:13,17:22)]

##order the data and remove the crossovers (btwn biannual and cored) that don't have biannual marked already
dendro_all <- dendro_all[order(dendro_all$tag,dendro_all$biannual),]

dendro_all$stemID[is.na(dendro_all$stemID)] <- 0
##WARNING:assign stemID values for 30365 and 131352 (discrepancy with 2013 census). THIS PART SHOULD BE DELETED once the 2018 census data includes these tags with the appropriate info.
dendro_all[91,6]=11 
dendro_all[867,6]=12


dendro_all<-dendro_all[!duplicated(dendro_all$stemID),]

##populate with geographic coordinates
latlon <- read.csv("V:/SIGEO/GIS_data/dendroband surveys/Merged_dendroband_utm_lat_lon.csv")

dendro_all$NAD83_X <- latlon$NAD83_X[match(dendro_all$stemID, latlon$stemID)]

dendro_all$NAD83_Y <- latlon$NAD83_Y[match(dendro_all$stemID, latlon$stemID)]

dendro_all$lat <- latlon$lat[match(dendro_all$stemID, latlon$stemID)]

dendro_all$lon <- latlon$lon[match(dendro_all$stemID, latlon$stemID)]


##populate with lx, ly, and status (once ForestGEO 2018 census data is added, use that for base status)
census_2013 <- read.csv("V:/SIGEO/3-RECENSUS 2013/DATA/FINAL DATA to use, to share/scbi.stem2.csv")

field2013<- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_main_census/data/census-csv-files/census3_coord_local_plot.csv")
#this .txt file was downloaded straight from CTFS at toward the end of data entry for the 3rd census Nov. 2018.

setnames(field2013, old="qx", new="lx")
setnames(field2013, old="qy", new="ly")

dendro_all$lx <- field2013$lx[match(dendro_all$stemID, field2013$stemid)]
dendro_all$ly <- field2013$ly[match(dendro_all$stemID, field2013$stemid)]

##can also do this another way from the census field forms. Not as accurate since you're matching by tag as opposed to stemID
#library(openxlsx)
#field2013 <- read.xlsx("V:/SIGEO/2-RECENSUS 2018/DATA/Forms to PRINT/QUADRAT_to_print.xlsx", sheet="QUAD_to_print", startRow=6)

#dendro_all$lx <- field2013$lx[match(dendro_all$tag, field2013$tag)]
#dendro_all$ly <- field2013$ly[match(dendro_all$tag, field2013$tag)]


##update status from most recent mortality data (this will update only some of the trees, hence why the census data is used first)

mortality_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data_private/SCBI_mortality/raw data/Mortality_Survey_2018.csv")


dendro_all$status <- mortality_2018$new.status[match(dendro_all$tag, mortality_2018$tag)]

missing <- ifelse(is.na(dendro_all$status), dendro_all$tag, "")
missingdf <- dendro_all[!complete.cases(dendro_all$status),]
missingdf <- missingdf[c(1:2)]

setnames(census_2013, old=c("StemTag"), new=c("stemtag"))

dendro_test <- merge(missingdf, census_2013[,c("tag", "stemtag","status")], by=c("tag","stemtag"))

dendro_all <- merge(dendro_all, dendro_test, by="tag", all.x=TRUE)
setnames(dendro_all, old="stemtag.x", new="stemtag")

library(tidyr)
dendro_all <- unite(dendro_all, status, status.x, status.y)
dendro_all$status <- gsub("_NA", "", dendro_all$status)
dendro_all$status <- gsub("NA_", "", dendro_all$status)

dendro_all$status <- gsub("PD", "D", dendro_all$status)
dendro_all$status <- gsub("DS", "D", dendro_all$status)
dendro_all$status <- gsub("DC", "D", dendro_all$status)
dendro_all$status <- gsub("AU", "A", dendro_all$status)


##get rid of NA
dendro_all$biannual[is.na(dendro_all$biannual)] <- 0
dendro_all$intraannual[is.na(dendro_all$intraannual)] <- 0
dendro_all$cored[is.na(dendro_all$cored)] <- 1

census_2008 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_main_census/data/census-cvs-files/scbi.stem1.csv")

dendro_all$dbh2008 <- census_2008$dbh[match(dendro_all$stemID, census_2008$stemID)]
dendro_all$dbh2013 <- census_2013$dbh[match(dendro_all$stemID, census_2013$stemID)]

dendro_all$dbh2008 <- round(dendro_all$dbh2008,1)
dendro_all$dbh2013 <- round(dendro_all$dbh2013,1)
dendro_all$gx <- round(dendro_all$gx,1)
dendro_all$gy <- round(dendro_all$gy,1)

##re-order
dendro_all <- dendro_all[c(1:6,21:22,11:13,10,7,14:15,8:9,16:19)]

#get rid of final duplicates now that all rows are the same
dendro_all <- dendro_all[!duplicated(dendro_all),]

write.csv(dendro_all, "dendro_cored_full.csv", row.names=FALSE)
