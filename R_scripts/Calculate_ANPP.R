######################################################
# Purpose: Calculate ANPP, total and per species, for 1cm threshold and 10 cm threshold without growth rate outliers
# To identify and deal with outliers,  group trees into size bins 1-5cm, 5-10cm, 10-50cm, and >50cm. Throw out any measurements where the calculated growth rate is more than 4 std outside the mean for the size bin. Replace these with the mean.
# Developped by: Valentine Herrmann - HerrmannV@si.edu
# R version 3.4.4 (2018-03-15)
######################################################

# Clean environment ####
rm(list = ls())

# Set working directory if needed ####
setwd(".")

# Load libraries ####

# set number of censuses ####

Censuses <- 2
min.dbh <- 10 # 10mm
hectares <- 25.6
site <- "scbi"

# Load data ####

for(f in paste0(site, ".stem", 1:Censuses, ".rdata")) {
  print(f)
  url <- paste0("https://raw.github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/", f)
  download.file(url, f, mode = "wb")
  load(f)
  file.remove(f)
}


# Calculate ANPP for each census interval, with and without recruitment (with a loop) ####


for(with.recruitement in c(FALSE, TRUE)) {
  print(paste("with.recruitement:", with.recruitement))
  
  all_results_all_censuses <- NULL  
  
  for(c in c(1: (Censuses -1 ))) { 
    
    stem1 <- get(paste0(site, ".stem", c))
    stem2 <- get(paste0(site, ".stem", c + 1))
    
    
    
    # Deal with recruitement ####
    ## set last "Prior" status to "alive" and last "NA" dbh to 10 mm (minimum threshold) ( this is to add recruitment into ANPP calculations: for new recruits, ANPP_stem will be calculated as the growth from the min threshold (here, 1cm). For example, the productivity of a 1.5cm stem that appeared in the second census would be counted as [biomass of 1.5 cm stem - biomass of 1 cm stem ]/ census interval)
    
    if(with.recruitement) {
      
      
      statuses <- sapply(mget(paste0(site, ".stem",  1:Censuses)), "[[", "DFstatus")
      
      priors <- statuses == "prior"
      alives <- statuses == "alive"
      
      # priors followed by alive are changed to alive + dbh changed to min.dbh
      stem1$DFstatus[priors[, c] & alives[, c+1]] <- "alive" 
      stem1$dbh[priors[, c] & alives[, c+1]] <- min.dbh
      
      
      # for(c in 1:(Censuses - 1)) {
      #   stem <- get(paste0(site, ".stem",  c))
      #   stem$DFstatus[priors[, c] & alives[, c+1]] <- "alive" # priors followed by alive are changed to alive + dbh changed to min.dbh
      #   stem$dbh[priors[, c] & alives[, c+1]] <- min.dbh
      # }
      
      
    } #  if(with.recruitement)
    
    
    # Calculate above ground biomass of each tree using allometries compiled by Erika + format dates####
    
    for(stem.c in c(1:2)) {
      x <- get(paste0("stem", stem.c))
      source("R_scripts/scbi_Allometries.R") # takes dbh in mm and spit ou agb in Mg
      
      # Convert to C
      x$agb <-  x$agb * .47 
      
      # format dates
      x$ExactDate <- as.Date(x$ExactDate , format= "%Y-%m-%d")
      
      assign(paste0("stem", stem.c), x)
    }
    
    # Identify grouth outliers using dbh classes: 1-5cm, 5-10cm, 10-50cm, and >50cm ####
    
    ## first ID trees that are alive in 2008 and survived through 2013 and for which we have a dbh and a dbh > 10mm (this includes trees that are recruited, with dbh 2008 set to 10mm) ####
    
    idx.tree_survived <- stem1$DFstatus == "alive" &  stem2$DFstatus == "alive" & !is.na(stem1$dbh) & !is.na(stem2$dbh) & stem1$dbh >= 10 & stem2$dbh >= 10 
    
    ## second group the trees that survived into bins, based on initial dbh ####
    dbh_class <- cut(stem1$dbh[idx.tree_survived], breaks = c(10, 50, 100, 500, round(max(stem1$dbh[idx.tree_survived]) +1)), right = F) # based on first census, breaks in mm
    
    cbind(stem1$dbh[idx.tree_survived], dbh_class) # just to double check that it alines correctly
    cbind(stem2$dbh[idx.tree_survived], dbh_class) # just to double check that it alines correctly
    
    ## then calculate mean and SD of growth rate in each group ####
    
    ### get the time interval of trees that survived
    s.timeint <- difftime(stem2$ExactDate, stem1$ExactDate)[idx.tree_survived] / 365.242  # difftime gives in days so we t
    
    ### get growth rates of trees that survived
    growth_rate_tree_survived <- c(stem2$dbh[idx.tree_survived] - stem1$dbh[idx.tree_survived]) / as.numeric(s.timeint)
    
    mean_growth_rate_by_class <- tapply(growth_rate_tree_survived, dbh_class, mean)
    sd_growth_rate_by_class <- tapply(growth_rate_tree_survived, dbh_class, sd)
    
    ## find out which tree grew/shrunk by more than 4 std outside the mean for the corresponding size class
    mean_plus_4SD_by_class <- c(mean_growth_rate_by_class + 4 * sd_growth_rate_by_class)
    mean_plus_4SD_for_each_tree <- mean_plus_4SD_by_class[dbh_class]
    
    s.idx.growth_rate_outliers <- abs(growth_rate_tree_survived) > mean_plus_4SD_for_each_tree # index based on subset of trees that survived
    
    # Calculate change in AGB and replace the one of growth rate outliers by the mean change in AGB of their size class ####
    yearly_change_AGB_tree_survived <- c(stem2$agb[idx.tree_survived] - stem1$agb[idx.tree_survived]) /as.numeric(s.timeint)
    
    mean_yearly_change_AGB_by_class <- tapply(yearly_change_AGB_tree_survived[!s.idx.growth_rate_outliers], dbh_class[!s.idx.growth_rate_outliers], mean)
    mean_yearly_change_AGB_for_each_tree <- mean_yearly_change_AGB_by_class[dbh_class]
    
    yearly_change_AGB_tree_survived_corrected <- ifelse(s.idx.growth_rate_outliers, mean_yearly_change_AGB_for_each_tree, yearly_change_AGB_tree_survived)
    
    # calcualte ANPP based on corrected change in AGB ####
    ## set sp as factor
    stem1$sp <- as.factor(stem1$sp)
    
    ## get the species of trees that survived
    s.species <- stem1$sp[idx.tree_survived]
    
    ## get the idx of tree >= 10cm (100mm)
    ss.trees.larger.10cm <- stem1$dbh[idx.tree_survived] >= 100 
    
    ## get the ANPP (corrected) of trees that survived
    s.ANPP <- yearly_change_AGB_tree_survived_corrected # Mg C / y
    
    ## get total ANPP and ANPP by Species, in Mg C/ha/y ####
    
    ### 1cm threshold ####
    ANPP_total <- cbind(sum(s.ANPP, na.rm = T) / hectares)
    rownames(ANPP_total) <- "total"
    n.total <- sum(idx.tree_survived)
    
    ANPP_by_species <- tapply(s.ANPP, s.species, sum, na.rm = T)  / hectares
    ANPP_by_species <- cbind(ANPP_by_species[order(ANPP_by_species, decreasing = T)])
    n.species <- table(s.species)[rownames(ANPP_by_species)]
    
    
    ### 10cm threshold ####
    ANPP_total_10cm <- cbind(sum(s.ANPP[ss.trees.larger.10cm]) / hectares)
    rownames(ANPP_total_10cm) <- "total"
    n.total_10cm <- sum(idx.tree_survived[ss.trees.larger.10cm])
    
    ANPP_by_species_10cm <- tapply(s.ANPP[ss.trees.larger.10cm], s.species[ss.trees.larger.10cm], sum, na.rm = T) / hectares
    ANPP_by_species_10cm <- cbind(ANPP_by_species_10cm[order(ANPP_by_species_10cm, decreasing = T)])
    n.species_10cm <- table(s.species[ss.trees.larger.10cm])[rownames(ANPP_by_species_10cm)]
    
    
    # save results ####
    results <- rbind(ANPP_total, ANPP_by_species)
    results_10cm <- rbind.data.frame(ANPP_total_10cm, ANPP_by_species_10cm)
    
    all_results <- data.frame(species = rownames(results), "ANPP_Mg.C.ha1.y1_1cm" = results, n_1cm = c(n.total, n.species), "ANPP_Mg.C.ha1.y1_10cm" = results_10cm[rownames(results),], n_10cm = c(n.total_10cm, n.species_10cm[rownames(results)[-1]]))
    
    
    all_results <- all_results[!is.na(all_results$ANPP_Mg.C.ha1.y1_1cm),]
    
    all_results_all_censuses <- rbind(all_results_all_censuses, 
                                      data.frame(census_interval = paste0("census_", c, "_", c+1), 
                                                 all_results))
    
  } # for(c in c(1:Censuses))
  
  
  
  if(with.recruitement) write.csv(all_results_all_censuses, file = "summary_data/ANPP_total_and_by_species.csv", row.names = F)
  if(!with.recruitement) write.csv(all_results_all_censuses, file = "summary_data/ANPP_total_and_by_species_without_recruitment.csv", row.names = F)
  
  
  
  
} # for(with.recruitement in c(TRUE, FALSE))

