# sort cores for Neil

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data_private/tree_cores/chronologies/current_chronologies")

core_list <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns/core_list_for_neil.csv")

library(dplR)

species <- core_list$sp[!duplicated(core_list$sp)]
species <- as.vector(species)

for (sp in species){
  sp1 <- read.rwl(paste0(sp, "_drop.rwl"))
  
  sp1_can <- core_list$tag[core_list$sp %in% sp & core_list$crown.position=="canopy"]
  sp1_can <- ifelse(sp1_can %in% colnames(sp1), sp1_can, paste0(sp1_can,"A"))
  sp1_can <- ifelse(sp1_can %in% colnames(sp1), sp1_can, paste0("0", sp1_can))
  sp1_canopy <- sp1[,names(sp1) %in% sp1_can, drop=F] #drop=F only for frni_canopy
  write.rwl(sp1_canopy, paste0(sp, "_drop_canopy.rwl"), long.names=TRUE)
  
  sp1_sub <- core_list$tag[core_list$sp %in% sp & core_list$crown.position=="sub-canopy"]
  sp1_sub <- ifelse(sp1_sub %in% colnames(sp1), sp1_sub, paste0(sp1_sub,"A"))
  sp1_sub <- ifelse(sp1_sub %in% colnames(sp1), sp1_sub, paste0("0", sp1_sub))
  sp1_subcan <- sp1[, colnames(sp1) %in% sp1_sub]
  write.rwl(sp1_subcan, paste0(sp, "_drop_subcanopy.rwl"), long.names=TRUE)
}








## for troubleshooting
frni <- read.rwl("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data_private/tree_cores/chronologies/current_chronologies/frni_drop.rwl")


  frni_can <- core_list$tag[core_list$sp=="frni" & core_list$crown.position=="canopy"]
  frni_can <- ifelse(frni_can %in% colnames(frni), frni_can, paste0(frni_can, "A"))
  frni_can <- ifelse(frni_can %in% colnames(frni), frni_can, paste0("0", frni_can))
  frni_canopy <- frni[,names(frni) %in% frni_can, drop=F] 
  #drop=F forces this to be a dataframe even though there's only one variable
  
  write.rwl(frni_canopy, "frni_drop_canopy.rwl", long.names=TRUE)
       
  frni_sub <- core_list$tag[core_list$sp=="frni" & core_list$crown.position=="sub-canopy"]
  frni_sub <- ifelse(frni_sub %in% colnames(frni), frni_sub, paste0(frni_sub,"A"))
  frni_sub <- ifelse(frni_sub %in% colnames(frni), frni_sub, paste0("0", frni_sub))
  frni_subcan <- frni[, colnames(frni) %in% frni_sub]
  write.rwl(frni_subcan, "frni_drop_subcanopy.rwl", long.names=TRUE)
  
  
