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

for(f in paste0("scbi.stem", 1:2, ".rdata")) {
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

mort.census.years <- c(2014:2018)

for(survey_year in mort.census.years) {
  print(paste("load mortlity data for year", survey_year))
  
  # load
  mort <- read.csv(paste0("raw data/Mortality_Survey_", survey_year, ".csv"), stringsAsFactors = F)
  
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
  
  # order the columns the way we want it
  mort <- mort[, c("quadrat", "tag", "StemTag", "sp", "lx", "ly", "dbh.2013", 
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
for(census in paste0("scbi.stem", 1:2)) {
  x <- get(census)
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



# order rows the same way as year 2013 ###

## first find out if all tags exist in core census data and fix any problem with that
tag_stems.13 <- paste(scbi.stem2$tag, scbi.stem2$StemTag, sep = "_")

for(survey_year in mort.census.years) {
  print(survey_year)
  
  mort <- get(paste0("mort", substr(survey_year, 3, 4)))
  tag_stems <- paste(mort$tag, mort$StemTag, sep = "_")
  
  if(!all(tag_stems %in% tag_stems.13)) {
    print("Not all tags are in core census")
    
    tag_stems[which(!tag_stems %in% tag_stems.13)]
    print(mort[ paste(mort$tag, mort$StemTag, sep = "_") %in% tag_stems[which(!tag_stems %in% tag_stems.13)], ])
  } 
}

### FIXING PrOBLEMES:

#### the tag and species ID issue: In full census data, tag 33331 appears 2 times. Looking like a 2-stem quru. In 2014 it was found that the biggest stem was actually tagged with tag 30365. The tag number was changed only in mortality census 2017 and Maya and Ryan ID-ed that second stem as fram. but the species ID was never changed. I am fixing that in all mortality related data now, by changin tag# StemTag and species in all dataframes

scbi.stem1[scbi.stem1$tag %in% 33331,]
scbi.stem2[scbi.stem2$tag %in% 33331,]
mort14[mort14$tag %in% 33331, ]
mort15[mort15$tag %in% 33331, ]
mort16[mort16$tag %in% 33331, ]
mort17[mort17$tag %in% 33331, ]
mort18[mort18$tag %in% 33331, ]

scbi.stem1[scbi.stem1$tag %in% 33331,]$StemTag <- c(1, 1)
scbi.stem2[scbi.stem2$tag %in% 33331,]$StemTag <- c(1, 1)
mort14[mort14$tag %in% 33331, ]$StemTag <- c(1, 1)
mort15[mort15$tag %in% 33331, ]$StemTag <- c(1, 1)
mort16[mort16$tag %in% 33331, ]$StemTag <- c(1, 1)


scbi.stem1[scbi.stem1$tag %in% 33331,]$sp <- c("fram", "quru")
scbi.stem2[scbi.stem2$tag %in% 33331,]$sp <- c("fram", "quru")
mort14[mort14$tag %in% 33331, ]$sp <- c("fram", "quru")
mort15[mort15$tag %in% 33331, ]$sp <- c("quru", "fram")
mort16[mort16$tag %in% 33331, ]$sp <-  c("quru", "fram")

scbi.stem1[scbi.stem1$tag %in% 33331,]$tag <- c(30365, 33331)
scbi.stem2[scbi.stem2$tag %in% 33331,]$tag <- c(30365, 33331)
mort14[mort14$tag %in% 33331, ]$tag <- c(30365, 33331)
mort15[mort15$tag %in% 33331, ]$tag <- c(33331, 30365)
mort16[mort16$tag %in% 33331, ]$tag <- c(33331, 30365)

scbi.stem1[scbi.stem1$tag %in% 33331,]
scbi.stem2[scbi.stem2$tag %in% 33331,]
mort14[mort14$tag %in% 33331, ]
mort15[mort15$tag %in% 33331, ]
mort16[mort16$tag %in% 33331, ]
mort17[mort17$tag %in% 33331, ]
mort18[mort18$tag %in% 33331, ]


scbi.stem1[scbi.stem1$tag %in% 30365,]
scbi.stem2[scbi.stem2$tag %in% 30365,]
mort14[mort14$tag %in% 30365, ]
mort15[mort15$tag %in% 30365, ]
mort16[mort16$tag %in% 30365, ]
mort17[mort17$tag %in% 30365, ]
mort18[mort18$tag %in% 30365, ]
  

#### "tag 133461(quadrat 1316, comment in 2015: Ojo:this is not caco, it is fram. Not 2 stem! Fram tag=131352)"

scbi.stem1[scbi.stem1$tag %in% 133461 & scbi.stem1$dbh > 900, ]$sp <- "fram"
scbi.stem2[scbi.stem2$tag %in% 133461 & scbi.stem2$dbh > 900, ]$sp <- "fram"
mort14[mort14$tag %in% 133461 & mort14$dbh.2013 > 900, ]$sp <- "fram"
mort15[mort15$tag %in% 133461 & mort15$dbh.2013 > 900, ]$sp <- "fram"
mort16[mort16$tag %in% 133461 & mort16$dbh.2013 > 900, ]$sp <- "fram"
mort17[mort17$tag %in% 133461 & mort17$dbh.2013 > 900, ]$sp <- "fram"
# mort18[mort18$tag %in% 133461 & mort18$dbh.2013 > 900, ]$sp <- "fram"

scbi.stem1[scbi.stem1$tag %in% 133461 & scbi.stem1$dbh < 900, ]$StemTag <- 1
scbi.stem2[scbi.stem2$tag %in% 133461 & scbi.stem2$dbh < 900, ]$StemTag <- 1
mort14[mort14$tag %in% 133461 & mort14$dbh.2013 < 900, ]$StemTag <- 1
mort15[mort15$tag %in% 133461 & mort15$dbh.2013 < 900, ]$StemTag <- 1
mort16[mort16$tag %in% 133461 & mort16$dbh.2013 < 900, ]$StemTag <- 1
mort17[mort17$tag %in% 133461 & mort17$dbh.2013 < 900, ]$StemTag <- 1
# mort18[mort18$tag %in% 133461 & mort18$dbh.2013 < 900, ]$StemTag <- 1

scbi.stem1[scbi.stem1$tag %in% 133461 & scbi.stem1$dbh > 900, ]$tag <- 131352
scbi.stem2[scbi.stem2$tag %in% 133461 & scbi.stem2$dbh > 900, ]$tag <- 131352
mort14[mort14$tag %in% 133461 & mort14$dbh.2013 > 900, ]$tag <- 131352
mort15[mort15$tag %in% 133461 & mort15$dbh.2013 > 900, ]$tag <- 131352
mort16[mort16$tag %in% 133461 & mort16$dbh.2013 > 900, ]$tag <- 131352
mort17[mort17$tag %in% 133461 & mort17$dbh.2013 > 900, ]$tag <- 131352
# mort18[mort18$tag %in% 133461 & mort18$dbh.2013 > 900, ]$tag <- 131352


# 170982 is fram and not liriodendron
scbi.stem1[scbi.stem1$tag %in% 170982,]$sp <- "fram"
scbi.stem2[scbi.stem2$tag %in% 170982,]$sp <- "fram"
mort14[mort14$tag %in% 170982, ]$sp <- "fram"
mort15[mort15$tag %in% 170982, ]$sp <- "fram"
mort16[mort16$tag %in% 170982, ]$sp <- "fram"
mort17[mort17$tag %in% 170982, ]$sp <- "fram"
mort18[mort18$tag %in% 170982, ]$sp <- "fram"


## fixing dbh issues ####
scbi.stem2[scbi.stem2$tag %in% 190691 & scbi.stem2$StemTag == 1, ]$dbh <- 32.8
mort16[mort16$tag %in% 190691, ]$dbh.2013 <- 32.8
mort17[mort17$tag %in% 190691, ]$dbh.2013 <- 32.8


scbi.stem2[scbi.stem2$tag %in% 203751, ]$dbh <- 14.3
mort14[mort14$tag %in% 203751, ]$dbh.2013 <- 14.3
mort15[mort15$tag %in% 203751, ]$dbh.2013 <- 14.3
mort16[mort16$tag %in% 203751, ]$dbh.2013 <- 14.3
mort17[mort17$tag %in% 203751, ]$dbh.2013 <- 14.3


scbi.stem2[scbi.stem2$tag %in% 80560, ]
mort14[mort14$tag %in% 80560, ]
mort15[mort15$tag %in% 80560, ]
mort16[mort16$tag %in% 80560, ]
mort17[mort17$tag %in% 80560, ]
mort18[mort18$tag %in% 80560, ]

mort16 <- mort16[-which(mort16$tag %in% 80560 & mort16$StemTag %in% 2), ]
mort17 <- mort17[-which(mort17$tag %in% 80560 & mort17$StemTag %in% 2), ]
mort18 <- mort18[-which(mort18$tag %in% 80560 & mort18$StemTag %in% 2), ]


scbi.stem2[scbi.stem2$tag %in% 172262, ]
mort14[mort14$tag %in% 172262, ]
mort15[mort15$tag %in% 172262, ]
mort16[mort16$tag %in% 172262, ]
mort17[mort17$tag %in% 172262, ]
mort18[mort18$tag %in% 172262, ]

mort17[mort17$tag %in% 172262, ]$dbh.2013 <- 170.7


scbi.stem1[!is.na(scbi.stem1$dbh) & scbi.stem1$dbh < 1, ]$dbh
scbi.stem2[!is.na(scbi.stem2$dbh) & scbi.stem2$dbh < 1, ]$dbh <- NA




#### Fixing quadrat issues ####
quadrat.317 <- scbi.stem1$quadrat %in% "0317" | scbi.stem1$tag %in% 33339
quadrat.319 <- scbi.stem1$quadrat %in% "0319" & !scbi.stem1$tag %in% 33339
scbi.stem1[quadrat.317, ]$quadrat <- "0319"
scbi.stem1[quadrat.319, ]$quadrat <- "0317"

quadrat.317 <- scbi.stem2$quadrat %in% "0317" | scbi.stem2$tag %in% 33339
quadrat.319 <- scbi.stem2$quadrat %in% "0319" & !scbi.stem2$tag %in% 33339
scbi.stem2[quadrat.317, ]$quadrat <- "0319"
scbi.stem2[quadrat.319, ]$quadrat <- "0317"

quadrat.317 <- mort14$quadrat %in% "0317" | mort14$tag %in% 33339
quadrat.319 <- mort14$quadrat %in% "0319" & !mort14$tag %in% 33339
mort14[quadrat.317, ]$quadrat <- "0319"
mort14[quadrat.319, ]$quadrat <- "0317"

tag.32081.in.317 <- mort15$tag %in% 32081
mort15$quadrat[tag.32081.in.317] <- "0317"
tag.32081.in.317 <- mort16$tag %in% 32081
mort16$quadrat[tag.32081.in.317] <- "0317"
tag.32081.in.317 <- mort17$tag %in% 32081
mort17$quadrat[tag.32081.in.317] <- "0317"
tag.32081.in.317 <- mort18$tag %in% 32081
mort18$quadrat[tag.32081.in.317] <- "0317"


tag.32021.32068.in.319 <- mort15$tag %in% c(32021, 32068)
mort15$quadrat[tag.32021.32068.in.319] <- "0319"
tag.32021.32068.in.319 <- mort16$tag %in% c(32021, 32068)
mort16$quadrat[tag.32021.32068.in.319] <- "0319"
tag.32021.32068.in.319 <- mort17$tag %in% c(32021, 32068)
mort17$quadrat[tag.32021.32068.in.319] <- "0319"
tag.32021.32068.in.319 <- mort18$tag %in% c(32021, 32068)
mort18$quadrat[tag.32021.32068.in.319] <- "0319"


tag.60364.in.608 <- mort17$tag %in% c(60364)
mort17$quadrat[tag.60364.in.608] <- "0608"
tag.60364.in.608 <- mort18$tag %in% c(60364)
mort18$quadrat[tag.60364.in.608] <- "0608"



t = "40873"
scbi.stem1[scbi.stem1$tag %in% t & scbi.stem1$dbh > 600, ]$tag <- "40874"
scbi.stem2[scbi.stem2$tag %in% t & scbi.stem2$dbh > 600, ]$tag <- "40874"
mort14[mort14$tag %in% t, ] ; mort14[mort14$tag %in% 40874, ]
mort15[mort15$tag %in% t, ] ; mort14[mort14$tag %in% 40874, ]
mort16[mort16$tag %in% t, ] ; mort16[mort16$tag %in% 40874, ]
mort17[mort17$tag %in% t, ] ; mort17[mort17$tag %in% 40874, ]
mort18[mort18$tag %in% t, ] ; mort18[mort18$tag %in% 40874, ]

# double checkin that all tags exist now ####
tag_stems.13 <- paste(scbi.stem2$tag, scbi.stem2$StemTag, sep = "_")

All_mortality_tag_stems <- NULL
for(survey_year in mort.census.years) {
  print(survey_year)
  
  mort <- get(paste0("mort", substr(survey_year, 3, 4)))
  tag_stems <- paste(mort$tag, mort$StemTag, sep = "_")
  
  if(!all(tag_stems %in% tag_stems.13)) {
    print("Not all tags are in core census")
    
    tag_stems[which(!tag_stems %in% tag_stems.13)]
    print(mort[ paste(mort$tag, mort$StemTag, sep = "_") %in% tag_stems[which(!tag_stems %in% tag_stems.13)], ])
  } 
  
  All_mortality_tag_stems <- c(All_mortality_tag_stems, paste(mort$tag, mort$StemTag, sep = "_"))
}
#--> if no data shows up, good!

## Now re-order all data frames to be in the same format
All_mortality_tag_stems <- unique(All_mortality_tag_stems)
length(All_mortality_tag_stems)

all(All_mortality_tag_stems %in% tag_stems.13 ) # has to be TRUE

scbi.stem1 <- scbi.stem1[tag_stems.13 %in% All_mortality_tag_stems, ]
scbi.stem2 <- scbi.stem2[tag_stems.13 %in% All_mortality_tag_stems, ]
tag_stems.13 <- tag_stems.13[tag_stems.13 %in% All_mortality_tag_stems]


all(tag_stems.13 == paste(scbi.stem2$tag, scbi.stem2$StemTag, sep = "_")) # has to be TRUE

for(survey_year in mort.census.years) {
  print(survey_year)
  
  mort <- get(paste0("mort", substr(survey_year, 3, 4)))
  tag_stems <- paste(mort$tag, mort$StemTag, sep = "_")
  
  m <- match(tag_stems.13, tag_stems)
  mort <- mort[m, ]
  assign(paste0("mort", substr(survey_year, 3,4)), mort)
  
  print(dim(mort))
  
}


## Now we double check that all match well and fix what does not... ####

all(apply(cbind(scbi.stem1$tag, scbi.stem2$tag, mort14$tag, mort15$tag, mort16$tag, mort17$tag, mort18$tag), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) # has to be TRUE

all(apply(cbind(scbi.stem1$StemTag, scbi.stem2$StemTag, mort14$StemTag, mort15$StemTag, mort16$StemTag, mort17$StemTag, mort18$StemTag), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) # has to be TRUE


all(apply(round(cbind(scbi.stem2$dbh, mort14$dbh.2013, mort15$dbh.2013, mort16$dbh.2013, mort17$dbh.2013, mort18$dbh.2013), 2), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) #should be TRUE

cbind(scbi.stem1$quadrat, scbi.stem1$tag, as.character(scbi.stem1$sp), scbi.stem1$dbh, as.character(scbi.stem1$status), scbi.stem2$dbh, as.character(scbi.stem2$status),mort14$dbh.2013, mort15$dbh.2013, mort16$dbh.2013, mort17$dbh.2013, mort18$dbh.2013)[!apply(cbind(scbi.stem2$dbh, mort14$dbh.2013, mort15$dbh.2013, mort16$dbh.2013, mort17$dbh.2013, mort18$dbh.2013), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] )), ] # most of the problems here are just due to trees that died and or grew or resprouted or problem that will be fixed if we only keep dbh in 2013. Bigger problems were fixed earlier in the script


all(apply(cbind(scbi.stem2$quadrat, mort14$quadrat, mort15$quadrat, mort16$quadrat, mort17$quadrat, mort18$quadrat), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) # Has to be TRUE (fixed (problem of 317 and 319 mostly))

cbind( scbi.stem1$tag, scbi.stem1$quadrat, scbi.stem2$quadrat, mort14$quadrat, mort15$quadrat, mort16$quadrat, mort17$quadrat, mort18$quadrat)[!apply(cbind(scbi.stem2$quadrat, mort14$quadrat, mort15$quadrat, mort16$quadrat, mort17$quadrat, mort18$quadrat), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] )), ]


all(apply(cbind(scbi.stem1$sp, scbi.stem2$sp, mort14$sp, mort15$sp, mort16$sp, mort17$sp, mort18$sp), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) # Has to be TRUE - I know there are issues, Erika might be working on it.
cbind( scbi.stem1$tag, scbi.stem1$sp, scbi.stem2$sp, mort14$sp, mort15$sp, mort16$sp, mort17$sp, mort18$sp)[!apply(cbind(scbi.stem1$sp, scbi.stem2$sp, mort14$sp, mort15$sp, mort16$sp, mort17$sp, mort18$sp), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] )), ] # keeping full census species ID for now.


# status in 2013

table(as.character(scbi.stem2$codes), as.character(scbi.stem2$DFstatus))

# status in 2014 # big problems... # will ignore all but in actual 2014 year
data.frame( scbi.stem1$quadrat,  scbi.stem1$tag, scbi.stem1$sp, scbi.stem2$dbh, scbi.stem2$status, mort14$status.2014, mort15$status.2014, mort16$status.2014)[(!apply(cbind(mort14$status.2014, mort15$status.2014, mort16$status.2014), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) & scbi.stem2$dbh >= 100 & !is.na(scbi.stem2$dbh), ]  

# status in 2015
data.frame( scbi.stem1$quadrat,  scbi.stem1$tag, scbi.stem1$sp, scbi.stem2$dbh, mort15$status.2015, mort16$status.2015, mort17$status.2015, mort18$status.2015)[!apply(cbind(mort15$status.2015, mort16$status.2015, mort17$status.2015, mort18$status.2015), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] )), ]  

# status in 2016
data.frame( scbi.stem1$quadrat,  scbi.stem1$tag, scbi.stem1$sp, scbi.stem2$dbh,  mort14$status.2014, mort15$status.2015, mort16$status.2016, mort17$status.2016, mort18$status.2016)[!apply(cbind(mort16$status.2016, mort17$status.2016, mort18$status.2016), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] )), ]  

# status in 2017
data.frame( scbi.stem1$quadrat,  scbi.stem1$tag, scbi.stem1$sp, mort17$status.2017, mort18$status.2017)[!apply(cbind(mort17$status.2017, mort18$status.2017), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] )), ]  


# append "Latin" to scbi.stem1 and 2 ####
scbi.stem1 <- cbind(scbi.stem1, Latin = scbi.spptable$Latin[match(scbi.stem1$sp, scbi.spptable$sp)])
scbi.stem2 <- cbind(scbi.stem2, Latin = scbi.spptable$Latin[match(scbi.stem2$sp, scbi.spptable$sp)])

# Getting data ready for each mortality census year + saving output ####
head(scbi.stem1)
head(scbi.stem2)
head(mort14)




data.2008 <- scbi.stem1[, c("tag", "StemTag",  "stemID","quadrat", "sp", "Latin", "gx", "gy", "pom", "dbh", "codes", "status", "ExactDate")]
names(data.2008) <- c("tag", "StemTag",  "stemID","quadrat", "sp", "Latin", "gx", "gy", "pom", "dbh.2008", "codes.2008", "status.2008", "date.2008")

data.2013 <- scbi.stem2[, c("dbh", "codes", "status", "ExactDate", "agb")]
names(data.2013) <- c("dbh.2013", "codes.2013", "status.2013", "date.2013", "agb.2013")

full.census.data <- cbind(data.2008, data.2013)
head(full.census.data)

# double check order

all(apply(cbind(data.2008$tag, data.2013$tag, mort14$tag, mort15$tag, mort16$tag, mort17$tag, mort18$tag), 1 , function(x) all( x[!is.na(x)] == x[!is.na(x)][1] ))) # has to be TRUE

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
  write.csv(final.mort, file = paste0("data/mortality_", survey_year, ".csv"), row.names = F)
}

# also save one data frame for 2008 and 2013 ####
data.2008 <- data.2008[order(as.numeric(data.2008$tag), as.numeric(data.2008$StemTag)), ]
full.census.data <- full.census.data[order(as.numeric(full.census.data$tag), as.numeric(full.census.data$StemTag)), ]
full.census.data$date.2008 <- as.Date(full.census.data$date.2008)
full.census.data$date.2013 <- as.Date(full.census.data$date.2013)

write.csv(data.2008, file = "data/mortality_2008.csv", row.names = F)
write.csv(full.census.data, file = "data/mortality_2013.csv", row.names = F)


# CREATE allmort.rdata file ####
allmort <- cbind(full.census.data[, c("tag", "StemTag", "stemID", "quadrat", "sp", "gx", "gy", "dbh.2013", 
                                      "date.2013", "agb.2013", "status.2013")],
                 
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
status.columns <- names(allmort)[grepl("status", names(allmort))]

for(sc in status.columns) {
  allmort[, sc] <- ifelse(is.na(allmort[, sc]), NA,
                          ifelse(allmort[, sc] %in% "P", "Prior",
                                 ifelse(grepl("A", allmort[, sc]), "Live", "Dead")))
}

head(allmort)

write.csv(allmort, "data/allmort.csv", row.names = F) # save as csv file
save(allmort, file ="data/allmort.rdata") # save as Rdata file
