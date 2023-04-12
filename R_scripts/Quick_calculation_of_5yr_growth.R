

load("C:/Users/herrmannV/Dropbox (Smithsonian)/GitHub/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree_main_census/data/scbi.stem1.rdata")
load("C:/Users/herrmannV/Dropbox (Smithsonian)/GitHub/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree_main_census/data/scbi.stem2.rdata")
load("C:/Users/herrmannV/Dropbox (Smithsonian)/GitHub/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree_main_census/data/scbi.stem3.rdata")

scbi.stem1$dbh <- as.numeric(scbi.stem1$dbh)
scbi.stem2$dbh <- as.numeric(scbi.stem2$dbh)
scbi.stem3$dbh <- as.numeric(scbi.stem3$dbh)


g1 <- !is.na(scbi.stem1$dbh) & scbi.stem1$dbh > 0 & !is.na(scbi.stem2$dbh) & scbi.stem2$dbh > 0 
g2 <- !is.na(scbi.stem3$dbh) & scbi.stem3$dbh > 0 & !is.na(scbi.stem2$dbh) & scbi.stem2$dbh > 0 

dbh_group1 <- cut(scbi.stem1$dbh[g1])
x <- c((scbi.stem2$dbh[g1] - scbi.stem1$dbh[g1]) / scbi.stem1$dbh[g1] , (scbi.stem3$dbh[g2] - scbi.stem2$dbh[g2]) / scbi.stem2$dbh[g2])

1 + median(x[x>0])
1 + median(x[x<0])

1 + quantile(x[x>0], 0.97)
1 + quantile(x[x<0], 0.03)



mean(x[x>0]) + 3*sd(x[x>0])
mean(x[x<0]) - 3*sd(x[x<0])
