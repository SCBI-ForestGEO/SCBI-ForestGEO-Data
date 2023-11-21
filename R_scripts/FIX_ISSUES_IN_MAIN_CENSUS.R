##########################################################################
# fix some issues in scbi.stem1, scbei.stem2 and scbi.stem3
# this needs to be run only once but may need to be run again once scbi.stem4 is completed, probably because we will have new versions of stem1, stem2 and stem3 then (with new lines for the recruits)
##########################################################################

# Clean environment ####
rm(list = ls())


# Load libraries ####

# Load data ####
load("tree_main_census/data/scbi.stem1.rdata")
load("tree_main_census/data/scbi.stem2.rdata")
load("tree_main_census/data/scbi.stem3.rdata")



# Fix issues in the data --------------------------------------------------


# tag 160135 has two stems but stemtag is 3 instead of 2
scbi.stem1[scbi.stem1$tag %in% "160135", ]
scbi.stem2[scbi.stem2$tag %in% "160135", ]
scbi.stem3[scbi.stem3$tag %in% "160135", ]

scbi.stem1[scbi.stem1$tag %in% "160135" & scbi.stem1$StemTag %in% 3, ]$StemTag <- 2
scbi.stem2[scbi.stem2$tag %in% "160135" & scbi.stem2$StemTag %in% 3, ]$StemTag <- 2
scbi.stem3[scbi.stem3$tag %in% "160135" & scbi.stem3$StemTag %in% 3, ]$StemTag <- 2

# tag 33331 vs 30365 ####
# until the 2018 main census, in full census data, tag 33331 appeared 2 times with same StemTag 1, looking like a 2-stem quru with wrong StemTag on smaller stem. In 2014 it was found that the biggest stem was actually tagged with tag 30365. The tag number was changed only in mortality census 2017 and Maya and Ryan ID-ed that second stem as being a fram, but the species ID was never changed in the data sets.
# So it seems that the truth would be:
# 33331 1 quru 161.2
# 30365 1 fram 992.0
#
# BUT, after 2018 main census, it seems that instructions were given to Suzanne Lao to change the tag number and species of BOTH stems, instead of the biggest stem only. So tag 33331 disappeared and we ended up with the same issue of having tag 30365 StemTag 1 appearing 2 times (but this time on a fram).
#
# So:
# Long term solution: tell Suzanne that smaller stem is a quru with tag 33331.
# Short term solution: fix data manually here (amd in mortality census)
# Temperarry solution in mortality census (not implemented anymore) changing 33331 quru to 30365 fram AND, for here, put a StemTag = 2 to smaller stem


scbi.stem1[scbi.stem1$tag %in% 30365, ] # should be 2 different tags, smaller: quru, bigger: fram
scbi.stem2[scbi.stem2$tag %in% 30365, ] # should be 2 different tags, smaller: quru, bigger: fram
scbi.stem3[scbi.stem3$tag %in% 30365, ] # should be 2 different tags, smaller: quru, bigger: fram

scbi.stem1[scbi.stem1$tag %in% 33331, ] # should exist and be a quru
scbi.stem2[scbi.stem2$tag %in% 33331, ] # should exist and be a quru
scbi.stem3[scbi.stem3$tag %in% 33331, ] # should exist and be a quru

scbi.stem1[scbi.stem1$tag %in% 30365 & scbi.stem1$dbh %in% 149.8, ]$sp <- "quru"
scbi.stem1[scbi.stem1$tag %in% 30365 & scbi.stem1$dbh %in% 149.8, ]$tag <- 33331

scbi.stem2[scbi.stem2$tag %in% 30365 & scbi.stem2$dbh %in% 161.2, ]$sp <- "quru"
scbi.stem2[scbi.stem2$tag %in% 30365 & scbi.stem2$dbh %in% 161.2, ]$tag <- 33331

scbi.stem3[scbi.stem3$tag %in% 30365 & scbi.stem3$dbh %in% 180, ]$sp <- "quru"
scbi.stem3[scbi.stem3$tag %in% 30365 & scbi.stem3$dbh %in% 180, ]$tag <- 33331


# tag 133461 vs 131352 ####
## "tag 133461 StemTag 1 (bigger stem) (quadrat 1316, comment in 2015: this is not caco, it is fram with tag=131352)"## looks like the bigger stem has a different tag and is fram. After 2018 main census, the tag and species were fixed but the species of the smaller stem (tag 133461), which was originally caco, was also changed to fram, by mistake. 133461 - is the smaller tree and is a caco, 131352 - was a large fram this is down and dead
scbi.stem1[scbi.stem1$tag %in% 133461, ] # should be caco
scbi.stem2[scbi.stem2$tag %in% 133461, ] # should be caco
scbi.stem3[scbi.stem3$tag %in% 133461, ] # should be caco

scbi.stem1[scbi.stem1$tag %in% 131352, ] # correctly fram
scbi.stem2[scbi.stem2$tag %in% 131352, ] # correctly fram
scbi.stem3[scbi.stem3$tag %in% 131352, ] # correctly fram

scbi.stem1[scbi.stem1$tag %in% 133461, ]$sp <- "caco" 
scbi.stem2[scbi.stem2$tag %in% 133461, ]$sp <- "caco" 
scbi.stem3[scbi.stem3$tag %in% 133461, ]$sp <- "caco" 



# tag 121374 ####
## tag 121374 is marked as dead in the last main census (2018) but is alive, with a dendro band.
## Krista mentioned this issue here https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/issues/35#issuecomment-1163596516
scbi.stem1[scbi.stem1$tag %in% 121374, "status"] # A
scbi.stem2[scbi.stem2$tag %in% 121374, "status"] # A
scbi.stem3[scbi.stem3$tag %in% 121374, "status"] # wrongly D

scbi.stem3[scbi.stem3$tag %in% 121374, "status"] <- "A"

# tag 093481 ####
## Tag 093481: species should be Carya cordiformis
## see Luke's comment here: https://github.com/SCBI-ForestGEO/SCBImortality/issues/47#issuecomment-902318886

scbi.stem1[scbi.stem1$tag %in% 093481, ] # should be caco
scbi.stem2[scbi.stem2$tag %in% 093481, ] # should be caco
scbi.stem3[scbi.stem3$tag %in% 093481, ] # should be caco

scbi.stem1[scbi.stem1$tag %in% 093481, ]$sp <- "caco" 
scbi.stem2[scbi.stem2$tag %in% 093481, ]$sp <- "caco" 
scbi.stem3[scbi.stem3$tag %in% 093481, ]$sp <- "caco" 

# tag 093487 ####
## Tag 093487: species should be Carya glabra
## see Luke's comment here: https://github.com/SCBI-ForestGEO/SCBImortality/issues/47#issuecomment-902318886

scbi.stem1[scbi.stem1$tag %in% 093487, ] # should be caco
scbi.stem2[scbi.stem2$tag %in% 093487, ] # should be caco
scbi.stem3[scbi.stem3$tag %in% 093487, ] # should be caco

scbi.stem1[scbi.stem1$tag %in% 093487, ]$sp <- "cagl" 
scbi.stem2[scbi.stem2$tag %in% 093487, ]$sp <- "cagl" 
scbi.stem3[scbi.stem3$tag %in% 093487, ]$sp <- "cagl" 


# tag 80180 ####
# should be a cagl (see https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/pull/29)
# See PR https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/pull/29/commits/3e74732cf337e1cd49550cfa6af50d361dd6d85c (which only modified the .csv files.. that is whyt I am now coding it here)

scbi.stem1[scbi.stem1$tag %in% 80180, ] # should be cagl
scbi.stem2[scbi.stem2$tag %in% 80180, ] # should be cagl
scbi.stem3[scbi.stem3$tag %in% 80180, ] # should be cagl

scbi.stem1[scbi.stem1$tag %in% 80180, ]$sp <- "cagl" 
scbi.stem2[scbi.stem2$tag %in% 80180, ]$sp <- "cagl" 
scbi.stem3[scbi.stem3$tag %in% 80180, ]$sp <- "cagl" 

# tag 131272 ####
# should be a fram (see https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/pull/29)
# See PR https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/pull/29/commits/3e74732cf337e1cd49550cfa6af50d361dd6d85c (which only modified the .csv files.. that is whyt I am now coding it here)

scbi.stem1[scbi.stem1$tag %in% 131272, ] # should be fram
scbi.stem2[scbi.stem2$tag %in% 131272, ] # should be fram
scbi.stem3[scbi.stem3$tag %in% 131272, ] # should be fram

scbi.stem1[scbi.stem1$tag %in% 131272, ]$sp <- "fram" 
scbi.stem2[scbi.stem2$tag %in% 131272, ]$sp <- "fram" 
scbi.stem3[scbi.stem3$tag %in% 131272, ]$sp <- "fram" 


# 52164 and 62184 is the same tree ####
## tag 52164 was removed from the field in 2023, 62184 remains
## need to consolidate 52164 into 62184 when needed and delete 52164

scbi.stem3[scbi.stem3$tag %in% "52164",] # delete that one (but move hom to 62184 )
scbi.stem3[scbi.stem3$tag %in% "62184",]

scbi.stem3[scbi.stem3$tag %in% "62184", "hom"] <- scbi.stem3[scbi.stem3$tag %in% "52164", "hom"]
scbi.stem3 <- scbi.stem3[!scbi.stem3$tag %in% "52164",]

scbi.stem2[scbi.stem2$tag %in% "52164",]  # delete that one (but move hom, dbh, DFsatus, codes and status to 62184 )
scbi.stem2[scbi.stem2$tag %in% "62184",]

scbi.stem2[scbi.stem2$tag %in% "62184", c("dbh", "hom", "ExactDate", "DFstatus", "codes", "date", "status")] <- scbi.stem2[scbi.stem2$tag %in% "52164", c("dbh", "hom", "ExactDate", "DFstatus", "codes", "date", "status")]
scbi.stem2 <- scbi.stem2[!scbi.stem2$tag %in% "52164",]


scbi.stem1[scbi.stem1$tag %in% "52164",] # can just delete this one
scbi.stem1[scbi.stem1$tag %in% "62184",]

scbi.stem1 <- scbi.stem1[!scbi.stem1$tag %in% "52164",]


# save data ---------------------------------------------------------------

save(scbi.stem1, file = "tree_main_census/data/scbi.stem1.rdata")
save(scbi.stem2, file = "tree_main_census/data/scbi.stem2.rdata")
save(scbi.stem3, file = "tree_main_census/data/scbi.stem3.rdata")

write.csv(scbi.stem1, "tree_main_census/data/census-csv-files/scbi.stem1.csv", row.names = F, quote = F)
write.csv(scbi.stem2, "tree_main_census/data/census-csv-files/scbi.stem2.csv", row.names = F, quote = F)
write.csv(scbi.stem3, "tree_main_census/data/census-csv-files/scbi.stem3.csv", row.names = F, quote = F)
