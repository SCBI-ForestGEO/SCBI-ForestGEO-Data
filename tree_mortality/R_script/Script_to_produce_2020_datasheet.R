#Script to create 2020 mortality survey data sheet.
#Adapted from: SCBI-ForestGEO-Data/tree_mortality/R_script/Script_to_produce_all_mort_surveys.R

# clear the environment ####
rm(list = ls())

# Load in needed package
library(data.table)
library(readr)
# Load in data ####

census3 <- read_csv("SCBI-ForestGEO-Data_private/census data/ViewFullTable_crc_master.csv")
mort19 <- read.csv("C:/Users/world/Desktop/Github/SCBI-ForestGEO-Data/tree_mortality/raw data/Mortality_Survey_2019.csv")

# Prepare census 3 ####
census3 <- census3[census3$CensusID %in% 3, ] # Subset to keep only data collected during census 3
census3$DBH <- as.numeric(census3$DBH) # Make sure DBH is a numeric, will coerce NULL to NA

# Create a unique ID ####
census3$tag_stem <- paste(census3$Tag, census3$StemTag, sep = "_")
mort19$tag_stem <- paste(mort19$tag,  mort19$stem, sep = "_") 

# Create a new column that will hold the DBH from mort19, matching based on the new unique ID
census3$DBH_2018 <- mort19$dbh.2018[match(census3$tag_stem, mort19$tag_stem)]

# Subset for trees that are DBH >= 100 in census 3 or that are dead (dbh is NA or 0) in census 3  BUT for which the DBH in mort18 is >= 100 AND all fraxinus species >= 10
## mort19 <- census3[(!is.na(census3$DBH) & census3$DBH >= 100) | ((is.na(census3$DBH) | census3$DBH == 0) & (!is.na(census3$DBH_2018) & census3$DBH >= 100)) | (census3$Mnemonic %in% c("fram", "frni", "frpe", "frsp") & !is.na(census3$DBH) & census3$DBH_2018 >= 10), ]

mort20 <- census3[(!is.na(census3$DBH) & census3$DBH >= 100) | ((is.na(census3$DBH) | census3$DBH == 0) & (!is.na(census3$DBH_2018) & census3$DBH_2018 >= 100)) | (census3$Mnemonic %in% c("fram", "frni", "frpe", "frsp") & !is.na(census3$DBH_2018) & census3$DBH_2018 >= 10), ]

###### remove fraxinus <100? 
mort20 <- census3[(!is.na(census3$DBH) & census3$DBH >= 100) | ((is.na(census3$DBH) | census3$DBH == 0) & (!is.na(census3$DBH_2018) & census3$DBH_2018 >= 100)) , ]

# Format mort20 ####
mort20 <- mort20[names(census3) %in% c("QuadratName", "Tag", "StemTag", "StemID", "Mnemonic", "QX", "QY", "DBH", "ListOfTSM")]

setnames(mort20, old = c("QuadratName", "Tag", "StemTag", "StemID", "Mnemonic", "QX", "QY", "DBH", "ListOfTSM"),
         new = c("quadrat", "tag", "stem", "stemID", "sp", "lx", "ly", "dbh.2018", "codes.2018"))

# Copy over the tree statuses from previous surveys
mort20$con <- paste0(mort20$tag, "_", mort20$stem)
mort19$con <- paste0(mort19$tag, "_", mort19$stem)

mort20$status.2015 <- mort19$status.2015[match(mort20$con, mort19$con)]
mort20$status.2016 <- mort19$status.2016[match(mort20$con, mort19$con)]
mort20$status.2017 <- mort19$status..2017[match(mort20$con, mort19$con)]
mort20$status.2018 <- mort19$status.2018[match(mort20$con, mort19$con)]
mort20$status.2019 <- mort19$new.status[match(mort20$con, mort19$con)]
mort20$new.status <- ""

# Add in other columns for the survey
extracols <- setdiff(colnames(mort19), colnames(mort20))
mort20[extracols] <- ""

## Specifically keep in comments from last year
mort20$Old.comments<- mort19$Old.comments[match(mort20$con, mort19$con)]
setnames(mort20, old="X2019.comments", new="X2020.comments")

# Remove concatenation because was only necessary for copying over status information
irrelevant <- c("codes.2013", "dbh.2013", "status.2017","species", "con", "stemID", "DBHID", "PlotName", "PlotID", "Family", "Genus", "SpeciesName", "Subspecies", "SpeciesID", "SubspeciesID", "QuadratID", "PX", "PY", "TreeID", "StemNumber", "PrimaryStem", "CensusID", "PlotCensusNumber", "HOM", "ExactDate", "Date", "DBH", "HighHOM", "LargeStem", "Status", "tag_stem")
mort20[irrelevant] <- NULL

# Order before saving
mort20 <- mort20[order(mort20$quadrat, mort20$tag), ]

# Save as csv ###
write.csv(mort20, "C:/Users/world/Desktop/Github/SCBI-ForestGEO-Data/tree_mortality/raw data/Mortality_Survey_2020.csv", row.names=FALSE)
