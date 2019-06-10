#########################################
# Purpose: Script to produce the layout of any future mortality surveys - eliminates "copy-and-paste" method
# Method: Take information from most recent census data and intergrate it with most recent mortality survey data
# Developed by: Alyssa Terrell (terrella3@si.edu) and Ian McGregor (mcgregori@si.edu)
# R version 3.5.2 - Created June 2019
##########################################
# Load in needed packages
library(data.table)

# Load in current census data
census3 <- read.csv("C:/Users/terrella3/Dropbox (Smithsonian)/GitHub_Alyssa/SCBI-ForestGEO-Data_private/census data/ViewFullTable_crc_master.csv", stringsAsFactors=FALSE)

# Label census 3 ID as "new"; label census 1 and 2 as 
"old"
## Will need to update this number for next census
census3$census <- ifelse(census3$CensusID == 3, "new", "old")

census3$DBH <- as.numeric(census3$DBH)
census3$DBH <- ifelse(is.na(census3$DBH), 0, census3$DBH)
census3_new <- census3[census3$census == "new", ]

# load last year's mortality survey to edit for this year
mort18 <- read.csv("C:/Users/terrella3/Dropbox (Smithsonian)/GitHub_Alyssa/SCBI-ForestGEO-Data/tree_mortality/raw data/Mortality_Survey_2018.csv", stringsAsFactors=FALSE)

mort19 <- census3_new[census3_new$Tag %in% mort18$tag | census3_new$DBH >= 100, ]

mort19 <- mort19[names(census3) %in% c("QuadratName", "Tag", "StemTag", "StemID", "Mnemonic", "QX", "QY", "DBH", "ListOfTSM")]

setnames(mort19, old = c("QuadratName", "Tag", "StemTag", "StemID", "Mnemonic", "QX", "QY", "DBH", "ListOfTSM"),
         new = c("quadrat", "tag", "stem", "stemID", "sp", "lx", "ly", "dbh.2018", "codes.2018"))

#copy over the tree statuses from previous surveys
mort19$con <- paste0(mort19$tag, "_", mort19$stem)
mort18$con <- paste0(mort18$tag, "_", mort18$stem)

mort19$status.2015 <- mort18$status.2015[match(mort19$con, mort18$con)]
mort19$status.2016 <- mort18$status.2016[match(mort19$con, mort18$con)]
mort19$status.2017 <- mort18$status..2017[match(mort19$con, mort18$con)]
mort19$status.2018 <- mort18$new.status[match(mort19$con, mort18$con)]

mort19$new.status <- ""

#add in other columns for the survey
extracols <- colnames(mort18[c(13:ncol(mort18))])
mort19[extracols] <- ""

#remove concatenation because was only necessary for copying over status information
mort19$con <- NULL
mort19$stemID <- NULL

write.csv(mort19, "Mortality_Survey_2019.csv", row.names = FALSE)
