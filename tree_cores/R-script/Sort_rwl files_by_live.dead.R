######################################################
# Purpose: Sorting .rwl files by live and dead cores from the file "census_data_for_cored_trees.csv"
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created November 2018
######################################################

rm(list = ls())

## Running this script produces live and dead .rwl files for all species specified in the first vector. It also troubleshoots and identifies mis-IDed species plus species we have a record of in the census_data_for_cored_trees.csv file, but are missing actual analyses for.

## Finally, this script will make simple plots for each live/dead file for each species specified.

setwd("tree_cores/chronologies/current_chronologies")

library(dplR)
library(RCurl)

Species <- c("fram", "quve", "litu", "quru")
missing_in_processed_cores <- NULL
mis_IDed <- NULL

census.data.for.cored.trees <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/climate_sensitivity_cores/master/data/census_data_for_cored_trees.csv"))

for(sp in Species) {

  print(sp)
  
  sp.rwl <- read.rwl(paste0(sp, "_drop.rwl"))
  colnames(sp.rwl) <- gsub("A", "",   colnames(sp.rwl) )
  colnames(sp.rwl)  <- gsub("^0", "",   colnames(sp.rwl) )
  colnames(sp.rwl) <- gsub("r", "", colnames(sp.rwl))
  
  tree_tags <- colnames(sp.rwl)

  
  
  tree_tags_live <- tree_tags[tree_tags %in% census.data.for.cored.trees[census.data.for.cored.trees$status.at.time.of.coring %in% "live", ]$tag]
  
  tree_tags_dead <- tree_tags[tree_tags %in% census.data.for.cored.trees[census.data.for.cored.trees$status.at.time.of.coring %in% "dead", ]$tag]
  
  # trees that are missing in the processed analysis
  
  ##dead
  missing_in_processed_cores <- rbind(missing_in_processed_cores, data.frame(sp = census.data.for.cored.trees[census.data.for.cored.trees$status.at.time.of.coring %in% "dead" & census.data.for.cored.trees$sp %in% sp, ]$sp [!census.data.for.cored.trees[census.data.for.cored.trees$status.at.time.of.coring %in% "dead" & census.data.for.cored.trees$sp %in% sp, ]$tag %in% tree_tags], tag = census.data.for.cored.trees[census.data.for.cored.trees$status.at.time.of.coring %in% "dead" & census.data.for.cored.trees$sp %in% sp, ]$tag [!census.data.for.cored.trees[census.data.for.cored.trees$status.at.time.of.coring %in% "dead" & census.data.for.cored.trees$sp %in% sp, ]$tag %in% tree_tags]))
  
  ## live
  missing_in_processed_cores <- rbind(missing_in_processed_cores, data.frame(sp = census.data.for.cored.trees[census.data.for.cored.trees$status.at.time.of.coring %in% "live" & census.data.for.cored.trees$sp %in% sp, ]$sp [!census.data.for.cored.trees[census.data.for.cored.trees$status.at.time.of.coring %in% "live" & census.data.for.cored.trees$sp %in% sp, ]$tag %in% tree_tags], tag = census.data.for.cored.trees[census.data.for.cored.trees$status.at.time.of.coring %in% "live" & census.data.for.cored.trees$sp %in% sp, ]$tag [!census.data.for.cored.trees[census.data.for.cored.trees$status.at.time.of.coring %in% "live" & census.data.for.cored.trees$sp %in% sp, ]$tag %in% tree_tags]))
  
  # trees that are mis-IDed
  
  mis_IDed <- rbind(mis_IDed,
                    census.data.for.cored.trees[census.data.for.cored.trees$tag %in% tree_tags & !census.data.for.cored.trees$sp %in% sp, ])
  
  
  # subset and save rwl file for live trees
  sp.rwl.live <- sp.rwl[, tree_tags_live]
  write.rwl(sp.rwl.live, paste0(sp, "_drop_live.rwl"))
  
  # subset and save rwl file for dead trees
  sp.rwl.dead <- sp.rwl[, tree_tags_dead]
  write.rwl(sp.rwl.dead, paste0(sp, "_drop_dead.rwl"))
  
  plot(sp.rwl.live, plot.type="spag", main=expression("Species_live"), xlab="Year", ylab="trees")
  plot(sp.rwl.dead, plot.type="spag", main=expression("Species_dead"), xlab="Year", ylab="trees")
  
} #for(sp in Species) 
