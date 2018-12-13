# for merging the ForestGEO recensus survey data with dendro_cored_full

recensus2018 <- read.csv("I:/recensus2018.csv")

dendro_cored <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns/dendro_cored_full.csv")

library(data.table)
recensus2018 <- setnames(recensus2018, old=c("Tag", "StemTag"), new=c("tag", "stemtag"))

combo <- merge(dendro_cored, recensus2018, by=c("tag", "stemtag"))
combo <- combo[order(combo[,1]),]

combo <- setnames(combo, old=c("DBH"), new=c("dbh2018"))
combo$dbh2018 <- combo$dbh2018*10

namescombo <- c(combo$tag)
namescored <- c(dendro_cored$tag)

## find the names that are in data_2017 but not in data_biannual
missing <- setdiff(namescored, namescombo)
missing1 <- setdiff(namescombo, namescored)

namescombo[!(namescombo %in% namescored)]

combo$QuadratName <- NULL
combo$Mnemonic <- NULL
combo$OldDBH <- NULL
combo$OldCodes <- NULL
combo$Comments <- NULL
combo$Errors <- NULL
combo$ExactDate <- NULL
combo$X <- NULL
combo$Y <- NULL
combo$dataset <- NULL

combo$status <- as.character(combo$status)
deadcodes <- grep("^D", combo$Codes, value = TRUE) #there are 47 unqiue dead codes in the 2018 recensus

combo$status <- ifelse(combo$Codes %in% deadcodes, "dead", combo$status)

combo$Codes <- NULL
combo <- combo[,c(1:8,26,9:25)]

combo <- combo[!duplicated(combo$stemID),]

write.csv(combo, "dendro_cored_full.csv", row.names=FALSE)
