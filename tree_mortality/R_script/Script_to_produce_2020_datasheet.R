#Script to create 2020 mortality survey data sheet.
#Adapted from: SCBI-ForestGEO-Data/tree_mortality/R_script/Script_to_produce_all_mort_surveys.R

# clear the environment ####
rm(list = ls())

# Load in needed package
library(data.table)
library(readr)
# Load in data ####
#Read directly from Github as data is public online (and where census 3 data is up-to-date)

census3 <- read_csv("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/scbi.stem3.csv")

mort19 <- read.csv("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_mortality/raw%20data/Mortality_Survey_2019.csv")


# Create a unique ID ####
census3$tag_stem <- paste(census3$tag, census3$StemTag, sep = "_")
mort19$tag_stem <- paste(mort19$tag,  mort19$stem, sep = "_") 

#convert dbh to numeric, introducing NA's instead of NULL
census3$dbh <- as.numeric(census3$dbh)
# Create a new column that will hold the DBH from mort19, matching based on the new unique ID
census3$DBH_2018 <- mort19$dbh.2018[match(census3$tag_stem, mort19$tag_stem)]
# Subset for trees that are DBH >= 100 in census 3 or that are dead (dbh is NA or 0) BUT for which the DBH in mort19 is >= 100 AND all fraxinus and chvi species >= 10


#THIS STILL NEED WORK from here. Converting dbh to numeric gets the list down to 8217, but thats still way short of 10,000. I can't see anything wrong with the ifelse statement. Maybe some trees were missed in the 2018 census?
mort20 <- census3[(!is.na(census3$dbh) & census3$dbh >= 100) | ((is.na(census3$dbh) | census3$dbh == 0) & (!is.na(census3$DBH_2018) & census3$DBH_2018 >= 100)) | (census3$sp %in% c("fram", "frni", "frpe", "frsp","chvi") & !is.na(census3$DBH_2018) & census3$DBH_2018 >= 10), ]

#There are no chvi, unk, or frsp that meet the above requirements. Is this expected?
frax <- subset(mort20, sp == c("fram", "frni", "frpe", "frsp","chvi", "unk"))
unique(frax$sp)
#Remove "unk" species as they have been dead basically since census 2008
mort20 <- subset(mort20, sp != "unk")

# Format mort20 ####
mort20 <- mort20[names(census3) %in% c("quadrat", "tag", "StemTag", "stemID", "sp", "gx", "gy", "dbh", "codes")]

setnames(mort20, old = c("quadrat", "tag", "StemTag", "stemID", "sp", "gx", "gy", "dbh", "codes"),
         new = c("quadrat", "tag", "stem", "stemID", "sp", "lx", "ly", "dbh.2018", "codes.2018"))

# Copy over the tree statuses from previous surveys
mort20$con <- paste0(mort20$tag, "_", mort20$stem)
mort19$con <- paste0(mort19$tag, "_", mort19$stem)

mort20$status.2015 <- mort19$status.2015[match(mort20$con, mort19$con)]
mort20$status.2016 <- mort19$status.2016[match(mort20$con, mort19$con)]
mort20$status.2017 <- mort19$status.2017[match(mort20$con, mort19$con)]
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
