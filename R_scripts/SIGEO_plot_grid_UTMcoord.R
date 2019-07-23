######################################################
# Purpose: Script to go from SIGEO quadrat coordinates to SIGEO grid coordinates to NAD83 coordinates
# Developed by: Dunbar Carpenter, 2/1/2011
## Edited by: Jonathan Thompson, 2/1/2011
## Modified by: Erika Gonzalez, 3/1/2017 & Ian McGregor 4/8/2019
## Converted into function by Ian McGregor 7/23/2019
# R version 3.5.3
######################################################
library(RCurl)
library(rgdal)
library(sp)

# greyed out so that way this script can be sourced
# sigeo_orig <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/scbi.stem3.csv"), stringsAsFactors=FALSE)


# write a function
plot_to_UTM <- function(df) {
  
  sigeo <- df
  
  #plot grid coordinates to see if they make sense
  plot(sigeo$gx, sigeo$gy)
  
  ## get local coordinates by calculating based on grid coordinates.
  ## To replicate, you subtract gx by (20*(quadrat divided by 100) minus 1).
  ## For gy, it's the same thing but the remainder of the quadrat divided by 100.
  sigeo$lx <- sigeo$gx - 20*((sigeo$quadrat %/% 100) - 1)
  sigeo$ly <- sigeo$gy - 20*((sigeo$quadrat %% 100) - 1)
  
  #round local coordinates to nearest tenth
  sigeo$lx <- round(sigeo$lx, digits=1)
  sigeo$ly <- round(sigeo$ly, digits=1)
  
  names(sigeo)
  
  ## these lines below are greyed out because they do were originally used to calculate the lx and ly (which are done above in one line of code). They can be deleted, but are kept for posterity.
  
  ## divide 4-digit quadrat number by 100 w/o remainder and w/ remainder to get quadrat x and y columns and rows separately
  # sigeo$quadrat_x <- as.numeric(as.character(sigeo$quadrat)) %/% 100
  # sigeo$quadrat_y <- as.numeric(as.character(sigeo$quadrat)) %% 100
  
  ## get grid coordinates by multiplying each quadrat coordinate by 20 and adding the corresponding within-quadrat coordinate (lx and ly).
  ## this is greyed out because it's reflected in the full calculation below
  # sigeo$grid_x <- 20*(sigeo$quadrat_x - 1)
  # sigeo$grid_y <- 20*(sigeo$quadrat_y - 1)
  
  
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
  
  sigeo_coords <<- sigeo
}

#run a function
# plot_to_UTM(sigeo_orig)

#write a csv if you need to
# write.csv(sigeo, file= "spatial_data/UTM coordinates/scbi_stem_utm_lat_long_2018.csv", row.names=FALSE)
