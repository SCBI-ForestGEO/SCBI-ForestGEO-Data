###############################################
# Purpose: Create maps via 'ggplot2' that displays the distribution of each species throughout the SCBI plot
# Developed by: Alyssa Terrell - terrella3@si.edu | Modified by Ian McGregor
# R version 3.5.2 - First created April 2019
###############################################

library(RCurl) #1
library(rgdal) #3b
library(fgeo) #3b (sp is loaded), 5
library(broom) #3b for the tidy function
library(ggplot2) #3, 4
library(sf) #4 for mapping
library(ggthemes) #4 needed for plot theme
library(directlabels)


#1 Load in scbi.stem3
sigeo <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/tree_main_census/data/census-csv-files/scbi.stem3.csv"), stringsAsFactors = FALSE)


#2. Create function to make one map with multiple species based on criteria ####
species <- c("caco", "cato", "cagl", "caovl", "fram")
colsp <- c("red", "dark green", "orange", "yellow", "blue")

#the function inputs are
##df = sigeo
##dbh_filter = filter out all species with dbh < dbh_filter (number)
##species = one species or vector of species
##sp_colors = one color or vector of colors to be used for map
plot_sp_by_filter <- function(df, dbh_filter, species, sp_colors) {
  source("R_scripts/SIGEO_plot_grid_UTMcoord.R")
  plot_to_UTM(df)
  
  sigeo_sub <- sigeo_coords[sigeo_coords$sp %in% species, ]
  sigeo_sub$dbh <- as.numeric(sigeo_sub$dbh)
  sigeo_sub$dbh <- ifelse(is.na(sigeo_sub$dbh), 0, sigeo_sub$dbh)
  
  #assign filter
  sigeo_sub <- sigeo_sub[sigeo_sub$dbh > 0 & sigeo_sub$dbh < dbh_filter, ]
  sigeo_sub <- sigeo_sub[grepl("A", sigeo_sub$status), ]
  
  scbi_plot <- readOGR("spatial_data/shapefiles/20m_grid.shp")
  deer <- readOGR("spatial_data/shapefiles/deer_exclosure_2011.shp")
  roads <- readOGR("spatial_data/shapefiles/SCBI_roads_edits.shp")
  streams <- readOGR("spatial_data/shapefiles/streams_ForestGEO/streams_ForestGEO_full.shp")
  
  scbi_plot_df <- tidy(scbi_plot)
  deer_df <- tidy(deer)
  roads_df <- tidy(roads)
  streams_df <- tidy(streams)
  
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
  
  sp_map <- ggplot() +
    geom_point(data = sigeo_sub, aes(x = NAD83_X, y = NAD83_Y, color = sigeo_sub$sp)) +
    geom_path(data = scbi_plot_df, aes(x = long, y = lat, group = group)) +
    geom_path(data = roads_df, aes(x = long, y = lat, group = group), color = "brown",
              linetype = 2, size = 0.8) +
    geom_path(data = streams_df, aes(x = long, y = lat, group = group), color = "dark blue", size = 1) +
    geom_path(data = deer_df, aes(x = long, y = lat, group = group), size = .7) +
    ggtitle("Location in ForestGEO plot") +
    theme(axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank()) +
    coord_sf(crs = "crs = +proj=merc", xlim = c(747350, 747800), ylim = c(4308500, 4309125)) +
    theme(panel.grid.major = element_line(colour = 'transparent')) +
    theme(legend.position = "right") +
    scale_color_manual(breaks = species, values = sp_colors) +
    guides(color=guide_legend(title="Species"))
  
  sp_map <<- sp_map + 
    rows +
    cols 
  
  sigeo_sub <<- sigeo_sub
}

plot_sp_by_filter(sigeo, 100, species, colsp)

#save map and csv if want specific coordinates
ggsave(filename = paste0("spatial_data/maps/", "carya-fram_map", ".jpg"), plot = sp_map, height = 11, width = 8.5)

sigeo_sub <- sigeo_sub[, c(3:6,11,18:19)]
write.csv(sigeo_sub, "spatial_data/coordinates.csv", row.names=FALSE)

#3 Make map for each species' distribution in plot from for-loop ####
##3a. Convert gx/gy to lat/lon ####
source("R_scripts/SIGEO_plot_grid_UTMcoord.R")
plot_to_UTM(sigeo)
##3b. Load in shapefiles ####
scbi_plot <- readOGR("spatial_data/shapefiles/20m_grid.shp")
ForestGEO_grid_outline <- readOGR("spatial_data/shapefiles/ForestGEO_grid_outline.shp")
deer <- readOGR("spatial_data/shapefiles/deer_exclosure_2011.shp")
roads <- readOGR("spatial_data/shapefiles/SCBI_roads_edits.shp")
streams <- readOGR("spatial_data/shapefiles/streams_ForestGEO/streams_ForestGEO_full.shp")
# contour_10m <- readOGR("spatial_data/shapefiles/contour10m_SIGEO_clipped.shp") #taken care of by elevation labels in 2b

#Use this option if you want to visualize the plot WITH quadrat/grid lines
# scbi_plot_df <- tidy(scbi_plot)

#Use this option if you want to visualize the plot WITHOUT quadrat/grid lines
scbi_plot_df <- tidy(ForestGEO_grid_outline) 

###if tidy isn't working, can also do: xxx_df <- as(xxx, "data.frame")
deer_df <- tidy(deer)
roads_df <- tidy(roads)
streams_df <- tidy(streams)
# contour_10m_df <- tidy(contour_10m)


##3b. Get contour labels ####
##needed to add contour lines - online research says that function needed to do this is not upgraded to current R version yet
# library(directlabels)
# direct.label.ggplot(ggplot_test, method="bottom.pieces")

elevation_labels <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/master/spatial_data/elevation/contour10m_SIGEO_coords.csv"), stringsAsFactors = FALSE)

elevation_labels$label <- ifelse(elevation_labels$order == 1, elevation_labels$elev, NA)

##3c. Define axis labels to add to plot maps ####
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

##3d. Loop to create maps for all species ####
##prepare sigeo
sigeo_coords$DFstatus <- ifelse(grepl("dead", sigeo_coords$DFstatus), "dead", "alive")
sigeo_coords$dbh <- as.numeric(sigeo_coords$dbh)
sigeo_coords$dbh <- ifelse(is.na(sigeo_coords$dbh), 0, sigeo$dbh)

sigeo_coords$color <- ifelse(sigeo_coords$dbh == 0, "black",
                      ifelse(sigeo_coords$dbh >0 & sigeo_coords$dbh<=100, "dark green",
                      ifelse(sigeo_coords$dbh > 100 & sigeo_coords$dbh <= 350, "gold", "blue")))

##make maps
for(i in seq(along = unique(sigeo_coords$sp))){
  focus_sp <- unique(sigeo_coords$sp)[[i]]
  focus_sp_df <- sigeo[sigeo_coords$sp == focus_sp, ]
  focus_sp_alive <- focus_sp_df[focus_sp_df$DFstatus == "live", ]
  focus_sp_dead <- focus_sp_df[focus_sp_df$DFstatus == "dead", ]
  
  #ggplot code ####
  sp_map <- ggplot() +
    geom_point(data = focus_sp_alive, aes(x = NAD83_X, y = NAD83_Y), color = focus_sp_alive$color) +
    geom_point(data = focus_sp_dead, aes(x = NAD83_X, y = NAD83_Y), color = focus_sp_dead$color) +
    geom_path(data = scbi_plot_df, aes(x = long, y = lat, group = group)) +
    geom_path(data = roads_df, aes(x = long, y = lat, group = group), color = "brown",
              linetype = 2, size = 0.8) +
    geom_path(data = streams_df, aes(x = long, y = lat, group = group), color = "light blue", size = 1) +
    geom_path(data = deer_df, aes(x = long, y = lat, group = group), size = .7) +
    geom_path(data = elevation_labels, aes(x = x, y = y, group = group), color = "grey", linetype = 1) +
    geom_text(data = elevation_labels, aes(x = x, y = y, label = label), angle=-70, nudge_x = 8, nudge_y = -15, size = 3) +
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
    
    #the dimensions of the outputs need to be played with
    ggsave(filename = paste0("D:/Dropbox (Smithsonian)/Github_Ian/SCBI-Plot-Book/maps_figures_tables/ch_3_distribution_maps/", focus_sp, ".jpg"), plot = ggplot_test, device = "jpeg")
}


#4. Create map with fgeo package ####
##this package easily creates faceted maps of all species distributions in our plot (as seen below). However, this doesn't allow for manually changing the colors of the points based on DBH, nor does it include the stream and road lines.

## for further reference, see source: https://github.com/forestgeo/fgeo.plot

#note, read_vft specifically is regarding the "ViewFullTable" file
test <- read_vft(file = (getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/master/census%20data/ViewFullTable_crc_master.csv?token=AJNRBEKU5NOO5E7BOP73SHS5DYGNI")))

setnames(test, old=c("PX", "PY", "Mnemonic"), new=c("gx", "gy", "sp"))

elevation <- scbi_elev

test1 <- test %>%
  filter(CensusID == 3) %>%
  filter(sp %in% c("libe"))

autoplot(sp_elev(test1, elevation))
