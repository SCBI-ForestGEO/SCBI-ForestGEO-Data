######################################################
# Purpose: Create shapefile from raster
# Sub-purpose: Create more accurate stream shapefile using TWI raster
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.3 - First created end July 2019
######################################################
library(raster)
library(rgdal)
library(rgeos)
library(broom)

#1 bring in raster and draw lines
plot_TWI <- raster("spatial_data/elevation/rasters/plot_TWI.tif")
grid <- readOGR("spatial_data/shapefiles/20m_grid.shp")
plot(plot_TWI)
plot(grid, add=TRUE)
################################################################################
#2. draw lines from scratch ####
##this function allows you to trace the lines on the raster in the plots window in R.
lines_left <- drawLine(col="blue")
lines_mid <- drawLine(col="blue")
lines_top <- drawLine(col="light blue")

##2a. write separate shapefiles for each line segment ####
##reason for this is easier to update specific line segments if ground-truthing in field or if stream has changed
lines_all <- list(lines_left, lines_mid, lines_top)

#create 3 separate spatiallinesdataframes and then write 3 shapefiles
segments <- c("left", "mid", "top")

for (j in seq(along=1:3)){
  df <- data.frame(len = sapply(1:length(lines_all[[j]]), function(i) 
    gLength(lines_all[[j]][i, ])))
  
  rownames(df) <- sapply(1:length(lines_all[[j]]), function(i) lines_all[[j]]@lines[[i]]@ID)
  
  Sldf <- SpatialLinesDataFrame(lines_all[[j]], data = df)
  
  writeOGR(Sldf, dsn="spatial_data/shapefiles/streams_ForestGEO", layer=paste0("streams_ForestGEO_", segments[[j]]), driver="ESRI Shapefile")
}

##2b. update line segments if need be ####
##read in the shapefiles of the segments you're NOT changing so you can have a basis 
streams_left <- readOGR("spatial_data/shapefiles/streams_ForestGEO/streams_ForestGEO_left.shp")
streams_mid <- readOGR("spatial_data/shapefiles/streams_ForestGEO/streams_ForestGEO_mid.shp")
streams_top <- readOGR("spatial_data/shapefiles/streams_ForestGEO/streams_ForestGEO_top.shp")

##once these are loaded, plot the ones you are not changing, so you have a base for where to re-draw the segment
plot(plot_TWI)
plot(grid, add=TRUE)
plot(streams_left, add=TRUE)
plot(streams_mid, add=TRUE)

lines_top <- drawLine(col="blue")

##convert to spatiallinesdataframe and write to shapefile
df <- data.frame(len = sapply(1:length(lines_top), function(i) 
  gLength(lines_top[i, ])))
rownames(df) <- sapply(1:length(lines_top), function(i) lines_top@lines[[i]]@ID)

Sldf <- SpatialLinesDataFrame(lines_top, data = df)

writeOGR(Sldf, dsn="spatial_data/shapefiles/streams_ForestGEO", layer="streams_ForestGEO_top", driver="ESRI Shapefile")

##2c. combine to 1 shapefile ####
streams_left <- readOGR("spatial_data/shapefiles/streams_ForestGEO/streams_ForestGEO_left.shp")
streams_mid <- readOGR("spatial_data/shapefiles/streams_ForestGEO/streams_ForestGEO_mid.shp")
streams_top <- readOGR("spatial_data/shapefiles/streams_ForestGEO/streams_ForestGEO_top.shp")

#combine the lines together
Sldf_all <- rbind(streams_left, streams_mid, streams_top)

#write to shapefile
writeOGR(Sldf_all, dsn="spatial_data/shapefiles/streams_ForestGEO", layer="streams_ForestGEO_full", driver="ESRI Shapefile")
##2d. test output and projections ####
##it would be a good idea to test the full output with the ForestGEO_plot_map.R script to make sure this works. When this was tested as it was being written, I noticed that sometimes the extent would be off from what it should be, so I had to redraw the segments a couple times. If you need to look this up, it's:

extent(streams_left) #e.g.

##this shapefile does not have a projected CRS (but it plots fine regardless). If the projection is needed, use the same one that the other shapefiles use (e.g. the roads shapefile)

proj4string(Sldf_all) <- CRS("+proj=utm +zone=17 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")