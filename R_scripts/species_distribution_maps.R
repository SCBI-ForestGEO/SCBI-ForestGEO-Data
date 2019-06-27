###############################################
# Purpose: Create maps via 'ggplot2' that displays the distribution of each species throughout the SCBI plot
# Developed by: Alyssa Terrell - terrella3@si.edu | Modified by Ian McGregor
# R version 3.5.2 - First created April 2019
###############################################

library(RCurl) #1
library(rgdal) #2a
library(fgeo) #2a (sp is loaded), 5
library(broom) #2a for the tidy function
library(ggplot2) #3, 4
library(sf) #4 for mapping
library(ggthemes) #4 needed for plot theme


#1 Convert SIGEO coordinates to decimal degrees and UTM NAD83 coordinates #####
# This chunk of code is sourced from the original found within the 'spatial_data' folder located in the SCBI-ForestGEO-Data repo on GitHub
## contributors: Dunbar Carpenter, Jonathan Thompson, Erika Gonzalez-Akre, Ian McGregor

##NOTES FOR #1
###until the 2018 data is public, this raw website will need to be sporadically updated because it is coming from a private repo
###this means the column names WILL need to be updated eventually
sigeo <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/master/census%20data/ViewFullTable_crc_master.csv?token=AJNRBEKU5NOO5E7BOP73SHS5DYGNI"), stringsAsFactors = FALSE)

sigeo <- sigeo[sigeo$CensusID == 3, ]

# plot grid coordinates to see if they make sense
plot(sigeo$PX, sigeo$PY)

## get local coordinates by calculating based on grid coordinates.
## To replicate, you subtract gx by (20*(quadrat divided by 100) minus 1).
## For gy, it's the same thing but the remainder of the quadrat divided by 100.
sigeo$lx <- sigeo$PX - 20*((sigeo$QuadratName %/% 100) - 1)
sigeo$ly <- sigeo$PY - 20*((sigeo$QuadratName %% 100) - 1)

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
sigeo <- data.frame(sigeo, grid2nad83(sigeo$PX, sigeo$PY))

# Add lat lon to the file, first run these 2 lines
utmcoor <- SpatialPoints(cbind(sigeo$NAD83_X, sigeo$NAD83_Y), proj4string=CRS("+proj=utm +zone=17N"))
longlatcoor <- spTransform(utmcoor, CRS("+proj=longlat"))

# add the results ('latlongcoor' output) as two new columns in original dataframe 
sigeo$lat <- coordinates(longlatcoor)[,2]
sigeo$lon <- coordinates(longlatcoor)[,1]
plot(sigeo$lon, sigeo$lat)

#2 Load data to create maps ####
##2a. Load in shapefiles ####
scbi_plot <- readOGR("spatial_data/shapefiles/20m_grid.shp")
ForestGEO_grid_outline <- readOGR("spatial_data/shapefiles/ForestGEO_grid_outline.shp")
deer <- readOGR("spatial_data/shapefiles/deer_exclosure_2011.shp")
roads <- readOGR("spatial_data/shapefiles/SCBI_roads_edits.shp")
streams <- readOGR("spatial_data/shapefiles/SCBI_streams_edits.shp")
contour_10m <- readOGR("spatial_data/shapefiles/contour10m_SIGEO_clipped.shp")

#Use this option if you want to visualize the plot WITH quadrat/grid lines
# scbi_plot_df <- tidy(scbi_plot)

#Use this option if you want to visualize the plot WITHOUT quadrat/grid lines
scbi_plot_df <- tidy(ForestGEO_grid_outline) 

###if tidy isn't working, can also do: xxx_df <- as(xxx, "data.frame")
deer_df <- tidy(deer)
roads_df <- tidy(roads)
streams_df <- tidy(streams)
contour_10m_df <- tidy(contour_10m)


#2b. Get contour labels ####
##needed to add contour lines - online research says that function needed to do this is upgraded to current R version yet
# library(directlabels)
# direct.label.ggplot(ggplot_test, method="bottom.pieces")

elevation_labels <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/spatial_data/elevation/contour10m_SIGEO_coords.csv"), stringsAsFactors = FALSE)

#3. Define axis labels to add to plot maps ####
##this code adds in meter marks and associated tick marks
x_meters <- annotate("text", 
                     x = seq(747390, 747780, length.out = 5), 
                     y = seq(4308495, 4308505, length.out = 5), 
                     label = c("0", "100", "200", "300", "400"), 
                     size = 3, color = "black")

y_meters <- annotate("text", 
                     x = seq(747350, 747365, length.out = 7), 
                     y = seq(4309125, 4308505, length.out = 7), 
                     label = c("600", "500", "400", "300", "200", "100", "0"), 
                     size = 3, color = "black")

x_ticks <- annotate("point",
                    x = seq(747386, 747786, length.out = 5), 
                    y = seq(4308506, 4308515, length.out = 5),
                    shape = 3,
                    color = "black")

y_ticks <- annotate("point",
                    x = seq(747371, 747386, length.out = 7),
                    y = seq(4309125, 4308506, length.out = 7), 
                    shape = 3,
                    color = "black")

## this code adds the row and column numbers based on coordinates
rows <- annotate("text", x = seq(747350, 747365, length.out = 32), y = seq(4309125, 4308505, length.out = 32), label = sprintf("%02d", 32:1), size = 3, color = "black")

cols <- annotate("text", x = seq(747390, 747765, length.out = 20), y = seq(4308495, 4308505, length.out = 20), label = sprintf("%02d", 1:20), size = 2.8, color = "black")
# x and y give the x/yposition on the plot; sprintf says to add 0 for single digits, the x/y=seq(...,length.out) says fit the label within these parameters, fitting the length of the label evenly.

##add this code at end of loop above and before saving
ggplot_test <- ggplot_test + rows + cols

#4. Loop to create maps for all species ####
##reminder as from #1 above, these column names and statuses WILL need to be changed when the 2018 data goes public

##prepare sigeo
sigeo$Status <- ifelse(grepl("dead", sigeo$Status), "dead", "live")
sigeo$DBH <- ifelse(grepl("dead", sigeo$Status), 0, sigeo$DBH)
sigeo$DBH <- as.numeric(sigeo$DBH)
sigeo$color <- ifelse(sigeo$DBH == 0, "black",
                      ifelse(sigeo$DBH >0 & sigeo$DBH<=100, "green",
                      ifelse(sigeo$DBH > 100 & sigeo$DBH <= 350, "gold", "blue")))

##make maps
for(i in seq(along = unique(sigeo$Mnemonic))){
  focus_sp <- unique(sigeo$Mnemonic)[[i]]
  focus_sp_df <- sigeo[sigeo$Mnemonic == focus_sp, ]
  focus_sp_alive <- subset(focus_sp_df, Status == "live")
  focus_sp_dead <- subset(focus_sp_df, Status == "dead")
  
  #ggplot code ####
  sp_map <- ggplot() +
    geom_point(data = focus_sp_alive, aes(x = NAD83_X, y = NAD83_Y), color = focus_sp_alive$color) +
    geom_point(data = focus_sp_dead, aes(x = NAD83_X, y = NAD83_Y), color = focus_sp_dead$color) +
    geom_path(data = scbi_plot_df, aes(x = long, y = lat, group = group)) +
    geom_path(data = roads_df, aes(x = long, y = lat, group = group), color = "brown",
              linetype = 2, size = 0.8) +
    geom_path(data = streams_df, aes(x = long, y = lat, group = group), color = "light blue", size = 0.5) +
    geom_path(data = deer_df, aes(x = long, y = lat, group = group), size = .7) +
    geom_path(data = contour_10m_df, aes(x = long, y = lat, group = group), color = "gray", linetype = 1) +
    theme(plot.title = element_text(vjust=0.1),
          axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank()) +
    coord_sf(crs = "crs = +proj=merc", xlim = c(747350, 747800), ylim = c(4308500, 4309125)) +
    theme(panel.grid.major = element_line(colour = 'transparent')) +
    # theme(legend.position = "bottom", legend.box = "horizontal") +
    theme(panel.background = element_blank())
  
    ggplot_test <- sp_map + 
      x_meters +
      x_ticks +
      y_meters +
      y_ticks
    
  #save maps to folder
  ggsave(filename = paste0("spatial_data/maps/species_maps/", focus_sp, ".jpg"), plot = ggplot_test)
}

#5. Create map with fgeo package ####
##this package easily creates faceted maps of all species distributions in our plot (as seen below). However, this doesn't allow for manually changing the colors of the points based on DBH, nor does it include the stream and road lines.

## for further reference, see source: https://github.com/forestgeo/fgeo.plot

#note, read_vft specifically is regarding the "ViewFullTable" file
test <- read_vft(file = (getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/master/census%20data/ViewFullTable_crc_master.csv?token=AJNRBEKU5NOO5E7BOP73SHS5DYGNI")))

setnames(test1, old=c("PX", "PY", "Mnemonic"), new=c("gx", "gy", "sp"))

elevation <- scbi_elev

test1 <- test %>%
  filter(CensusID == 3) %>%
  filter(sp %in% c("libe"))



autoplot(sp_elev(test1, elevation))
