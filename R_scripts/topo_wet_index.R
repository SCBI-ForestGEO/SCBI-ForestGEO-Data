######################################################
# Purpose: Get topographical wetness index (TWI) for each quadrat in SCBI ForestGEO plot
# Developed by: Ian McGregor - mcgregori@si.edu &
#               Valentine Herrmann - herrmannv@si.edu
# R version 3.5.3 - First created July 2019
######################################################
library(rgdal)
library(raster)
library(elevatr) 
#https://cran.r-project.org/web/packages/elevatr/vignettes/introduction_to_elevatr.html
library(dynatopmodel)
#https://cran.r-project.org/web/packages/dynatopmodel/dynatopmodel.pdf

#1 Define an empty raster to match plot dimensions

# scbi_plot <- readOGR(dsn = "spatial_data/shapefiles", layer = "ForestGEO_grid_outline")
# ext <- extent(scbi_plot)

##If these x and y min/max aren't working or dimensions need to be more exact, use the extent from the shapefile above
ext <-  extent(747375, 747783, 4308510, 4309155)
xy <- abs(apply(as.matrix(bbox(ext)), 1, diff))
n <- 5
r <- raster(ext, ncol=xy[1]*n, nrow=xy[2]*n)
proj4string(r) <- CRS("+proj=utm +zone=17 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")

#2 Get elevation raster from online
q <- get_elev_raster(r, z=14)

#3 Crop online raster to the dimensions of the empty raster, match resolutions
r <- raster(ext, res = 5)
q <- resample(q, r)
res(q)
plot(q)

#4 Get hydrological features of landscape (upslope area and topographical wetness index)
##graphing parameters comes from help text from build_layers
layers <- build_layers(q)
sp::plot(layers, main=c("Elevation AMSL (m)", "Upslope area (log(m^2/m))", "TWI ((log(m^2/m))"))

#5 Redefine resolution to match 20m quadrats of plot
r <- raster(ext, res = 20)
layers@layers[[4]] <- resample(layers@layers[[3]], r)

sp::plot(layers, main=c("Elevation AMSL (m)", "Upslope area (log(m^2/m))", "TWI ((log(m^2/m))", "TWI per quadrat"))

#6 write TWI plot map to raster image file
writeRaster(layers@layers[[4]], )
            