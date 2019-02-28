##### Script to go from SIGEO quadrat coordinates to SIGEO grid coordinates to NAD83 coordinates #####
## written by Dunbar Carpenter ###
## 2/1/2011

#Modified by Erika Gonzalez 03/01/2017

#Read full data or stem data files, bring them from V:\SIGEO\3-RECENSUS 2013\DATA\FINAL DATA to use, to share
#Here we will use stem2, where all stems measured in 2013 (last census) are included.
sigeo <- read.csv("scbi.stem2.csv") 
#from Github/SCBI-ForestGEO-Data/tree_main_census/data/census-csv-files

#plot grid coordinates to see if they make sense
plot(sigeo$gx, sigeo$gy)

## divide 4-digit quadrat number by 100 w/o remainder and w/ remainder to get quadrat x and y columns and rows separately
sigeo$quadrat_x <- as.numeric(as.character(sigeo$quadrat)) %/% 100
sigeo$quadrat_y <- as.numeric(as.character(sigeo$quadrat)) %% 100

names(sigeo)

## get grid coordinates by multiplying each quadrat coordinate by 20 and adding the corresponding within-quadrat coordinate (lx and ly)
sigeo$grid_x <- (sigeo$quadrat_x - 1)
sigeo$grid_y <- (sigeo$quadrat_y - 1)

#Instal this package if you don't have it, get libraries
#install.packages("rgdal")
library(rgdal)
library(sp)

## NAD83 coordinates of the SW and NW corners of the SIGEO plot
NAD83.SW <- c(747385.521, 4308506.438)                     
NAD83.NW <- c(747370.676, 4309146.156)

## Angle (in radians) at which the plot's western boundary is offset from true NAD83 line of latitude
Offset <- atan2(NAD83.NW[1] - NAD83.SW[1], NAD83.NW[2] - NAD83.SW[2])

## Function that transforms grid coordinates into NAD83 coordinates
grid2nad83 <- function(x, y) {
  NAD83.X <- NAD83.SW[1] + (x*cos(Offset) + y*sin(Offset))
  NAD83.Y <- NAD83.SW[2] + (-x*sin(Offset) + y*cos(Offset))
  nad83 <- list(NAD83.X, NAD83.Y)
  names(nad83) <- c("NAD83_X", "NAD83_Y")
  nad83
}

## add NAD83 coordinate columns to SIGEO data table
sigeo<-data.frame(sigeo, grid2nad83(sigeo$gx, sigeo$gy))

# Add lat lon to the file, first run these 2 lines
utmcoor<-SpatialPoints(cbind(sigeo$NAD83_X, sigeo$NAD83_Y), proj4string=CRS("+proj=utm +zone=17N"))
longlatcoor<-spTransform(utmcoor,CRS("+proj=longlat"))

#add the results ('latlongcoor' output) as two new columns in original dataframe 
sigeo$lat<- coordinates(longlatcoor)[,2]
sigeo$lon <- coordinates(longlatcoor)[,1]
plot(sigeo$lon, sigeo$lat)

#write a csv if you need to
write.csv(sigeo, file= "scbi_stem_utm_lat_long.csv", row.names=F)

############################################################################################
# how to find grid corners
library(rgdal)
library(broom)

grid <- readOGR("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/spatial_data", layer="ForestGEO_grid_outline")
grid <- tidy(grid)

grid <- grid[1:4, ]
grid$position <- c("NW", "SW", "SE", "NE")
