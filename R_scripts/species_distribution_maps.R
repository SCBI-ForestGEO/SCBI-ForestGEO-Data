###############################################
# Purpose: Create maps via 'ggplot2' that displays the distribution of each species throughout the SCBI plot
# Developed by: Alyssa Terrell - terrella3@si.edu | Altered by Ian McGregor
# R version 3.5.2 - First created April 2019
###############################################

# install needed packages
library(fgeo) #sp is loaded with this package
library(ggplot2)
library(rgdal)
library(broom) # for the tidy function
library(sf) # for mapping
library(ggthemes) # needed for plot theme

# Script to go from SIGEO quadrat coordinates to SIGEO grid coordinates to NAD83 coordinates #####
# Following chunk of code is sourced from the original found within the 'spatial_data' folder located in the SCBI-ForestGEO-Data repo on GitHub

# Using 2018 data
library(RCurl) 

sigeo <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/scbi.stem3_TEMPORARY.csv"))

# plot grid coordinates to see if they make sense
plot(sigeo$gx, sigeo$gy)

## get local coordinates by calculating based on grid coordinates.
## To replicate, you subtract gx by (20*(quadrat divided by 100) minus 1).
## For gy, it's the same thing but the remainder of the quadrat divided by 100.
sigeo$lx <- sigeo$gx - 20*((sigeo$SiteID %/% 100) - 1)
sigeo$ly <- sigeo$gy - 20*((sigeo$SiteID %% 100) - 1)

#round local coordinates to nearest tenth
sigeo$lx <- round(sigeo$lx, digits = 1)
sigeo$ly <- round(sigeo$ly, digits = 1)

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
utmcoor <- SpatialPoints(cbind(sigeo$NAD83_X, sigeo$NAD83_Y), proj4string=CRS("+proj=utm +zone=17N"))
longlatcoor <- spTransform(utmcoor, CRS("+proj=longlat"))

# add the results ('latlongcoor' output) as two new columns in original dataframe 
sigeo$lat <- coordinates(longlatcoor)[,2]
sigeo$lon <- coordinates(longlatcoor)[,1]
plot(sigeo$lon, sigeo$lat)

# following part of script is to create maps species within the plot ####

## files can be found in the ForestGEO-Data repo on GitHub
scbi_plot <- readOGR("spatial_data/shapefiles/20m_grid.shp")
ForestGEO_grid_outline <- readOGR("spatial_data/shapefiles/ForestGEO_grid_outline.shp")
deer <- readOGR("spatial_data/shapefiles/deer_exclosure_2011.shp")
roads <- readOGR("spatial_data/shapefiles/SCBI_roads_edits.shp")
streams <- readOGR("spatial_data/shapefiles/SCBI_streams_edits.shp")
contour_10m <- readOGR("spatial_data/shapefiles/contour10m_SIGEO_clipped.shp")


# convert all shp to dataframe so that it can be used by ggplot ####
# if tidy isn't working, can also do: xxx_df <- as(xxx, "data.frame")

#Use this option if you want to visualize the plot WITH quadrat/grid lines
scbi_plot_df <- tidy(scbi_plot)

#Use this option if you want to visualize the plot WITHOUT quadrat/grid lines
#ForestGEO_grid_outline_df <- tidy(ForestGEO_grid_outline) 

deer_df <- tidy(deer)
roads_df <- tidy(roads)
streams_df <- tidy(streams)
contour_10m_df <- tidy(contour_10m)

# x and y give the x/yposition on the plot; sprintf says to add 0 for single digits, the x/y=seq(...,length.out) says fit the label within these parameters, fitting the length of the label evenly.

## this code adds the row and column numbers based on coordinates
rows <- annotate("text", x = seq(747350, 747365, length.out = 32), y = seq(4309125, 4308505, length.out = 32), label = sprintf("%02d", 32:1), size = 3, color = "black")

cols <- annotate("text", x = seq(747390, 747765, length.out = 20), y = seq(4308495, 4308505, length.out = 20), label = sprintf("%02d", 1:20), size = 2.8, color = "black")

# this will be the foundation of where the data points from each species within each census will go ####

### needed to add contour lines - online research says that function needed to do this is upgraded to current R version yet
# library(directlabels)
# direct.label.ggplot(ggplot_test, method="bottom.pieces")

# make a for loop for all species
sigeo$Tree_Status <- as.character(sigeo$Tree_Status)

sigeo$Tree_Status[sigeo$Tree_Status %in% c("Dead")] <- "dead"
sigeo$Tree_Status[sigeo$Tree_Status %in% c("Live", "prior", "lost_stem")] <- "live"

# for loop for making maps for all species
for(i in seq(along = unique(sigeo$SPPCODE))){
  focus_sp <- unique(sigeo$SPPCODE)[[i]]
  focus_sp_df <- sigeo[sigeo$SPPCODE == focus_sp, ]
  focus_sp_alive <- subset(focus_sp_df, Tree_Status == "live")
  focus_sp_dead <- subset(focus_sp_df, Tree_Status == "dead")
  
  #ggplot code ####
  ggplot_test <- ggplot() +
    geom_point(data = focus_sp_alive, aes(x = NAD83_X, y = NAD83_Y, color = DBHcm)) +
    #color for focus_sp_dead = black by default!! This is not included in legend.
    geom_point(data = focus_sp_dead, aes(x = NAD83_X, y = NAD83_Y)) +
    #geom_path(data = ForestGEO_grid_outline_df, aes(x = long, y = lat, group = group)) +
    geom_path(data = scbi_plot_df, aes(x = long, y = lat, group = group)) +
    geom_path(data = roads_df, aes(x = long, y = lat, group = group), color = "brown",
              linetype = 2, size = 0.8) +
    geom_path(data = streams_df, aes(x = long, y = lat, group = group), color = "blue", size = 0.5) +
    labs() +
    geom_path(data = deer_df, aes(x = long, y = lat, group = group), size = .7) +
    geom_path(data = contour_10m_df, aes(x = long, y = lat, group = group), color = "gray", linetype = 1) +
    scale_colour_gradientn(colours=rainbow(3)) +
    ### scale_fill_continuous(type = "viridis") + ###
    ### scale_color_viridis_c() + ###
    theme(plot.title = element_text(vjust=0.1),
          axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank()) +
    coord_sf(crs = "crs = +proj=merc", xlim = c(747350, 747800), ylim = c(4308500, 4309125)) +
    theme(panel.grid.major = element_line(colour = 'transparent')) +
    theme(legend.position = "bottom", legend.box = "horizontal") +
    theme(panel.background = element_rect(fill = "gray98")) +
    ggtitle(paste0(focus_sp, "_2018")) +
    rows +
    cols
  
  #save maps to folder
  ggsave(filename = paste0("spatial_data/species_maps/", focus_sp, ".jpg"), plot = ggplot_test)
}
