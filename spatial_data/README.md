# SCBI spatial data

This folder contains [shapefiles](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/spatial_data/shapefiles) and [elevation data](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/spatial_data/elevation) to create topographic maps for the SCBI plot. 

## Elevation (m)
The file [scbi_elev](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/spatial_data/elevation/scbi_elev.csv) can be used to plot species distribution using [fgeo.plot](https://github.com/forestgeo/fgeo.plot), for example.

## Shapefiles description

|File| Description|
|--|--|
|20m_grid|grid of the ForestGEO plot in 20m^2 quadrats, 400m x 640m total|
|ForestGEO_grid_outline|perimeter of the ForestGEO plot|
|SCBI_roads_clipped_to_plot| the dirt road running through the ForestGEO plot. This shapefile is clipped from a larger shapefile showing all roads in SCBI (SCBI_roads_edits)|
|SCBI_roads_edits| all roads in SCBI|
|SCBI_streams_clipped_to_plot|the streams going through the ForestGEO plot. This shapefile clipped from a larger shapefile showing all streams in SCBI (SCBI_streams_edits)|
|SCBI_streams_edits|all streams in SCBI|
|streams_ForestGEO|more accurate shapefiles for plot, drawn from topographic wetness index raster. There are 3 separate shapefiles ("left", "top", "mid") for easy editing if need be, with the "full" shapefile for the combined. More detailed info can be found in the associated [script](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/create_shapefile_from_raster.R)|
|Virginia|outline of the state of Virginia|
|cb_2017_us_state_5m|outline of all US states|
|contour10m_SIGEO_clipped|contour lines within the ForestGEO plot|
|deer_exclosure_2011|outline of the deer exclosure in the ForestGEO plot|
|full_stem_elevation_2013|elevation data for all stems from the 2013 census. This shapefile was created by reading in xy data from the UTM coordinates [here](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/spatial_data/UTM%20coordinates/scbi_stem_utm_lat_lon_2013.csv) and then extracting elevation values from [dem-sigeo](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/spatial_data/elevation/dem-sigeo) in ArcGIS
|sigeo_5m_dem|original dem files for sigeo plot, different from "dem-sigeo"
