# analysis for Ian paper

setwd("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns")

dendrofull <- read.csv("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/tree_dimensions/tree_crowns/dendro_cored_full.csv")

#dataframe subsets ####
## separate chronologies by canopy position

highcan <- subset(dendrofull, (crown.position == "D" | crown.position == "C") & status == "alive")
lowcan <- subset(dendrofull, (crown.position == "I" | crown.position == "S") & status == "alive")

## separate trees by dbh (above and below 35cm)
highdbh <- subset(dendrofull, dbh2018>350 & status == "alive")
lowdbh <- subset(dendrofull, dbh2018<=350 & status == "alive")

#graphs #####
library(ggplot2)

pdf(file="DBH_CrownPosition_by_Sp.pdf", width=10)

## graph DBH abundance by canopy position
alive <- subset(dendrofull, status == "alive")
ggplot(data = alive) +
  aes(x = dbh2018, fill = crown.position) +
  geom_histogram(bins = 50) +
  scale_fill_brewer(palette = "Paired") +
  scale_x_continuous(breaks=c(0,350,1500)) +
  labs(title = "DBH by Crown Position",
       x = "dbh2018 (mm)",
       y = "Count") +
  theme_minimal()

## graph DBH by canopy position and sp
ggplot(data = alive) +
  aes(x = sp,fill = crown.position, weight = dbh2018/100) +
  geom_bar() +
  scale_y_continuous(breaks=c(0,350,1500)) +
  labs(title = "DBH and Crown Position by Sp",
       x = "sp",
       y = "dbh2018 (mm)") +
  theme_minimal()
dev.off()