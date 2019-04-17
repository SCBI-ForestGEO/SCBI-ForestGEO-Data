######################################################
# Purpose: Calculate distance to water (in m) in ForestGEO plot
# Developed by: Ian McGregor - mcgregori@si.edu
# R version 3.5.2 - First created April 2019
######################################################

## the ggplot map was originally done in the survey_maps.R script used for dendrobands.
library(RCurl)
library(ggplot2)
library(rgdal)
library(broom) #for the tidy function
library(sf) #for mapping
library(ggthemes) #for removing graticules when making pdf
library(rgeos) #for distance calculation

## as an example, let's use dendroband trees, subsetted for live trees
dendro_trees <- read.csv(text=getURL("https://raw.githubusercontent.com/SCBI-ForestGEO/Dendrobands/master/data/dendro_trees.csv?token=AlsQkR8jmWNmQ60dsbaZnSSRaXFqhQTnks5cui-qwA%3D%3D"))
dendro_trees <- dendro_trees[is.na(dendro_trees$mortality.year), ]
dendro_trees <- dendro_trees[!is.na(dendro_trees$NAD83_X), ] #you MUST have complete data
dendro_sub <- dendro_trees[, c(1:6,8:9,23:24)]

# upload shapefiles
scbi_plot <- readOGR("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/spatial_data/shapefiles/20m_grid.shp")
deer <- readOGR("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/spatial_data/shapefiles/deer_exclosure_2011.shp")
roads <- readOGR("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/spatial_data/shapefiles/SCBI_roads_edits.shp")
streams <- readOGR("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/SCBI-ForestGEO-Data/spatial_data/shapefiles/SCBI_streams_edits.shp")
NS_divide <- readOGR("C:/Users/mcgregori/Dropbox (Smithsonian)/Github_Ian/Dendrobands/resources/maps/shapefiles/NS_divide1.shp")

#convert all shp to dataframe so that it can be used by ggplot
#if tidy isn't working, can also do: xxx_df <- as(xxx, "data.frame")
scbi_plot_df <- tidy(scbi_plot)
deer_df <- tidy(deer)
roads_df <- tidy(roads)
streams_df <- tidy(streams)
NS_divide_df <- tidy(NS_divide)

#x and y give the x/yposition on the plot; sprintf says to add 0 for single digits, the x/y=seq(...,length.out) says fit the label within these parameters, fitting the length of the label evenly.
##this code adds the row and column numbers based on coordinates
rows <- annotate("text", x = seq(747350, 747365, length.out = 32), y = seq(4309125, 4308505, length.out = 32), label = sprintf("%02d", 32:1) , size=5.25, color="black")

cols <- annotate("text", x = seq(747390, 747765, length.out = 20), y = seq(4308495, 4308505, length.out = 20), label = sprintf("%02d", 1:20), size=5.4, color="black")

#base map to use for the distance calculation
map <- ggplot() +
  geom_path(data = scbi_plot_df, aes(x = long, y = lat, group = group))+
  geom_path(data=roads_df, aes(x=long, y=lat, group=group), 
            color="#996600", linetype=2)+
  geom_path(data=streams_df, aes(x=long, y=lat, group=group), color="blue")+
  geom_path(data=deer_df, aes(x=long, y=lat, group=group), size=1.1)+
  geom_point(data=dendro_trees, aes(x=NAD83_X, y=NAD83_Y), shape=19)+
  geom_text(data=dendro_trees, aes(x=NAD83_X, y=NAD83_Y, label=tag), 
            size=3, hjust=1.25, nudge_y=-1, nudge_x=1, check_overlap=TRUE)+
  labs(title="ForestGEO Plot")+
  theme(plot.title=element_text(vjust=0.1))+
  coord_sf(crs = "crs = +proj=merc", xlim=c(747350,747800), ylim=c(4308500, 4309125))+
  rows +
  cols

## calculating the distance requires some conversion. First, the points of the trees from must be in their own dataframe before they can be converted to a SpatialPoints object.
## in this example we're staying with UTM lon/lat that's used in the full map projection
## probably this can also be done using dd but just double check the projection
dendro_trees_map <- dendro_trees[, c(23:24)]
dendro_points <- SpatialPoints(dendro_trees_map, proj4string = CRS(as.character("+proj=merc")))

## here, the minimum distance to water is calculated before binding back to dendro_sub from above.
## A warning says that dendro_points and streams are projected differently, but the output has been verified to be accurate.
distance_water <- data.frame(apply(gDistance(dendro_points, streams, byid=TRUE), 2, min))
colnames(distance_water) <- "dist"
distance <- cbind(dendro_sub, distance_water)


## to double check the accuracy of the calculation, make a subset of all trees close to the stream (e.g. at most 30m away) and map them.
distance_short <- distance[distance$dist <= 30, ]

map <- ggplot() +
  geom_path(data = scbi_plot_df, aes(x = long, y = lat, group = group))+
  geom_path(data=roads_df, aes(x=long, y=lat, group=group), 
            color="#996600", linetype=2)+
  geom_path(data=streams_df, aes(x=long, y=lat, group=group), color="blue")+
  geom_path(data=deer_df, aes(x=long, y=lat, group=group), size=1.1)+
  geom_point(data=distance_short, aes(x=NAD83_X, y=NAD83_Y), shape=19)+
  geom_text(data=distance_short, aes(x=NAD83_X, y=NAD83_Y, label=tag), 
            size=3, hjust=1.25, nudge_y=-1, nudge_x=1, check_overlap=TRUE)+
  theme(plot.title=element_text(vjust=0.1))+
  coord_sf(crs = "crs = +proj=merc", xlim=c(747350,747800), ylim=c(4308500, 4309125))+
  rows+
  cols
