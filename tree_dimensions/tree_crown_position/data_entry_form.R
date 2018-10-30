#create data entry form for crown position

##the main csv is located in the Dendrobands repo
dendro_cored_full <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/data/clean_data_files/dendro_cored_full.csv")

library(dplyr)
dendro <- dendro_cored_full %>%
  filter(status=="A")

dendro <- dendro[c(1:4,7:10)]
dendro$crown.position <- ""

write.csv(dendro, "scbi.crownposition.csv")
