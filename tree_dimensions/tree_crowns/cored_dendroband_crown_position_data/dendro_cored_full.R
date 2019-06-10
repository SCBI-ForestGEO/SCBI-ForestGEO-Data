######################################################
# Purpose: Merge to see all tree cores compared to ForestGEO censuses
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.1 - First created November 2018
######################################################
library(data.table)
library(tidyr)
library(RCurl)


## First files we're working with
cores <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/climate_sensitivity_cores/master/data/census_data_for_cored_trees.csv"))

dendro_trees <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/Dendrobands/master/data/dendro_trees.csv?token=AJNRBEPJI72IQ7TYJX64GFC5A6LES"))

#if want to keep North/South identifier, then don't use this line. Otherwise, run the line since keeping it will alter the number of columns below (it was added after this script was finished)
dendro_trees$location <- NULL

setnames(cores, old=c("StemTag"), new=c("stemtag"))
setnames(dendro_trees, old=c("mortality.year"), new=c("status"))

dendro_trees$status <- ifelse(dendro_trees$status=="[:digit:]", "A", "D") #this ifelse code is backwards from what it should be but for some reason it's producing the right output.
dendro_trees$status <- replace_na(dendro_trees$status, "A")


dendro_trees$year.cored <-cores$year.cored[match(dendro_trees$tag,cores$tag)]

dendro_merge <- merge(dendro_trees, cores, by=c("tag", "stemtag", "sp", "quadrat", "treeID", "stemID", "status", "gx", "gy","year.cored"), all.x=TRUE, all.y=TRUE)

dendro_all <- dendro_merge[c(1:13,17:22)]

##order the data and remove the crossovers (btwn biannual and cored) that don't have biannual marked already
dendro_all <- dendro_all[order(dendro_all$tag,dendro_all$biannual),]

dendro_all$stemID[is.na(dendro_all$stemID)] <- 0

dendro_all<-dendro_all[!duplicated(dendro_all$stemID),]

##populate with geographic coordinates
latlon <- read.csv("spatial_data/UTM coordinates/scbi_stem_utm_lat_long_2013.csv")

dendro_all$NAD83_X <- latlon$NAD83_X[match(dendro_all$stemID, latlon$stemID)]

dendro_all$NAD83_Y <- latlon$NAD83_Y[match(dendro_all$stemID, latlon$stemID)]

dendro_all$lat <- latlon$lat[match(dendro_all$stemID, latlon$stemID)]

dendro_all$lon <- latlon$lon[match(dendro_all$stemID, latlon$stemID)]


##populate with lx, ly, and status (once ForestGEO 2018 census data is added, use that for base status)
##we have the 2018 data currently in SCBI-ForestGEO-Data-Private. Once it is converted to the final, official form and made public (moved to the public repo), update this.
census_2018 <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/master/census%20data/ViewFullTable_crc_master.csv?token=AJNRBENW6IUKAF3KQURJDK25A6LWU"))

setnames(census_2018, old="qx", new="lx")
setnames(census_2018, old="qy", new="ly")

dendro_all$lx <- census_2018$lx[match(dendro_all$stemID, census_2018$stemid)]
dendro_all$ly <- census_2018$ly[match(dendro_all$stemID, census_2018$stemid)]


##update status from most recent mortality data (this will update only some of the trees, hence why the census data is used first)
mortality_2018 <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data_private/SCBI_mortality/raw data/Mortality_Survey_2018.csv")


dendro_all$status <- mortality_2018$new.status[match(dendro_all$tag, mortality_2018$tag)]

missing <- ifelse(is.na(dendro_all$status), dendro_all$tag, "")
missingdf <- dendro_all[!complete.cases(dendro_all$status),]
missingdf <- missingdf[c(1:2)]

setnames(census_2018, old=c("StemTag"), new=c("stemtag"))

dendro_test <- merge(missingdf, census_2013[,c("tag", "stemtag","status")], by=c("tag","stemtag"))

dendro_all <- merge(dendro_all, dendro_test, by="tag", all.x=TRUE)
setnames(dendro_all, old="stemtag.x", new="stemtag")

##clarify status
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

census_2008 <- read.csv("tree_main_census/data/census-csv-files/scbi.stem1.csv")
census_2013 <- read.csv("tree_main_census/data/census-csv-files/scbi.stem2.csv")

dendro_all$dbh2008 <- census_2008$dbh[match(dendro_all$stemID, census_2008$stemID)]
dendro_all$dbh2013 <- census_2013$dbh[match(dendro_all$stemID, census_2013$stemID)]
dendro_all$dbh2018 <- census_2018$DBH[match(dendro_all$stemID, census_2018$stemID)]

dendro_all$dbh2008 <- round(dendro_all$dbh2008,1)
dendro_all$dbh2013 <- round(dendro_all$dbh2013,1)
dendro_all$dbh2018 <- round(dendro_all$dbh2018,1)
dendro_all$gx <- round(dendro_all$gx,1)
dendro_all$gy <- round(dendro_all$gy,1)

##re-order
dendro_all <- dendro_all[c(1:6,21:22,11:13,10,7,14:15,8:9,16:19)]

#get rid of final duplicates now that all rows are the same
dendro_all <- dendro_all[!duplicated(dendro_all),]

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns/cored_dendroband_crown_position_data")
write.csv(dendro_all, "dendro_cored_full1.csv", row.names=FALSE)
