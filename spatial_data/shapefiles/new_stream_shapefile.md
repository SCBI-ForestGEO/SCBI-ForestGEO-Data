# Need to update stream shapefile (by @mcgregorian1)

**Context**: the scbi streams shapefile [found here](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/spatial_data/shapefiles) is old and a little inaccurate. It should be remade.

**Task**: There are two main ways this can be done
1. Get data points in field.
    - Go out with a Garmin and take GPS points for all the streams. 
    - Then import points to ArcGIS, make a polyline shapefile, and export.

2. Extract stream areas from raster.
    - This uses the [topo_wet_index](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/R_scripts) script, which creates a raster of the predicted stream areas based on topography, either the "upslope area" or the "TWI" output. These are pretty accurate to where the actual stream locations are. The rasters are also saved [here](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/spatial_data/elevation/rasters).
    - To make this work, you need to extract the stream areas of the raster by defining a threshold of values, which is not difficult. What will take some time, however, is the manual input required: while the top left and middle right stream areas of the raster have similar color hues, the latter is the only one that has continuous water through the year.
