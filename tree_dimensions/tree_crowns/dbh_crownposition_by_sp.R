# analysis for Ian paper

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns")

dendrofull <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns/dendro_cored_full.csv")


#dataframe subsets ####
## separate chronologies by canopy position

highcan <- subset(dendrofull, crown.position == "D" | crown.position == "C")
lowcan <- subset(dendrofull, crown.position == "I" | crown.position == "S")

## separate trees by dbh (above and below 35cm)
highdbh <- subset(dendrofull, dbh2018>350)
lowdbh <- subset(dendrofull, dbh2018<=350)

#graphs #####
library(ggplot2)

pdf(file="DBH_CrownPosition_by_all_sp.pdf", width=10)

dendrofull$crown.position <- as.character(dendrofull$crown.position)
dendrofull$crown.position <- ifelse(dendrofull$dbh2018>0 & dendrofull$tree.notes == "CF", "C", dendrofull$crown.position)

##subset by 
dendro2018 <- subset(dendrofull, dendrofull$dbh2018>=0 & !(is.na(dendrofull$crown.position)))

## graph DBH abundance by canopy position
ggplot(data = dendro2018) +
  aes(x = dbh2018, fill = crown.position) +
  geom_histogram(bins = 50) +
  scale_fill_brewer(palette = "Paired") +
  scale_x_continuous(breaks=c(0,350,1500)) +
  labs(title = "DBH by Crown Position",
       x = "dbh2018 (mm)",
       y = "Count") +
  theme_minimal()

## graph DBH by canopy position and sp
ggplot(data = dendro2018) +
  aes(x = sp,fill = crown.position, weight = dbh2018/100) +
  geom_bar() +
  scale_y_continuous(breaks=c(0,350,1500)) +
  labs(title = "DBH and Crown Position by Sp",
       x = "sp",
       y = "dbh2018 (mm)") +
  theme_minimal()
dev.off()

#which cores used in final chronologies ####
cored <- subset(dendrofull, cored == 1)
