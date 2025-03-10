######################################################
# Purpose: Calculate Biomass, total and per species, for 1cm threshold and 10 cm threshold.
# Developped by: Valentine Herrmann - HerrmannV@si.edu
# R version 3.4.4 (2018-03-15)
######################################################

# Clean environment ####
rm(list = ls())

# Set working directory as Shenandoah main folder ####
setwd(".")

# Load libraries ####
library(allodb) # remotes::install_github("forestgeo/allodb")

# set number of censuses ####
site <- "scbi"
Censuses <- 2
units = "mm"
hectares <- 25.6
min.dbh <- ifelse(units %in% "mm", 10, 1) # 10mm



# Load data ####

for(f in paste0(site, ".stem", 1:Censuses, ".rdata")) {
  print(f)
  url <- paste0("https://raw.github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/", f)
  download.file(url, f, mode = "wb")
  load(f)
  file.remove(f)
}

f = "scbi.spptable"
assign(f, read.csv(paste0("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/", f, ".csv")))


# Calculate above ground biomass of each tree using allometries compiled by Erika + format dates####

for(census in c(1:2)) {
  x <- get(paste0("scbi.stem", census))
  # source("R_scripts/scbi_Allometries.R") # takes dbh in mm and spit ou agb in Mg
  
  x$dbh <- as.numeric(x$dbh) # not numeric because of the "NULL" values
  x$genus <- scbi.spptable$Genus[match(x$sp, scbi.spptable$sp)]
  x$species <- scbi.spptable$Species[match(x$sp, scbi.spptable$sp)]
  
  x$agb <-
    round(get_biomass(
      dbh = x$dbh/10, # in cm
      genus = x$genus,
      species = x$species,
      coords = c(-78.2, 38.9)
    ) / 1000 ,2) #  / 1000 to change to in Mg
  
  # Convert to C
  x$agb <-  x$agb * .47 
  
  # format dates
  x$ExactDate <- as.Date(x$ExactDate , format= "%Y-%m-%d")
  
  assign(paste0("scbi.stem", census), x)
}


# Calculate live above ground biomass for each census ####

for(census in c(1:2)) {
  x <- get(paste0("scbi.stem", census))
  
  ## get the trees that are alive
  idx.tree_alive <- x$DFstatus %in% "alive"
  
  ## get live tree SpeciesID
  s.species <- x$sp[idx.tree_alive]

  ## get the idx of tree >= 10cm (100mm)
  ss.trees.larger.10cm <- scbi.stem1$dbh[idx.tree_alive] >= 100 

  ## get the AGB of trees that live
  s.AGB <- x$agb[idx.tree_alive] # Mg C / y

  ## get total AG and AGB by Species, in Mg C/ha ####

  ### 1cm threshold ####
  AGB_total <- cbind(sum(s.AGB, na.rm = T) / 25.6) # ignore tree with missing dbh
  rownames(AGB_total) <- "total"
  n.total <- sum(idx.tree_alive)

  AGB_by_species <- cbind(sort(tapply(s.AGB, s.species, sum) / 25.6, decreasing = T))
  n.species <- table(s.species)[rownames(AGB_by_species)]


  ### 10cm threshold ####
  AGB_total_10cm <- cbind(sum(s.AGB[ss.trees.larger.10cm]) / 25.6)
  rownames(AGB_total_10cm) <- "total"
  n.total_10cm <- sum(idx.tree_alive[ss.trees.larger.10cm])

  AGB_by_species_10cm <- cbind(sort(tapply(s.AGB[ss.trees.larger.10cm], s.species[ss.trees.larger.10cm], sum) / 25.6, decreasing = T))
  n.species_10cm <- table(s.species[ss.trees.larger.10cm])[rownames(AGB_by_species_10cm)]


  # save results ####
  results <- rbind(AGB_total, AGB_by_species)
  results_10cm <-  rbind.data.frame(AGB_total_10cm, AGB_by_species_10cm)

  all_results <- data.frame(species = rownames(results), "AGB_Mg.C.ha1_1cm" = results, n_1cm = c(n.total, n.species), "AGB_Mg.C.ha1_10cm" = results_10cm[rownames(results),], n_10cm = c(n.total_10cm, n.species_10cm[rownames(results)[-1]]))
  
  names(all_results) <- gsub("(AGB|^n)", paste0("census", census, "_\\1"), names(all_results))

  assign(paste0("all_results", census), all_results)
}

head(all_results1)
head(all_results2)

# save
write.csv(cbind(all_results1, all_results2[rownames(all_results1), -1]), file = "summary_data/AGB_total_and_by_species.csv", row.names = F)

