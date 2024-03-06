######################################################
# Purpose: Script to go from SIGEO quadrat coordinates to SIGEO grid coordinates to NAD83 coordinates
# Developed by: Dunbar Carpenter, 2/1/2011
## Edited by: Jonathan Thompson, 2/1/2011
## Modified by: Erika Gonzalez, 3/1/2017 & Ian McGregor 4/8/2019
## Converted into function by Ian McGregor 7/23/2019
# R version 3.5.3
######################################################
library(sf)
library(dplyr)


# quadrat coordinates to plot coordinates (lx,ly to gx,gy) -----------------

lxly_to_gxgy <- function(lxlyquadrat) {
  
  
  if(!ncol(lxlyquadrat) == 3) stop("gxgy should be a dataframe with three columns: first quadrat x, second quadrat y and third quadrat")
  
  lx <- lxlyquadrat[[1]]
  ly <- lxlyquadrat[[2]]
  quadrat <- lxlyquadrat[[3]]
  
  quadrat <- as.numeric(quadrat)
  
  row <- quadrat %/% 100
  col <- quadrat %% 100
  
  
  gx <- 20*(row-1) + lx
  gy <- 20*(col-1) + ly

  
  #round coordinates to nearest tenth
  gx <- round(gx, digits=1)
  gy <- round(gy, digits=1)
  
  data.frame(gx, gy)
  
}




# plot coordinates to quadrat coordinates (gx,gy to lx, ly) ---------------


gxgy_to_lxly <- function(gxgyquadrat) {
  
  if(!ncol(gxgyquadrat) == 3) stop("gxgy should be a dataframe with three columns: first plot x, second plot y and third quadrat")
  
  gx <- gxgyquadrat[[1]]
  gy <- gxgyquadrat[[2]]
  quadrat <- gxgyquadrat[[3]]
  
  quadrat <- as.numeric(quadrat)
  
  row <- quadrat %/% 100
  col <- quadrat %% 100
  
  lx <- gx - 20*(row - 1)
  ly <- gy - 20*(col - 1)
  
  #round local coordinates to nearest tenth
  lx <- round(lx, digits=1)
  ly <- round(ly, digits=1)
  
  data.frame(lx, ly)
  
}


# plot coordinates to lat lon and NAD83  (gx,gy to NAD83_X,NAD83_Y and x,y)  --------------------
gxgy_to_NAD83_and_lonlat <- function(gxgy) {

  if(!ncol(gxgy) == 2) stop("gxgy should be a dataframe with two columns: first plot x, second plot y")
  
  gx <- gxgy[[1]]
  gy <- gxgy[[2]]

  quadrat <- as.numeric(quadrat)
  
  ## NAD83 coordinates of the SW and NW corners of the SIGEO plot
  ## projection is "+proj=utm +zone=17N"
  NAD83.SW <- c(747385.521, 4308506.438)                
  NAD83.NW <-  c(747370.676, 4309146.156) 
  
  ## Angle (in radians) at which the plot's western boundary is offset from true NAD83 line of latitude
  Offset <- atan2(NAD83.NW[1] - NAD83.SW[1], NAD83.NW[2] - NAD83.SW[2])
  
  ## Function that transforms grid coordinates into NAD83 coordinates
  grid2nad83 <- function(x, y) {
    NAD83.X <- NAD83.SW[1] + (x*cos(Offset) + y*sin(Offset))
    NAD83.Y <- NAD83.SW[2] + (-x*sin(Offset) + y*cos(Offset))
    nad83 <- data.frame(NAD83.X, NAD83.Y)
    names(nad83) <- c("NAD83_X", "NAD83_Y")
    nad83
  }
  
  ## get NAD83 coordinate
  NAD83 <- grid2nad83(gx, gy)
  
  ## transform them to lat and lon
  NAD83_sf <- st_as_sf(NAD83, coords = c("NAD83_X", "NAD83_Y"), crs = "+proj=utm +zone=17N")
  lonlat_sf <- st_transform(NAD83_sf,"+proj=longlat")
  
  lonlat_sf <-  st_coordinates(lonlat_sf)
  names(lonlat_sf) <- c("x", "y")
  # add the results as two new columns
  
  data.frame(NAD83, lonlat_sf)
  
  
  
}


# lonlat to utm, gxgy and lxly ----------------------------------------------------------
lonlat_to_NAD83_and_gxgy <- function(lonlat) {
  if(!ncol(lonlat) == 2) stop("lonlat should be a dataframe with two columns: first longitude, second latitude")
  
  names(lonlat) <- c("x", "y")
  
  lonlat_sf <- st_as_sf(lonlat, coords = c("x", "y"), crs = "+proj=longlat")
    
  NAD83_sf <- st_transform(lonlat_sf, crs = "+proj=utm +zone=17N")

  NAD83 <- as.data.frame(st_coordinates(NAD83_sf))
  names(NAD83) <- c("NAD83_X", "NAD83_Y")
  
  ## NAD83 coordinates of the SW and NW corners of the SIGEO plot
  ## projection is "+proj=utm +zone=17N"
  NAD83.SW <- c(747385.521, 4308506.438)              
  NAD83.NW <- c(747370.676, 4309146.156)        
  NAD83.SE <- c(747784.399, 4308515.935)
  
  ## make a line for the western boundary and one for the southern one
  
  W <- st_cast(summarize(st_as_sf(st_sfc(st_point(NAD83.SW), st_point(NAD83.NW)), crs = "+proj=utm +zone=17N")), "LINESTRING")
  S <-  st_cast(summarize(st_as_sf(st_sfc(st_point(NAD83.SW), st_point(NAD83.SE)), crs = "+proj=utm +zone=17N")), "LINESTRING")
  
  ## get closest distance to lines --> will give gx and gy
  
  gx <- as.numeric(st_distance(NAD83_sf, W))
  gy <- as.numeric(st_distance(NAD83_sf, S))
  
  data.frame(NAD83, gx, gy)
  
}




# Older function taking a whole data set gxgy to NAD83 (not deleting in case of used by old codes) --------------------

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
  sigeo <- data.frame(sigeo, grid2nad83(sigeo$gx, sigeo$gy))
  
  # Add lat lon to the file, first run these 2 lines
  utmcoor <- st_as_sf(sigeo, coords = c("NAD83_X", "NAD83_Y"), crs = "+proj=utm +zone=17N")
  longlatcoor <- st_transform(utmcoor, crs = "+proj=longlat")
  
  #add the results ('latlongcoor' output) as two new columns in original dataframe 
  sigeo$lat<- st_coordinates(longlatcoor)[,2]
  sigeo$lon <- st_coordinates(longlatcoor)[,1]
  plot(sigeo$lon, sigeo$lat)
  
  sigeo_coords <<- sigeo
}

#run a function
# plot_to_UTM(sigeo_orig)

#write a csv if you need to
# write.csv(sigeo, file= "spatial_data/UTM coordinates/scbi_stem_utm_lat_long_2018.csv", row.names=FALSE)
