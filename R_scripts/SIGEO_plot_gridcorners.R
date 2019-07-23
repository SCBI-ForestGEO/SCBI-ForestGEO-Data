######################################################
# Purpose: Find grid corners from shapefile
# Developed by: Ian McGregor 4/8/2019
# R version 3.5.3
######################################################
library(rgdal)
library(broom)
library(data.table)

#get corner coordinates in UTM
grid <- readOGR("spatial_data/shapefiles", layer="ForestGEO_grid_outline")
grid <- tidy(grid)

grid <- grid[1:4, ]
grid$position <- c("NW", "SW", "SE", "NE")

grid_utm <- grid[, c(1:2)]

#convert coordinates to WGS84
sputm <- SpatialPoints(grid_utm, proj4string=CRS("+proj=utm +zone=17N +datum=WGS84"))
spgeo <- spTransform(sputm, CRS("+proj=longlat +datum=WGS84"))
spgeo <- as.data.frame(spgeo)

setnames(spgeo, old=c("long", "lat"), new=c("long_WGS84", "lat_WGS84"))
grid <- cbind(grid, spgeo)