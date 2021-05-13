#############################################################################
# Purpose: clean and merge all mortality census data
# Developped by: Valentine Herrmann - HerrmannV@si.edu
# R version 3.4.4 (2018-03-15)
##########################################################################

# Clean environment ####
rm(list = ls())

# Set working directory ####
setwd(".")

# Load libraries ####


# Load data ####


## We need core ForestGEO census data from 2013 (and also bring 2008 data so that we can have a full record)

for(f in paste0("scbi.stem", 1:3, ".rdata")) {
  print(f)
  url <- paste0("https://raw.github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/", f)
  download.file(url, f, mode = "wb")
  load(f)
  file.remove(f)
}


### get the sppecies table
f = "scbi.spptable.rdata"
url <- paste0("https://raw.github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/", f)
download.file(url, f, mode = "wb")
load(f)
file.remove(f)

## we need all mortality data (raw data)

mort.census.years <- c(2014:2020)

for(survey_year in mort.census.years) {
  print(paste("load mortlity data for year", survey_year))
  
  # load
  mort <- read.csv(paste0("tree_mortality/raw data/Mortality_Survey_", survey_year, ".csv"), stringsAsFactors = F)
  
  # fix column names to be consistant
  names(mort) <- gsub("species", "sp", names(mort))
  # names(mort) <- gsub("codes", "code", names(mort)) # commenting this out to ignor code.2013 that is causing more problem than we need...
  names(mort) <- gsub("previous.condition", paste0("status.", survey_year -1 ), names(mort))
  names(mort) <- gsub("new.condition|new.status", paste0("status.", survey_year ), names(mort))
  names(mort) <- gsub("status\\.\\.","status.", names(mort))
  names(mort) <- gsub("fad\\.", "fad", names(mort))
  names(mort) <- gsub(" ", ".", names(mort))
  names(mort) <- gsub("Comments", "comments", names(mort), ignore.case = F)
  names(mort) <- gsub("Date", "date", names(mort), ignore.case = F)
  names(mort) <- gsub("X2018.comments", "comments", names(mort))
  names(mort) <- gsub("stem", "StemTag", names(mort))
  names(mort) <- gsub("surveyor\\b", "surveyors", names(mort))
  names(mort) <- gsub("X2019.comments", "comments", names(mort))
  
  
  # add columns and fill with NA if they don't exist
  if(!any(grepl("lx", names(mort)))) mort$lx <- NA
  if(!any(grepl("ly", names(mort)))) mort$ly <- NA
  if(!any(grepl("dbh.if.dead", names(mort)))) mort$dbh.if.dead <- NA
  if(!any(grepl("fad4", names(mort)))) mort$fad4 <- NA
  if(!any(grepl("DF", names(mort)))) mort$DF <- NA
  if(!any(grepl("fraxinus.crown.thinning", names(mort)))) mort$fraxinus.crown.thinning <- NA
  if(!any(grepl("fraxinus.epicormic.growth", names(mort)))) mort$fraxinus.epicormic.growth <- NA
  if(!any(grepl("EABF", names(mort)))) mort$EABF <- NA
  if(!any(grepl("DE.count", names(mort)))) mort$DE.count <- NA
  if(!any(grepl("fraxinus.crown.thinning", names(mort)))) mort$fraxinus.crown.thinning <- NA
  
  # padd quadrats with 0
  mort$quadrat <- as.character(  mort$quadrat)
  mort$quadrat <- ifelse(nchar(mort$quadrat) < 4, paste0("0",   mort$quadrat),   mort$quadrat)
  
  # remove extra spaces in statuses
  mort[, paste0("status.", survey_year )] <- trimws(mort[, paste0("status.", survey_year )])
  
  # order the columns the way we want it
  mort <- mort[, c("quadrat", "tag", "StemTag", "sp", "lx", "ly", ifelse(survey_year >= 2019, "dbh.2018", "dbh.2013"),
                   grep("status", names(mort), value = T), "dbh.if.dead",
                   "perc.crown", "crown.position", "fad1", "fad2", "fad3", "fad4",
                   "DF", "liana.load", "fraxinus.crown.thinning", "fraxinus.epicormic.growth",
                   "EABF","DE.count", "comments", "date", "surveyors")]
  
  # save
  assign(paste0("mort", substr(survey_year, 3,4)), mort)
}

# Calculate allometries ####
f = "scbi_Allometries.R"
url <- paste0("https://raw.github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/R_scripts/", f)
download.file(url, f, mode = "wb")

# on full census
for(census in paste0("scbi.stem", 1:3)) {
  x <- get(census)
  x$dbh <- as.numeric(x$dbh) # not numeric because of the "NULL" values
  source(f)
  assign(census, x)
}

# on dbh.if.dead for mortality censuses

for(survey_year in mort.census.years) {
  mort <- get(paste0("mort", substr(survey_year, 3,4)))
  mort$dbh.if.dead <- as.numeric(mort$dbh.if.dead)
  
  x <- mort[, c("tag", "sp", "dbh.if.dead" )]
  x$dbh <- x$dbh.if.dead
  
  source(f)
  
  mort$agb.if.dead <- x$agb
  
  assign(paste0("mort", substr(survey_year, 3,4)), mort)
  
}



# remove allometry file

file.remove(f)



# order rows the same way as year 2018 ###

## first find out if all tags exist in core census data and fix any problem with that
tag_stem_in_order <- paste(scbi.stem3$tag, scbi.stem3$StemTag, sep = "_")

for(survey_year in mort.census.years) {
  print(survey_year)
  
  mort <- get(paste0("mort", substr(survey_year, 3, 4)))
  tag_stems <- paste(mort$tag, mort$StemTag, sep = "_")
  
  if(!all(tag_stems %in% tag_stem_in_order)) {
    print("Not all tags are in core census")
    
    tag_stems[which(!tag_stems %in% tag_stem_in_order)]
    print(mort[ paste(mort$tag, mort$StemTag, sep = "_") %in% tag_stems[which(!tag_stems %in% tag_stem_in_order)], ])
  }
}

### FIXING PrOBLEMES:

### mort20 has 31 blank rows at the end of its dataframe fore some reason
mort20 <- mort20[!is.na(mort20$tag),]

#### the tag and species ID issue: In full census data, tag 33331 appears 2 times. Looking like a 2-stem quru. In 2014 it was found that the biggest stem was actually tagged with tag 30365. The tag number was changed only in mortality census 2017 and Maya and Ryan ID-ed that second stem as fram. but the species ID was never changed. I am fixing that in all mortality related data now, by changin tag# StemTag and species in all dataframes. BUT, after 2018 main census, it seems that instructions were given to Suzanne Lao to change the tag number but on both stems.... so we end up with the same issue of having tag 30365 appearing 2 times, with same StemTag #1... So I'll, ignore that for now but eventually, this will need to be fixed.
### issue put in github that might explain this better:
# 33331 vs 30365: Up until the 2018 main census, in full census data, tag 33331 appeared 2 times with same StemTag 1, looking like a 2-stem quru with wrong StemTag on smaller stem. In 2014 it was found that the biggest stem was actually tagged with tag 30365. The tag number was changed only in mortality census 2017 and Maya and Ryan ID-ed that second stem as being a fram, but the species ID was never changed in the data sets.
# So it seems that the truth would be:
# 33331 1 quru 161.2
# 30365 1 fram 992.0
#
# BUT, after 2018 main census, it seems that instructions were given to Suzanne Lao to change the tag number and species of BOTH stems, instead of the biggest stem only. So tag 33331 disappeared and we ended up with the same issue of having tag 30365 StemTag 1 appearing 2 times (but this time on a fram).
#
# So:
# Long term solution: tell Suzanne that smaller stem is a quru with tag 33331.
# Short term solution (for building new master mortality census data) changing 33331 quru to 30365 fram AND, for here, put a StemTag = 2 to smaller stem


scbi.stem1[scbi.stem1$tag %in% 33331,]; scbi.stem1[scbi.stem1$tag %in% 30365,]
scbi.stem2[scbi.stem2$tag %in% 33331,]; scbi.stem2[scbi.stem2$tag %in% 30365,]
scbi.stem3[scbi.stem3$tag %in% 33331,]; scbi.stem3[scbi.stem3$tag %in% 30365,]

mort14[mort14$tag %in% 33331, ]; mort14[mort14$tag %in% 30365, ]
mort15[mort15$tag %in% 33331, ]; mort15[mort15$tag %in% 30365, ]
mort16[mort16$tag %in% 33331, ]; mort16[mort16$tag %in% 30365, ]
mort17[mort17$tag %in% 33331, ]; mort17[mort17$tag %in% 30365, ]
mort18[mort18$tag %in% 33331, ]; mort18[mort18$tag %in% 30365, ]
mort19[mort19$tag %in% 33331, ]; mort19[mort19$tag %in% 30365, ]
mort20[mort20$tag %in% 33331, ]; mort20[mort20$tag %in% 30365, ]


# # original and correct fix, before main census were wrongly corrected...
#
# mort14[mort14$tag %in% 33331, ]$StemTag <- c(1, 1)
# mort15[mort15$tag %in% 33331, ]$StemTag <- c(1, 1)
# mort16[mort16$tag %in% 33331, ]$StemTag <- c(1, 1)
#
#
# scbi.stem1[scbi.stem1$tag %in% 33331,]$sp <- c("fram", "quru")
# scbi.stem2[scbi.stem2$tag %in% 33331,]$sp <- c("fram", "quru")
# mort14[mort14$tag %in% 33331, ]$sp <- c("fram", "quru")
# mort15[mort15$tag %in% 33331, ]$sp <- c("quru", "fram")
# mort16[mort16$tag %in% 33331, ]$sp <-  c("quru", "fram")
#
# scbi.stem1[scbi.stem1$tag %in% 33331,]$tag <- c(30365, 33331)
# scbi.stem2[scbi.stem2$tag %in% 33331,]$tag <- c(30365, 33331)
# mort14[mort14$tag %in% 33331, ]$tag <- c(30365, 33331)
# mort15[mort15$tag %in% 33331, ]$tag <- c(33331, 30365)
# mort16[mort16$tag %in% 33331, ]$tag <- c(33331, 30365)



mort14[mort14$tag %in% 33331, ]$sp <- c("fram", "fram")
mort15[mort15$tag %in% 33331, ]$sp <- c("fram", "fram")
mort16[mort16$tag %in% 33331, ]$sp <-  c("fram", "fram")
mort17[mort17$tag %in% 33331, ]$sp <-  "fram"
mort18[mort18$tag %in% 33331, ]$sp <-  "fram"

mort14[mort14$tag %in% 33331, ]$tag <- 30365
mort15[mort15$tag %in% 33331, ]$tag <- 30365
mort16[mort16$tag %in% 33331, ]$tag <- 30365
mort17[mort17$tag %in% 33331, ]$tag <- 30365
mort18[mort18$tag %in% 33331, ]$tag <- 30365


scbi.stem1[scbi.stem1$tag %in% 30365,]$StemTag <- c(1,2)[order(scbi.stem1[scbi.stem1$tag %in% 30365,]$dbh, decreasing = T)]
scbi.stem2[scbi.stem2$tag %in% 30365,]$StemTag <- c(1,2)[order(scbi.stem1[scbi.stem1$tag %in% 30365,]$dbh, decreasing = T)]
scbi.stem3[scbi.stem3$tag %in% 30365,]$StemTag <- c(1,2)[order(scbi.stem1[scbi.stem1$tag %in% 30365,]$dbh, decreasing = T)]

mort14[mort14$tag %in% 30365, ]$StemTag <- c(1,2)[order(mort14[mort14$tag %in% 30365,]$dbh.2013 , decreasing = T)]
mort15[mort15$tag %in% 30365, ]$StemTag <- c(1,2)[order(mort15[mort15$tag %in% 30365,]$dbh.2013, decreasing = T)]
mort16[mort16$tag %in% 30365, ]$StemTag <- c(1,2)[order(mort16[mort16$tag %in% 30365,]$dbh.2013, decreasing = T)]
mort17[mort17$tag %in% 30365, ]$StemTag <- c(1,2)[order(mort17[mort17$tag %in% 30365,]$dbh.2013, decreasing = T)]
mort18[mort18$tag %in% 30365, ]$StemTag <- c(1,2)[order(mort18[mort18$tag %in% 30365,]$dbh.2013, decreasing = T)]
mort19[mort19$tag %in% 30365, ]$StemTag <- c(1,2)[order(mort19[mort19$tag %in% 30365,]$dbh.2018, decreasing = T)]
mort20[mort20$tag %in% 30365, ]$StemTag <- c(1,2)[order(mort20[mort20$tag %in% 30365,]$dbh.2018, decreasing = T)]



#### "tag 133461 StemTag 1 (bigger stem) (quadrat 1316, comment in 2015: Ojo:this is not caco, it is fram. Not 2 stem! Fram tag=131352)"
## looks like the bigger stem has a different tag and is fram. After 2018 main census, the tag and species were fixed but the species of the smaller stem (tag 133461), which was originally caco, was also changed to fram, not sure if it was made on purpose. I will do the same here...

scbi.stem1[scbi.stem1$tag %in% 133461,]; scbi.stem1[scbi.stem1$tag %in% 131352,]
scbi.stem2[scbi.stem2$tag %in% 133461,]; scbi.stem2[scbi.stem2$tag %in% 131352,]
scbi.stem3[scbi.stem3$tag %in% 133461,]; scbi.stem3[scbi.stem3$tag %in% 131352,]

mort14[mort14$tag %in% 133461, ]; mort14[mort14$tag %in% 131352, ]
mort15[mort15$tag %in% 133461, ]; mort15[mort15$tag %in% 131352, ]
mort16[mort16$tag %in% 133461, ]; mort16[mort16$tag %in% 131352, ]
mort17[mort17$tag %in% 133461, ]; mort17[mort17$tag %in% 131352, ]
mort18[mort18$tag %in% 133461, ]; mort18[mort18$tag %in% 131352, ]
mort19[mort19$tag %in% 133461, ]; mort19[mort19$tag %in% 131352, ]
mort20[mort20$tag %in% 133461, ]; mort20[mort20$tag %in% 131352, ]


# scbi.stem1[scbi.stem1$tag %in% 133461 & scbi.stem1$dbh > 900, ]$sp <- "fram"
# scbi.stem2[scbi.stem2$tag %in% 133461 & scbi.stem2$dbh > 900, ]$sp <- "fram"
# scbi.stem1[scbi.stem1$tag %in% 133461 & scbi.stem1$dbh < 900, ]$StemTag <- 1
# scbi.stem2[scbi.stem2$tag %in% 133461 & scbi.stem2$dbh < 900, ]$StemTag <- 1
# scbi.stem1[scbi.stem1$tag %in% 133461 & scbi.stem1$dbh > 900, ]$tag <- 131352
# scbi.stem2[scbi.stem2$tag %in% 133461 & scbi.stem2$dbh > 900, ]$tag <- 131352

mort14[mort14$tag %in% 133461, ]$sp <- "fram"
mort14[mort14$tag %in% 133461 & mort14$dbh.2013 < 900, ]$StemTag <- 1
mort14[mort14$tag %in% 133461 & mort14$dbh.2013 > 900, ]$tag <- 131352


mort15[mort15$tag %in% 133461, ]$sp <- "fram"
mort15[mort15$tag %in% 133461 & mort15$dbh.2013 < 900, ]$StemTag <- 1
mort15[mort15$tag %in% 133461 & mort15$dbh.2013 > 900, ]$tag <- 131352


mort16[mort16$tag %in% 133461, ]$sp <- "fram"
mort16 <- mort16[!(mort16$tag %in% 133461 & mort16$dbh.2013 > 900), ]
mort16[mort16$tag %in% 133461 & mort16$dbh.2013 < 900, ]$StemTag <- 1

# mort16[mort16$tag %in% 133461 & mort16$dbh.2013 > 900, ]$sp <- "fram"
# mort16[mort16$tag %in% 133461 & mort16$dbh.2013 < 900, ]$StemTag <- 1
# mort16[mort16$tag %in% 133461 & mort16$dbh.2013 > 900, ]$tag <- 131352

mort17[mort17$tag %in% 133461, ]$sp <- "fram"
mort17 <- mort17[!(mort17$tag %in% 133461 & mort17$dbh.2013 > 900), ]
mort17[mort17$tag %in% 133461 & mort17$dbh.2013 < 900, ]$StemTag <- 1

# mort17[mort17$tag %in% 133461 & mort17$dbh.2013 > 900, ]$sp <- "fram"
# mort17[mort17$tag %in% 133461 & mort17$dbh.2013 < 900, ]$StemTag <- 1
# mort17[mort17$tag %in% 133461 & mort17$dbh.2013 > 900, ]$tag <- 131352

mort18[mort18$tag %in% 133461, ]$sp <- "fram"
mort18 <- mort18[!(mort18$tag %in% 131352 & mort18$EABF %in% "AS;W;DE"),]
# mort18[mort18$tag %in% 133461 & mort18$dbh.2013 > 900, ]$sp <- "fram"
# mort18[mort18$tag %in% 133461 & mort18$dbh.2013 < 900, ]$StemTag <- 1
# mort18[mort18$tag %in% 133461 & mort18$dbh.2013 > 900, ]$tag <- 131352


# 170982 is fram and not liriodendron
scbi.stem1[scbi.stem1$tag %in% 170982,]
scbi.stem2[scbi.stem2$tag %in% 170982,]
scbi.stem3[scbi.stem3$tag %in% 170982,]
mort14[mort14$tag %in% 170982, ]$sp <- "fram"
mort15[mort15$tag %in% 170982, ]$sp <- "fram"
mort16[mort16$tag %in% 170982, ]$sp <- "fram"
mort17[mort17$tag %in% 170982, ]$sp <- "fram"
mort18[mort18$tag %in% 170982, ]$sp <- "fram"
mort19[mort19$tag %in% 170982, ]$sp
mort20[mort20$tag %in% 170982, ]$sp

## fixing dbh issues ####
scbi.stem1[scbi.stem1$tag %in% 190691 & scbi.stem1$StemTag == 1, ]$dbh
scbi.stem2[scbi.stem2$tag %in% 190691 & scbi.stem2$StemTag == 1, ]$dbh
scbi.stem3[scbi.stem3$tag %in% 190691 & scbi.stem3$StemTag == 1, ]$dbh
mort14[mort14$tag %in% 190691, ]$dbh.2013
mort15[mort15$tag %in% 190691, ]$dbh.2013
mort16[mort16$tag %in% 190691, ]$dbh.2013 <- 32.8
mort17[mort17$tag %in% 190691, ]$dbh.2013 <- 32.8
mort18[mort18$tag %in% 190691, ]$dbh.2013
mort19[mort19$tag %in% 190691, ]$dbh.2013


scbi.stem2[scbi.stem2$tag %in% 203751, ]$dbh
mort14[mort14$tag %in% 203751, ]$dbh.2013 <- 14.3
mort15[mort15$tag %in% 203751, ]$dbh.2013 <- 14.3
mort16[mort16$tag %in% 203751, ]$dbh.2013 <- 14.3
mort17[mort17$tag %in% 203751, ]$dbh.2013 <- 14.3
mort18[mort18$tag %in% 203751, ]$dbh.2013
mort19[mort19$tag %in% 203751, ]$dbh.2013


scbi.stem2[scbi.stem2$tag %in% 80560, ]
mort14[mort14$tag %in% 80560, ]
mort15[mort15$tag %in% 80560, ]
mort16[mort16$tag %in% 80560, ]
mort17[mort17$tag %in% 80560, ]
mort18[mort18$tag %in% 80560, ]
mort19[mort19$tag %in% 80560, ]

mort14 <- mort14[-which(mort14$tag %in% 80560 & mort14$StemTag %in% 2), ]
mort16 <- mort16[-which(mort16$tag %in% 80560 & mort16$StemTag %in% 2), ]
mort17 <- mort17[-which(mort17$tag %in% 80560 & mort17$StemTag %in% 2), ]
mort18 <- mort18[-which(mort18$tag %in% 80560 & mort18$StemTag %in% 2), ]
mort19 <- mort19[-which(mort19$tag %in% 80560 & mort19$StemTag %in% 2), ]
mort20 <- mort20[-which(mort20$tag %in% 80560 & mort20$StemTag %in% 2), ]


scbi.stem2[scbi.stem2$tag %in% 172262, ]$dbh
scbi.stem3[scbi.stem3$tag %in% 172262, ]$dbh
mort14[mort14$tag %in% 172262, ]$dbh.2013
mort15[mort15$tag %in% 172262, ]$dbh.2013
mort16[mort16$tag %in% 172262, ]$dbh.2013
mort17[mort17$tag %in% 172262, ]$dbh.2013
mort18[mort18$tag %in% 172262, ]$dbh.2013
mort19[mort19$tag %in% 172262, ]$dbh.2013

mort17[mort17$tag %in% 172262, ]$dbh.2013 <- 170.7

scbi.stem3[scbi.stem3$tag %in% 172262, ]

row_to_add <- mort17[mort17$tag %in% 172262, ]
row_to_add$date <- unique(mort18[mort18$quadrat %in% 1720, ]$date)
row_to_add$surveyors <- unique(mort18[mort18$quadrat %in% 1720, ]$surveyors)
row_to_add$status.2018 <- "A"
mort18 <- rbind(mort18, row_to_add)


row_to_add$date <- unique(mort19[mort19$quadrat %in% 1720, ]$date)
row_to_add$surveyors <- unique(mort19[mort19$quadrat %in% 1720, ]$surveyors)
row_to_add$status.2019 <- "A"
names(row_to_add) <- gsub("dbh.2013", "dbh.2018",  names(row_to_add))
row_to_add$dbh.2018 <- scbi.stem3[scbi.stem3$tag %in% 172262, ]$dbh



scbi.stem1[!is.na(scbi.stem1$dbh) & scbi.stem1$dbh < 1, ]$dbh
# scbi.stem2[!is.na(scbi.stem2$dbh) & scbi.stem2$dbh < 1, ]$dbh <- NA


#### Fixing quadrat issues ####

# not quite sure what is right but will follow main census...

quadrat.317 <- scbi.stem1$quadrat %in% "0317"
quadrat.319 <- scbi.stem1$quadrat %in% "0319"

all(scbi.stem2$quadrat[quadrat.317] %in% "0317") # should be TRUE
all(scbi.stem3$quadrat[quadrat.317] %in% "0317") # should be TRUE

all(scbi.stem2$quadrat[quadrat.319] %in% "0319") # should be TRUE
all(scbi.stem3$quadrat[quadrat.319] %in% "0319") # should be TRUE


all(mort14$quadrat[mort14$tag %in% scbi.stem1$tag[quadrat.317]] %in% "0317") # should be TRUE --> is not
all(mort15$quadrat[mort15$tag %in% scbi.stem1$tag[quadrat.317]] %in% "0317") # should be TRUE
all(mort16$quadrat[mort16$tag %in% scbi.stem1$tag[quadrat.317]] %in% "0317") # should be TRUE
all(mort17$quadrat[mort17$tag %in% scbi.stem1$tag[quadrat.317]] %in% "0317") # should be TRUE
all(mort18$quadrat[mort18$tag %in% scbi.stem1$tag[quadrat.317]] %in% "0317") # should be TRUE
all(mort19$quadrat[mort19$tag %in% scbi.stem1$tag[quadrat.317]] %in% "0317") # should be TRUE

all(mort14$quadrat[mort14$tag %in% scbi.stem1$tag[quadrat.319]] %in% "0319") # should be TRUE--> is not
all(mort15$quadrat[mort15$tag %in% scbi.stem1$tag[quadrat.319]] %in% "0319") # should be TRUE--> is not
all(mort16$quadrat[mort16$tag %in% scbi.stem1$tag[quadrat.319]] %in% "0319") # should be TRUE--> is not
all(mort17$quadrat[mort17$tag %in% scbi.stem1$tag[quadrat.319]] %in% "0319") # should be TRUE--> is not
all(mort18$quadrat[mort18$tag %in% scbi.stem1$tag[quadrat.319]] %in% "0319") # should be TRUE--> is not
all(mort19$quadrat[mort19$tag %in% scbi.stem1$tag[quadrat.319]] %in% "0319") # should be TRUE


mort14$quadrat[mort14$tag %in% scbi.stem1$tag[quadrat.317]] <- "0317"

mort14$quadrat[mort14$tag %in% scbi.stem1$tag[quadrat.319]] <- "0319"
mort15$quadrat[mort15$tag %in% scbi.stem1$tag[quadrat.319]] <- "0319"
mort16$quadrat[mort16$tag %in% scbi.stem1$tag[quadrat.319]] <- "0319"
mort17$quadrat[mort17$tag %in% scbi.stem1$tag[quadrat.319]] <- "0319"
mort18$quadrat[mort18$tag %in% scbi.stem1$tag[quadrat.319]] <- "0319"




# quadrat.317 <- scbi.stem1$quadrat %in% "0317" | scbi.stem1$tag %in% 33339
# quadrat.319 <- scbi.stem1$quadrat %in% "0319" & !scbi.stem1$tag %in% 33339
# scbi.stem1[quadrat.317, ]$quadrat <- "0319"
# scbi.stem1[quadrat.319, ]$quadrat <- "0317"
#
# quadrat.317 <- scbi.stem2$quadrat %in% "0317" | scbi.stem2$tag %in% 33339
# quadrat.319 <- scbi.stem2$quadrat %in% "0319" & !scbi.stem2$tag %in% 33339
# scbi.stem2[quadrat.317, ]$quadrat <- "0319"
# scbi.stem2[quadrat.319, ]$quadrat <- "0317"
#
# quadrat.317 <- mort14$quadrat %in% "0317" | mort14$tag %in% 33339
# quadrat.319 <- mort14$quadrat %in% "0319" & !mort14$tag %in% 33339
# mort14[quadrat.317, ]$quadrat <- "0319"
# mort14[quadrat.319, ]$quadrat <- "0317"
#
# tag.32081.in.317 <- mort15$tag %in% 32081
# mort15$quadrat[tag.32081.in.317] <- "0317"
# tag.32081.in.317 <- mort16$tag %in% 32081
# mort16$quadrat[tag.32081.in.317] <- "0317"
# tag.32081.in.317 <- mort17$tag %in% 32081
# mort17$quadrat[tag.32081.in.317] <- "0317"
# tag.32081.in.317 <- mort18$tag %in% 32081
# mort18$quadrat[tag.32081.in.317] <- "0317"
#
#
# tag.32021.32068.in.319 <- mort15$tag %in% c(32021, 32068)
# mort15$quadrat[tag.32021.32068.in.319] <- "0319"
# tag.32021.32068.in.319 <- mort16$tag %in% c(32021, 32068)
# mort16$quadrat[tag.32021.32068.in.319] <- "0319"
# tag.32021.32068.in.319 <- mort17$tag %in% c(32021, 32068)
# mort17$quadrat[tag.32021.32068.in.319] <- "0319"
# tag.32021.32068.in.319 <- mort18$tag %in% c(32021, 32068)
# mort18$quadrat[tag.32021.32068.in.319] <- "0319"




quadrat.609 <- scbi.stem1$quadrat %in% "0609"
quadrat.608 <- scbi.stem1$quadrat %in% "0608"

all(scbi.stem2$quadrat[quadrat.609] %in% "0609") # should be TRUE
all(scbi.stem3$quadrat[quadrat.609] %in% "0609") # should be TRUE

all(scbi.stem2$quadrat[quadrat.608] %in% "0608") # should be TRUE
all(scbi.stem3$quadrat[quadrat.608] %in% "0608") # should be TRUE


all(mort14$quadrat[mort14$tag %in% scbi.stem1$tag[quadrat.609]] %in% "0609") # should be TRUE
all(mort15$quadrat[mort15$tag %in% scbi.stem1$tag[quadrat.609]] %in% "0609") # should be TRUE
all(mort16$quadrat[mort16$tag %in% scbi.stem1$tag[quadrat.609]] %in% "0609") # should be TRUE
all(mort17$quadrat[mort17$tag %in% scbi.stem1$tag[quadrat.609]] %in% "0609") # should be TRUE
all(mort18$quadrat[mort18$tag %in% scbi.stem1$tag[quadrat.609]] %in% "0609") # should be TRUE
all(mort19$quadrat[mort19$tag %in% scbi.stem1$tag[quadrat.609]] %in% "0609") # should be TRUE

all(mort14$quadrat[mort14$tag %in% scbi.stem1$tag[quadrat.608]] %in% "0608") # should be TRUE
all(mort15$quadrat[mort15$tag %in% scbi.stem1$tag[quadrat.608]] %in% "0608") # should be TRUE
all(mort16$quadrat[mort16$tag %in% scbi.stem1$tag[quadrat.608]] %in% "0608") # should be TRUE
all(mort17$quadrat[mort17$tag %in% scbi.stem1$tag[quadrat.608]] %in% "0608") # should be TRUE--> is not
all(mort18$quadrat[mort18$tag %in% scbi.stem1$tag[quadrat.608]] %in% "0608") # should be TRUE--> is not
all(mort19$quadrat[mort19$tag %in% scbi.stem1$tag[quadrat.608]] %in% "0608") # should be TRUE
all(mort20$quadrat[mort20$tag %in% scbi.stem1$tag[quadrat.608]] %in% "0608") # should be TRUE

mort17$quadrat[mort17$tag %in% scbi.stem1$tag[quadrat.608]] <- "0608"
mort18$quadrat[mort18$tag %in% scbi.stem1$tag[quadrat.608]] <- "0608"


# tag 40873 StemTag 2 does not exist in the database after 2018 census... trying to fix mort to main census here...
scbi.stem1[scbi.stem1$tag %in% "40873",]; scbi.stem1[scbi.stem1$tag %in% "40874",]
scbi.stem2[scbi.stem2$tag %in% "40873",]; scbi.stem2[scbi.stem2$tag %in% "40874",]
scbi.stem3[scbi.stem3$tag %in% "40873",]; scbi.stem3[scbi.stem3$tag %in% "40874",]
mort14[mort14$tag %in% "40873", ] ; mort14[mort14$tag %in% "40874", ]
mort15[mort15$tag %in% "40873", ] ; mort14[mort14$tag %in% "40874", ]
mort16[mort16$tag %in% "40873", ] ; mort16[mort16$tag %in% "40874", ]
mort17[mort17$tag %in% "40873", ] ; mort17[mort17$tag %in% "40874", ]
mort18[mort18$tag %in% "40873", ] ; mort18[mort18$tag %in% "40874", ]
mort19[mort19$tag %in% "40873", ] ; mort19[mort19$tag %in% "40874", ]
mort20[mort20$tag %in% "40873", ] ; mort20[mort20$tag %in% "40874", ]

mort14[mort14$tag %in% "40873" & mort14$StemTag %in% 1, ]$sp <- "quve"
mort14[mort14$tag %in% "40873" & mort14$StemTag %in% 2, ]$tag <- "40874"

mort15[mort15$tag %in% "40873" & mort15$StemTag %in% 1, ]$sp <- "quve"
mort15[mort15$tag %in% "40873" & mort15$StemTag %in% 2, ]$tag <- "40874"

mort16[mort16$tag %in% "40873" & mort16$StemTag %in% 1, ]$sp <- "quve"
mort16[mort16$tag %in% "40873" & mort16$StemTag %in% 2, ]$tag <- "40874"

mort17[mort17$tag %in% "40873" & mort17$StemTag %in% 1, ]$sp <- "quve"
mort17[mort17$tag %in% "40873" & mort17$StemTag %in% 2, ]$tag <- "40874"

mort18[mort18$tag %in% "40873" & mort18$StemTag %in% 1, ]$sp <- "quve"
mort18[mort18$tag %in% "40873" & mort18$StemTag %in% 2, ]$tag <- "40874"


# scbi.stem1[scbi.stem1$tag %in% t & scbi.stem1$dbh > 600, ]$tag <- "40874"
# scbi.stem2[scbi.stem2$tag %in% t & scbi.stem2$dbh > 600, ]$tag <- "40874"
# mort14[mort14$tag %in% t, ] ; mort14[mort14$tag %in% 40874, ]
# mort15[mort15$tag %in% t, ] ; mort14[mort14$tag %in% 40874, ]
# mort16[mort16$tag %in% t, ] ; mort16[mort16$tag %in% 40874, ]
# mort17[mort17$tag %in% t, ] ; mort17[mort17$tag %in% 40874, ]
# mort18[mort18$tag %in% t, ] ; mort18[mort18$tag %in% 40874, ]

## fixing species ID issues ####
tags_to_fix <- c("92425", "12269", "20655", "30097", "30262", "32197", "32416",
                 "42175", "42349", "42522", "62307", "72059", "80007", "90268",
                 "90281", "90357", "91454", "92444", "100533", "100623", "100647",
                 "112412", "122117", "131272", "150278", "180838", "180973", "190136",
                 "103217")

for(t in tags_to_fix) {
  idx_main <- scbi.stem1$tag %in% t
  if( all(c(scbi.stem1$sp[idx_main], scbi.stem2$sp[idx_main], scbi.stem3$sp[idx_main]) %in% scbi.stem1$sp[idx_main]) & length(unique(scbi.stem1$sp[idx_main] == 1))) {
    mort14$sp[mort14$tag %in% t] <- unique(scbi.stem1$sp[idx_main])
    mort15$sp[mort15$tag %in% t] <- unique(scbi.stem1$sp[idx_main])
    mort16$sp[mort16$tag %in% t] <- unique(scbi.stem1$sp[idx_main])
    mort17$sp[mort17$tag %in% t] <- unique(scbi.stem1$sp[idx_main])
    mort18$sp[mort18$tag %in% t] <- unique(scbi.stem1$sp[idx_main])
    mort19$sp[mort19$tag %in% t] <- unique(scbi.stem1$sp[idx_main])
  } else { stop("species ID are not the same accross main censuses")}
}


## fix some status ####
mort16$status.2016[mort16$tag %in% 92465] <- "PD"
mort16$status.2016[mort16$tag %in% 40853 & mort16$dbh.2013 %in% 297.5] <- "AU"

# mort16.status.2016 should be fixed to "PD" for 92465 (fixed earlier), is correct for 40853 302.5, and should be "AU" for 40853 297.5 (fixed earlier)


# double checking that all tags exist now ####

tag_stem_in_order <- paste(scbi.stem3$tag, scbi.stem3$StemTag, sep = "_")

All_mortality_tag_stems <- NULL
for(survey_year in mort.census.years) {
  print(survey_year)
  
  mort <- get(paste0("mort", substr(survey_year, 3, 4)))
  tag_stems <- paste(mort$tag, mort$StemTag, sep = "_")
  
  if(!all(tag_stems %in% tag_stem_in_order)) {
    print("Not all tags are in core census")
    
    tag_stems[which(!tag_stems %in% tag_stem_in_order)]
    print(mort[ paste(mort$tag, mort$StemTag, sep = "_") %in% tag_stems[which(!tag_stems %in% tag_stem_in_order)], ])
  }
  
  All_mortality_tag_stems <- c(All_mortality_tag_stems, paste(mort$tag, mort$StemTag, sep = "_"))
}
#--> if no data shows up, good!

## Now re-order all data frames to be in the same format
All_mortality_tag_stems <- unique(All_mortality_tag_stems)
length(All_mortality_tag_stems)

all(All_mortality_tag_stems %in% tag_stem_in_order ) # has to be TRUE

scbi.stem1 <- scbi.stem1[tag_stem_in_order %in% All_mortality_tag_stems, ]
scbi.stem2 <- scbi.stem2[tag_stem_in_order %in% All_mortality_tag_stems, ]
scbi.stem3 <- scbi.stem3[tag_stem_in_order %in% All_mortality_tag_stems, ]

tag_stem_in_order <- tag_stem_in_order[tag_stem_in_order %in% All_mortality_tag_stems]


all(tag_stem_in_order == paste(scbi.stem2$tag, scbi.stem2$StemTag, sep = "_")) # has to be TRUE

for(survey_year in mort.census.years) {
  print(survey_year)
  
  mort <- get(paste0("mort", substr(survey_year, 3, 4)))
  tag_stems <- paste(mort$tag, mort$StemTag, sep = "_")
  
  m <- match(tag_stem_in_order, tag_stems)
  mort <- mort[m, ]
  assign(paste0("mort", substr(survey_year, 3,4)), mort)
  
  print(dim(mort))
  
}


## Now we double check that all match well and fix what does not... ####

all(apply(cbind(scbi.stem1$tag, scbi.stem2$tag, mort14$tag, mort15$tag, mort16$tag, mort17$tag, mort18$tag, mort18$tag), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) # has to be TRUE

all(apply(cbind(scbi.stem1$StemTag, scbi.stem2$StemTag, mort14$StemTag, mort15$StemTag, mort16$StemTag, mort17$StemTag, mort18$StemTag, mort19$StemTag), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) # has to be TRUE


all(apply(round(cbind(scbi.stem2$dbh, mort14$dbh.2013, mort15$dbh.2013, mort16$dbh.2013, mort17$dbh.2013, mort18$dbh.2013), 2), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) #should be TRUE

cbind(scbi.stem1$quadrat, scbi.stem1$tag, as.character(scbi.stem1$sp), scbi.stem1$dbh, as.character(scbi.stem1$status), scbi.stem2$dbh, as.character(scbi.stem2$status),mort14$dbh.2013, mort15$dbh.2013, mort16$dbh.2013, mort17$dbh.2013, mort18$dbh.2013)[!apply(round(cbind(scbi.stem2$dbh, mort14$dbh.2013, mort15$dbh.2013, mort16$dbh.2013, mort17$dbh.2013, mort18$dbh.2013), 2), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] )), ] # most of the problems here are just due to trees that died and or grew or resprouted or problem that will be fixed if we only keep dbh in 2013. Bigger problems were fixed earlier in the script

all(apply(round(cbind(scbi.stem3$dbh, mort19$dbh.2018), 2), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) #should be TRUE

cbind(scbi.stem3$quadrat, scbi.stem3$tag, as.character(scbi.stem3$sp), scbi.stem3$dbh, as.character(scbi.stem3$status), mort19$dbh.2018)[!apply(round(cbind(scbi.stem3$dbh, mort19$dbh.2018), 2), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] )), ]



all(apply(cbind(scbi.stem1$quadrat, scbi.stem2$quadrat, scbi.stem3$quadrat, mort14$quadrat, mort15$quadrat, mort16$quadrat, mort17$quadrat, mort18$quadrat, mort19$quadrat), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) # Has to be TRUE (fixed (problem of 317 and 319 mostly))

cbind( scbi.stem1$tag, scbi.stem1$quadrat, scbi.stem2$quadrat, scbi.stem3$quadrat, mort14$quadrat, mort15$quadrat, mort16$quadrat, mort17$quadrat, mort18$quadrat, mort19$quadrat)[!apply(cbind(scbi.stem2$quadrat, mort14$quadrat, mort15$quadrat, mort16$quadrat, mort17$quadrat, mort18$quadrat), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] )), ]


all(apply(cbind(scbi.stem1$sp, scbi.stem2$sp, scbi.stem3$sp, mort14$sp, mort15$sp, mort16$sp, mort17$sp, mort18$sp, mort19$sp), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) # Has to be TRUE -  (fixed problems above, keeping fill census species ID for now)

cbind( scbi.stem1$tag, scbi.stem1$sp,scbi.stem2$sp, scbi.stem3$sp, mort14$sp, mort15$sp, mort16$sp, mort17$sp, mort18$sp, mort19$sp)[!apply(cbind(scbi.stem1$sp, scbi.stem2$sp, mort14$sp, mort15$sp, mort16$sp, mort17$sp, mort18$sp), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] )), ] # keeping full census species ID for now.


# status in 2013

table(as.character(scbi.stem2$codes), as.character(scbi.stem2$DFstatus))

# status in 2014 # big problems... # will ignore all but in actual 2014 year
data.frame( scbi.stem1$quadrat,  scbi.stem1$tag, scbi.stem1$sp, scbi.stem2$dbh, scbi.stem2$status, mort14$status.2014, mort15$status.2014, mort16$status.2014)[(!apply(cbind(mort14$status.2014, mort15$status.2014, mort16$status.2014), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) & scbi.stem2$dbh >= 100 & !is.na(scbi.stem2$dbh), ]

# status in 2015
data.frame( scbi.stem1$quadrat,  scbi.stem1$tag, scbi.stem1$sp, scbi.stem2$dbh, mort15$status.2015, mort16$status.2015, mort17$status.2015, mort18$status.2015, mort19$status.2015)[!apply(cbind(mort15$status.2015, mort16$status.2015, mort17$status.2015, mort18$status.2015, mort19$status.2015), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] )), ] # mort15$status.2015 correct for 10346, 20134, 190691, 83043

# status in 2016
data.frame( scbi.stem1$quadrat,  scbi.stem1$tag, scbi.stem1$sp, scbi.stem2$dbh,  mort14$status.2014, mort15$status.2015, mort16$status.2016, mort17$status.2016, mort18$status.2016, mort19$status.2016)[!apply(cbind(mort16$status.2016, mort17$status.2016, mort18$status.2016, mort19$status.2016), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] )), ]  # mort16.status.2016 should be fixed to "PD" for 92465 (fixed earlier), is correct for 40853 302.5, and should be "AU" for 40853 297.5 (fixed earlier)

# status in 2017
data.frame( scbi.stem1$quadrat,  scbi.stem1$tag, scbi.stem1$sp, mort17$status.2017, mort18$status.2017, mort19$status.2017)[!apply(cbind(mort17$status.2017, mort18$status.2017, mort19$status.2017), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] )), ]# mort17$status.2017 correct for 60205, 60205


#status in 2018
data.frame( scbi.stem1$quadrat,  scbi.stem1$tag, scbi.stem1$sp, mort18$status.2018, mort19$status.2018)[!apply(cbind( mort18$status.2018, mort19$status.2018), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] )), ]  # mort18$status.2018 correct for 30365


# append "Latin" to scbi.stem1, 2 and 3 ####
scbi.stem1 <- cbind(scbi.stem1, Latin = scbi.spptable$Latin[match(scbi.stem1$sp, scbi.spptable$sp)])
scbi.stem2 <- cbind(scbi.stem2, Latin = scbi.spptable$Latin[match(scbi.stem2$sp, scbi.spptable$sp)])
scbi.stem3 <- cbind(scbi.stem3, Latin = scbi.spptable$Latin[match(scbi.stem3$sp, scbi.spptable$sp)])

# Getting data ready for each mortality census year + saving output ####
head(scbi.stem1)
head(scbi.stem2)
head(scbi.stem3)
head(mort14)




data.2008 <- scbi.stem1[, c("tag", "StemTag",  "stemID","quadrat", "sp", "Latin", "gx", "gy", "hom", "dbh", "codes", "status", "ExactDate", "agb")]
names(data.2008) <- c("tag", "StemTag",  "stemID","quadrat", "sp", "Latin", "gx", "gy", "hom", "dbh.2008", "codes.2008", "status.2008", "date.2008", "agb.2008")

data.2013 <- scbi.stem2[, c("dbh", "codes", "status", "ExactDate", "agb")]
names(data.2013) <- c("dbh.2013", "codes.2013", "status.2013", "date.2013", "agb.2013")

data.2018 <- scbi.stem3[, c("dbh", "codes", "status", "ExactDate", "agb")]
names(data.2018) <- c("dbh.2018", "codes.2018", "status.2018", "date.2018", "agb.2018")


full.census.data <- cbind(data.2008, data.2013, data.2018)
head(full.census.data)

# double check order

all(apply(cbind(data.2008$tag, data.2013$tag, mort14$tag, mort15$tag, mort16$tag, mort17$tag, mort18$tag, mort19$tag), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) # has to be TRUE

all(apply(cbind(data.2008$StemTag, data.2013$StemTag, mort14$StemTag, mort15$StemTag, mort16$StemTag, mort17$StemTag, mort18$StemTag), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) # has to be TRUE


for (survey_year in mort.census.years) {
  
  print(paste("Preparing and saving final data set for", survey_year))
  
  mort <- get(paste0("mort", substr(survey_year, 3,4)))
  head(mort)
  
  current.census.data <-  mort[, c(paste0("status.", survey_year), "dbh.if.dead", "agb.if.dead", "perc.crown", "crown.position", "fad1", "fad2", "fad3", "fad4", "DF", "liana.load", "fraxinus.crown.thinning", "fraxinus.epicormic.growth", "EABF", "DE.count", "comments", "date", "surveyors")]
  
  if (!survey_year %in% 2014) {
    previous.census.data <- get(paste0("mort", substr(survey_year-1, 3,4)))[, paste0("status.", survey_year-1)]
    mort <- cbind.data.frame(previous.census.data, current.census.data, stringsAsFactors = FALSE)
    names(mort) <-  gsub("previous.census.data", paste0("status.", survey_year-1), names(mort))
  } else {
    mort <- current.census.data
  }
  
  mort$date <- as.Date(mort$date, format = "%m/%d/%Y")
  names(mort) <- gsub("date$", paste0("date.", survey_year), names(mort))
  names(mort) <- gsub("if.dead", paste0("if.dead.", survey_year), names(mort))
  
  
  final.mort <- cbind(full.census.data, mort)
  final.mort <- final.mort[order(as.numeric(final.mort$tag), as.numeric(final.mort$StemTag)), ]
  
  assign(paste0("final.mort.", survey_year), final.mort)
  write.csv(final.mort, file = paste0("tree_mortality/data/mortality_", survey_year, ".csv"), row.names = F)
}

# also save one data frame for 2008, 2013 and 2018 ####
data.2008 <- data.2008[order(as.numeric(data.2008$tag), as.numeric(data.2008$StemTag)), ]
full.census.data <- full.census.data[order(as.numeric(full.census.data$tag), as.numeric(full.census.data$StemTag)), ]
full.census.data$date.2008 <- as.Date(full.census.data$date.2008)
full.census.data$date.2013 <- as.Date(full.census.data$date.2013)

write.csv(data.2008, file = "tree_mortality/data/mortality_2008.csv", row.names = F)
write.csv(full.census.data[, -grep("2018", names(full.census.data))], file = "tree_mortality/data/mortality_2013.csv", row.names = F)


# CREATE allmort.rdata file ####
allmort <- cbind(full.census.data[, c("tag", "StemTag", "stemID", "quadrat", "Latin", "sp", "gx", "gy", "dbh.2008", "date.2008", "agb.2008", "status.2008", "dbh.2013", "date.2013", "agb.2013", "status.2013", "dbh.2018", "date.2018", "agb.2018", "status.2018")],
                 
                 do.call(cbind, lapply(mort.census.years, function(survey_year) {
                   final.mort <- get(paste0("final.mort.", survey_year))
                   final.mort <- final.mort[match(paste(full.census.data$tag, full.census.data$StemTag), paste(final.mort$tag, final.mort$StemTag)), paste0(c("status.", "date.", "dbh.if.dead.", "agb.if.dead."), survey_year)]
                   return(final.mort)
                 })),
                 Latin = full.census.data$Latin
) # forgeting about fad and positions

# Add Genus, spsecies, Familly
allmort <- cbind(allmort, scbi.spptable[match(allmort$sp,scbi.spptable$sp), c("Genus", "Species", "Family")])

# change status format
status.columns <- sort(unique(names(allmort)[grepl("status", names(allmort))]))

for(sc in status.columns) {
  allmort[, sc] <- ifelse(is.na(allmort[, sc]), NA,
                          ifelse(allmort[, sc] %in% "P", "Prior",
                                 ifelse(grepl("A", allmort[, sc]), "Live", "Dead")))
}

head(allmort)

write.csv(allmort, "tree_mortality/data/allmort.csv", row.names = F) # save as csv file
save(allmort, file ="tree_mortality/data/allmort.rdata") # save as Rdata file
