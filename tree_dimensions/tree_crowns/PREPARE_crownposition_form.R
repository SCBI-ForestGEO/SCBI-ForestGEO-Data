#create form that only shows crown position

##the main csv is located in the Dendrobands repo
dendro_cored_full <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_dimensions/tree_crown_cored_geo/dendro_cored_full.csv")

library(dplyr)
dendro <- dendro_cored_full %>%
  filter(status=="A")

dendro <- dendro[c("tag", "stemtag", "sp", "quadrat", "biannual", "cored", "year.cored", "dbh2008", "dbh2013", "illum", "crown.condition", "crown.position", "tree.notes")]

dendro$dbh2018 <- ""

dendro <- dendro[c(1:9,14,10:13)]

write.csv(dendro, "scbi_crown.csv", row.names=FALSE)
