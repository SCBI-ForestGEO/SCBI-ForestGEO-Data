#########################################
# Purpose: Script to produce the layout of any future mortality surveys - eliminates "copy-and-paste" method
# Method: Take information from most recent census data and intergrate it with most recent mortality survey data
# Developed by: Alyssa Terrell (terrella3@si.edu), Ian McGregor (mcgregori@si.edu), and Valentine Herrmann (herrmannv@si.edu)
# R version 3.5.2 - Created June 2019
##########################################

# clear the environment ####
rm(list = ls())

# Load in needed package
library(data.table)

# Load in data ####
census3 <- read.csv("C:/Users/terrella3/Dropbox (Smithsonian)/GitHub_Alyssa/SCBI-ForestGEO-Data_private/census data/ViewFullTable_crc_master.csv", stringsAsFactors=FALSE)
mort18 <- read.csv("C:/Users/terrella3/Dropbox (Smithsonian)/GitHub_Alyssa/SCBI-ForestGEO-Data/tree_mortality/raw data/Mortality_Survey_2018.csv", stringsAsFactors=FALSE)

# Prepare census 3 ####
census3 <- census3[census3$CensusID %in% 3, ] # Subset to keep only data collected during census 3
census3$DBH <- as.numeric(census3$DBH) # Make sure DBH is a numeric, will coerce NULL to NA

# Create a unique ID ####
census3$tag_stem <- paste(census3$Tag, census3$StemTag, sep = "_") 
mort18$tag_stem <- paste(mort18$tag,  mort18$stem, sep = "_") 

# Create a new column that will hold the DBH from mort18, matching based on the new unique ID
census3$DBH_2018 <- mort18$dbh.2013[match(census3$tag_stem, mort18$tag_stem)]

# Subset for trees that are DBH >= 100 in census 3 or that are dead (dbh is NA or 0) in census 3  BUT for which the DBH in mort18 is >= 100 AND all fraxinus species >= 10
## mort19 <- census3[(!is.na(census3$DBH) & census3$DBH >= 100) | ((is.na(census3$DBH) | census3$DBH == 0) & (!is.na(census3$DBH_2018) & census3$DBH >= 100)) | (census3$Mnemonic %in% c("fram", "frni", "frpe", "frsp") & !is.na(census3$DBH) & census3$DBH_2018 >= 10), ]

mort19 <- census3[(!is.na(census3$DBH) & census3$DBH >= 100) | ((is.na(census3$DBH) | census3$DBH == 0) & (!is.na(census3$DBH_2018) & census3$DBH_2018 >= 100)) | (census3$Mnemonic %in% c("fram", "frni", "frpe", "frsp") & !is.na(census3$DBH_2018) & census3$DBH_2018 >= 10), ]

# Format mort19 ####

mort19 <- mort19[names(census3) %in% c("QuadratName", "Tag", "StemTag", "StemID", "Mnemonic", "QX", "QY", "DBH", "ListOfTSM")]

setnames(mort19, old = c("QuadratName", "Tag", "StemTag", "StemID", "Mnemonic", "QX", "QY", "DBH", "ListOfTSM"),
         new = c("quadrat", "tag", "stem", "stemID", "sp", "lx", "ly", "dbh.2018", "codes.2018"))

# Copy over the tree statuses from previous surveys
mort19$con <- paste0(mort19$tag, "_", mort19$stem)
mort18$con <- paste0(mort18$tag, "_", mort18$stem)

mort19$status.2015 <- mort18$status.2015[match(mort19$con, mort18$con)]
mort19$status.2016 <- mort18$status.2016[match(mort19$con, mort18$con)]
mort19$status.2017 <- mort18$status..2017[match(mort19$con, mort18$con)]
mort19$status.2018 <- mort18$new.status[match(mort19$con, mort18$con)]

mort19$new.status <- ""

# Add in other columns for the survey
extracols <- setdiff(colnames(mort18), colnames(mort19))
mort19[extracols] <- ""

## Specifically keep in comments from last year
mort19$Old.comments<- mort18$X2018.comments[match(mort19$con, mort18$con)]
setnames(mort19, old="X2018.comments", new="X2019.comments")

# Remove concatenation because was only necessary for copying over status information
irrelevant <- c("codes.2013", "dbh.2013", "status..2017", "con", "stemID", "DBHID", "PlotName", "PlotID", "Family", "Genus", "SpeciesName", "Subspecies", "SpeciesID", "SubspeciesID", "QuadratID", "PX", "PY", "TreeID", "StemNumber", "PrimaryStem", "CensusID", "PlotCensusNumber", "HOM", "ExactDate", "Date", "DBH", "HighHOM", "LargeStem", "Status", "tag_stem")
mort19[irrelevant] <- NULL

# Order before saving
mort19 <- mort19[order(mort19$quadrat, mort19$tag), ]

# Save as csv ####
write.csv(mort19, "C:/Users/terrella3/Dropbox (Smithsonian)/GitHub_Alyssa/SCBI-ForestGEO-Data/tree_mortality/raw data/Mortality_Survey_2019REALLYUPDATED2.csv", row.names = FALSE)

