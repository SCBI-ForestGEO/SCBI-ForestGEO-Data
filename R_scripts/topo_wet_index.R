######################################################
# Purpose: Get topographical wetness index (TWI) for SCBI ForestGEO plot
# Sub-purpose: Create plot DEM, create raster of stream areas, see 3D rendering of plot
# Developed by: Ian McGregor - mcgregori@si.edu &
#               Valentine Herrmann - herrmannv@si.edu
# R version 3.5.3 - First created July 2019
######################################################
library(rgdal) #A
library(raster) #A,B
library(elevatr) #A
#https://cran.r-project.org/web/packages/elevatr/vignettes/introduction_to_elevatr.html
library(dynatopmodel) #A
#https://cran.r-project.org/web/packages/dynatopmodel/dynatopmodel.pdf
library(rasterVis) #B

#A: Create rasters ####
#1 Define an empty raster to match plot dimensions
# grid <- readOGR(dsn = "spatial_data/shapefiles", layer = "ForestGEO_grid_outline")

ext <- extent(747370.6, 747785.8, 4308505.5, 4309154.8) #these come from the grid shapefile and represent the tilted plot
xy <- abs(apply(as.matrix(bbox(ext)), 1, diff))
n <- 5
r <- raster(ext, ncol=xy[1]*n, nrow=xy[2]*n)
proj4string(r) <- CRS("+proj=utm +zone=17 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")

# ext <- extent(747375, 747785, 4308510, 4309155) #these are for a vertical representation of the plot

#2 Get elevation raster from online
q <- get_elev_raster(r, z=14)


#3 Crop online raster to the dimensions of the empty raster, set resolution to 5m
r <- raster(ext, res = 5)
q <- resample(q, r)
res(q)
proj4string(q) <- CRS("+proj=utm +zone=17 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0") #q lost its crs in the resample function
plot(q)


#4 Get hydrological features of landscape (upslope area and topographical wetness index)
##graphing parameters comes from help text from build_layers
layers <- build_layers(q)
sp::plot(layers, main=c("Elevation AMSL (m)", "Upslope area (log(m^2/m))", "TWI ((log(m^2/m))"))


#5 Add map of plot quadrats with 20m resolution
r <- raster(ext, res = 20)
layers@layers[[4]] <- resample(layers@layers[[3]], r)
sp::plot(layers, main=c("Elevation masl", "Upslope area (log(m^2/m))", "TWI ((log(m^2/m))", "TWI per quadrat"))


#6 write TWI plot map to file
titles <- c("Elevation masl", "Upslope area (log(m^2/m))", "TWI ((log(m^2/m))", "TWI per quadrat")
files <- c("plot_elevation", "plot_upslope", "plot_TWI", "plot_TWI_quadrat")

##this writes to a GeoTIFF file that is perfectly read into ArcGIS. However, these files are not viewable in standard image viewers.
# for(i in seq(along=1:4)){
#   writeRaster(layers[[i]], paste0("spatial_data/elevation/rasters/", files[i], ".tif"), format="GTiff", overwrite=TRUE)
# }

##write to png for viewable images
# for(i in seq(along=1:4)){
#   png(paste0("spatial_data/elevation/rasters/", files[i], ".png")) 
#   sp::plot(layers[[i]], main=titles[i]) 
#   dev.off()
# }


#7 overlay with plot
grid <- readOGR(dsn = "spatial_data/shapefiles", layer = "20m_grid")

w <- mask(layers[[3]], grid) #clips raster to grid polygon
plot(w)
plot(grid, add=TRUE)
points(trees$NAD83_X, trees$NAD83_Y)


#8 extract TWI value for specific trees
trees <- read.csv("D:/Dropbox (Smithsonian)/Github_Ian/McGregor_climate-sensitivity-variation/data/core_list_for_neil.csv")
trees <- trees[, c(1,23:24)]
trees1 <- trees[, c(2:3)]

twi_values <- extract(layers[[3]], trees1, method="simple")

trees$TWI <- twi_values

###################################################################################
#B: 3D rendering of plot #####
##the plot can easily be rendered as a semi-interactive 3D image as long as you have a raster
elev <- raster("spatial_data/elevation/rasters/plot_elevation.tif")
plot_TWI <- raster("spatial_data/elevation/rasters/plot_TWI.tif")

plot3D(elev) #DEM
plot3D(plot_TWI) #not a DEM but can be used as another way to visualize where the streams are

########################################################################################
#for the record, here is the angle at which the plot is rotated compared to vertical
## NAD83 coordinates of the SW and NW corners of the SIGEO plot
NAD83.SW <- c(747385.521, 4308506.438)                     
NAD83.NW <- c(747370.676, 4309146.156)

## Angle (in radians) at which the plot's western boundary is offset from true NAD83 line of latitude
Offset <- atan2(NAD83.NW[1] - NAD83.SW[1], NAD83.NW[2] - NAD83.SW[2])
