######################################################
# Purpose: calculating neighborhood basal area (NBA) for ForestGEO plot trees
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created April 2019
######################################################

#this script recreates the efforts done by Alan Tepley from Gonzalez et al 2016: https://esajournals.onlinelibrary.wiley.com/doi/epdf/10.1002/ecs2.1595, whereby neighborhood basal area was calculated by summing the basal area of all trees within a given distance of a focal tree. Specifically, basal area for this paper was calculated to 30m at a distance increment of 0.5m. Initial calculations were done in Excel.

#for trees that have >1 stem that is at least 10cm dbh (1 individual in 2013), Tepley said, "When I calculated neighborhood basal area for the tree with Tag Number 60108 and Stem Tag 1, I would exclude the basal area for that stem and include the basal area for the tree with Tag Number 60108 and Stem Tag 2, and the distance to that tree is 0 meters."

#Tepley also created a calculation such that if a focal tree was within 30m of the ForestGEO plot edge, then that distance away he would give the NBA to be 0. For example, if a tree was 15m from the ForestGEO edge, that tree would have 0 NBA until distance 15.5m. This has not been replicated in this script, but it should be acknowledged that this was the original intent.

#script
library(data.table)
library(RCurl)

scbi.full2 <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/scbi.stem2.csv"), stringsAsFactors=FALSE)

setnames(scbi.full2, old="StemTag", new="stemtag")
scbi.full2[5340, 3] <- 40874 #duplicated tag (above 10cm dbh), fixed in 2018 data
scbi.full2[7112, 7] <- 110.0 #60108 stem 2 for some reason has coordinates which
scbi.full2[7112, 8] <- 95.5 #differ from stem 1. These lines of code fix that.
scbi.full2 <- scbi.full2[scbi.full2$dbh>=100, ]#& !grepl("S", scbi.full2$codes), ]

trees <- scbi.full2[c(2,7,8)] #IMPORTANT: working off stemID here
rownames(trees) <- trees[,1]
trees <- trees[, -1]

library(vegan)
d <- vegdist(trees, method="euclidean") #calculate distance between one tree and all the other trees using Pythagorean theorem
m <- data.frame(t(combn(rownames(trees),2)), as.numeric(d)) #put in df format
names(m) <- c("tree1", "tree2", "distance")
simple <- m[m$distance<=30, ] #only include distances of 30m or less
simple <- simple[order(simple$tree1, simple$distance), ] #sort by tree and distance
rm(m) #because the file is so massive
rm(d) #also because the file is large

simple$tree1 <- as.numeric(as.character(simple$tree1))
simple$tree2 <- as.numeric(as.character(simple$tree2))

full_trees <- c(simple$tree1, simple$tree2)

scbi.sub <- scbi.full2[scbi.full2$stemID %in% unique(full_trees), ] #this number may match scbi.full2, but may not if some trees > 30m from another tree

scbi.sub <- scbi.sub[c(2,3,4,7,8,11)]
scbi.sub$dbh <- scbi.sub$dbh/10 #dbh needs to be in cm for basal area equation
scbi.sub$basal <- (pi*(scbi.sub$dbh/2)^2)*0.0001

dist <- seq(0,30, by=0.5)
dist <- gsub("^", "dist.m_", dist)
scbi.sub[, dist] <- NA

scbi.sub_list <- lapply(scbi.sub$stemID, function(x){
  scbi.sub[scbi.sub$stemID == x, ]}) #separate each stem into separate dataframe
names(scbi.sub_list) <- scbi.sub$stemID

dist_shift <- dist[-1] #get rid of x0 in the list now that you've defined it

edge <- scbi.sub[scbi.sub$gx > 370 | scbi.sub$gy > 610, ] #see which trees are close to plot edge





#in short, the loop below does the following:
#1. defines a focal tree, creates df "test" with all distances of that focal tree (line 72-75)
#2. Adds column to test with all the trees the focal is relating to, plus the basal area of each one (line 77-82)
#3. Split test into separate dataframes (test_list) to make it easier to work with (line 84-86)
#4. Filter scbi.sub_list by the focal tree to "z". (line 88)
#5. Following line 7 above, if there is a multistem (in other words, if the distance to the nearest tree = 0m, then the starting basal area should be the basal area of the other stem). (line 89)
##5a. NOTED: this will make problems when including things like havi in this analysis. Be aware what size class you're focusing on and adjust as needed.
#6. Make each element of test_list a separate df "w". Then, define column indices to use (inc, inc_num, inc_prev). For each increment (inc and inc_num), subset the df "w" so that it returns all trees with distances less than the number of inc_num. Then, fill in df "z" whereby if inc_num is less than the max distance in the subset "w", fill in that column in "z" with the value of inc_prev. Otherwise, if inc is greater than the max distance, add the basal area from x0 to the sum of the basal areas in the filtered "w" df. (lines 93-115)
#7. Add z to list "full", then rbind to one df "all_dist". (lines 117-120)

all_dist <- NULL
full <- list() #NB this loop will take >60 minutes
for (j in seq(along=unique(simple$tree1))){
  tree <- unique(simple$tree1)[[j]] #one tree at a time
  test <- simple[simple$tree1 == tree | simple$tree2 == tree, ] #filter by tree
  test <- test[order(test$distance), ] #order by distance
  
  test$diff <- sapply(1:nrow(test), function(x){
    ifelse(test[x,1] == tree, test[x,2], 
      ifelse(test[x,2] == tree, test[x,1], test$diff))})
  
  #get basal area for tags that aren't the focal tree
  test$basal_diff <- scbi.sub$basal[match(test$diff, scbi.sub$stemID)] 
  
  test_list <- lapply(unique(test$diff), function(x){
    test[test$diff == x, ] }) #split test into separate df
  names(test_list) <- unique(test$diff)

  z <- scbi.sub_list[[grep(paste0("^",tree,"$"), names(scbi.sub_list))]]
  z$dist.m_0 <- ifelse(test$distance[1] == 0, test$basal_diff[1], 
                       ifelse((z$gx>= (400-30) & (400-z$gx)>0)|
                              (z$gy>= (640-30) & (640-z$gy)>0), NA, z$basal)) #this line of code follows Tepleys' intial calculation as described above in line 7.
  
  for (q in seq(along=test_list)){
    w <- test_list[[q]]
    w$distance <- as.numeric(w$distance)
    
    for (i in seq(along=dist_shift)){
      inc <- dist_shift[[i]]
      inc_num <- gsub("dist.m_", "", inc)
      inc_num <- as.numeric(inc_num)
      inc_num_prev <- inc_num - 0.5
      inc_prev <- gsub("^", "dist.m_", inc_num_prev)
      
      w <- test[test$distance < inc_num, ]
      
      #if we don't care about distance to plot edge and want to caluclate NBA regardless, then use the following lines:
      # z[, inc] <- ifelse(inc_num < max(w$distance), z[, inc_prev],
      #                    sum(ifelse(is.na(z$dist.m_0), z$basal, z$dist.m_0), w$basal_diff))

      #this version is a little complicated but follows Tepley's intial calculations. This is saying if the tree is within the increment distance to the plot edge (max 30m), then the basal area is NA. If it's not then if the increment distance is less than the total distance in w, there are two options: put the value in z$basal is the previous increment is NA, or if not NA, put that previous value. If the increment distance is greater than the total distance in w, then do a sum of the distances in w$distance and z$basal (if z$dist.m_0 is NA) or z$dist.m_0 (if it is not NA).
      z[, inc] <- ifelse((z$gx>= (400-30) & inc_num < (400-z$gx))|
                        (z$gy>= (640-30) & inc_num < (640-z$gy)), NA,
                         ifelse(inc_num < max(w$distance),
                                ifelse(is.na(z[, inc_prev]), z$basal, z[, inc_prev]),
                                sum(ifelse(is.na(z$dist.m_0), z$basal, z$dist.m_0), w$basal_diff)))

     full[[j]] <- z
    }
  }
  all_dist <- rbind(all_dist, full[[j]])
}



#NB this is a LARGE file (~78Mb)
write.csv(all_dist, "tree_dimensions/tree_crowns/neighborhood_basal_area_2013.csv", row.names=FALSE) 
