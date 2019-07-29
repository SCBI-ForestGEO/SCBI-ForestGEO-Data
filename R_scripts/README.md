## Scripts for SCBI-ForestGEO-Data

Here we share various scripts built for different analysis of the SCBI tree data. 


|R file	|Description |
|---|---|
| [Calculate_ANPP.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/Calculate_ANPP.R)| To calculate ANPP, total and per species, for 1cm threshold and 10 cm threshold without growth rate outliers|
| [Calculate_Biomass.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/Calculate_Biomass.R)| To calculate Biomass, total and per species, for 1cm threshold and 10 cm threshold.|
| [calculate_distance_to_water.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/calculate_distance_to_water.R)| Calculates the distance from each tagged tree in ForestGEO plot to stream, based on the stream shapefile.|
| [create_shapefile_from_raster.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/create_shapefile_from_raster.R) | Gives code for creating a shapefile from drawing on a raster, specifically using the example of drawing a new stream shapefile from the topographic wetness index raster|
| [ForestGEO_plot_map.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/ForestGEO_plot_map.R) | Creates standard map of plot with grid, streams, roads, deer exclosure, and column/row numbers |
|	[neighborhood_basal_area.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/neighborhood_basal_area.R)| This script recreates the efforts done by Alan Tepley from [Gonzalez et al 2016](https://esajournals.onlinelibrary.wiley.com/doi/epdf/10.1002/ecs2.1595), whereby neighborhood basal area was calculated by summing the basal area of all trees within a given distance of a focal tree. Specifically, basal area for this paper was calculated to 30m at a distance increment of 0.5m. Initial calculations were done in Excel (see original output [here](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_dimensions/tree_crowns)). |
| [scbi_Allometries.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/scbi_Allometries.R)|To estimate AGB for all stems at SCBI| 
| [SIGEO_plot_grid_UTMcoord.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/SIGEO_plot_grid_UTMcoord.R) | Convert gx and gy coordinates from census to UTM_NAD83, lat/lon in decimal degrees, and quadrat-specific x/y |
| [SIGEO_plot_corners.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/SIGEO_plot_gridcorners.R) | Find plot corners from grid outline shapefile |
| [species_distribution_maps.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/species_distribution_maps.R) | Create plot-specific distribution maps of each species in ForestGEO plot |
| [topo_wet_index.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/topo_wet_index.R) | Calculate topographic wetness index for each tree in ForestGEO plot. Also creates DEM of plot and a TWI raster, which is used in create_shapefile_from_raster.R|
