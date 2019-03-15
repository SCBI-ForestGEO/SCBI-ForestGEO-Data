# SCBI plot elevation data

## Locally measured elevation (scbi_elev)
The elevation file [scbi_elev.csv](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/spatial_data/elevation/scbi_elev.csv) is based on the elevation (in m) of several points throught the SCBI plot. 
Explanation for the sampling design is described in [Bourg et al. 2013](http://onlinelibrary.wiley.com/doi/10.1890/13-0010.1/full) and summarized here:

_In 2008 the LFDP was delineated in the forested portion of the Posey Creek watershed of
SCBI by choosing a starting center point and surveying the plot into 20 × 20 m quadrats, using a tripod-­mounted Laser
Technologies Impulse 200 LR laser rangefinder, high reflectance target, staff compass, and measuring tapes. The plot is
oriented to 350° on its north-­south axis and 80° on its east-­west axis. Each quadrat corner was marked with a 1.27 cm (0.5
inch) diameter iron rebar painted bright blue at the top. A numbered metal tag was attached with steel wire to each rebar. The
quadrat numbering system began with 01,01 in the southwest corner (origin) of the plot and continued at 20m intervals along
the x-­axis (east-­west direction) to 400 m (rebar 21,01). Numbering along the y-­axis (north-­south direction) was continued
similarly to 640 m (rebar 01,33)._

### scbi_elev metadata
|Column name | Description |
|---|---|
|rebar_id|Unique metal bar identified number located int he southwest corner of each 20x20 m quadrat|
|x|X coordinate based on full plot dimension|
|y|Y coordinate based on full plot dimension|
|elev|Elevation in meters |

## Additional files
[dem-sigeo]() = raster file with elevation of the SIGEO plot (and immediate surroundings). File is a USGS DEM originally obtained by Jonathan Thompson via reprojection in ArcGIS. To get elevation data for lon/lat coordinates of census stems in ArcGIS, use Geoprocessing Tools > Spatial Analyst > Extraction > Extract Multivalues to Points. An example of an output using the 2013 census data is below.

[contour_10m_SIGEO_coords](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/spatial_data/elevation/contour10m_SIGEO_coords.csv) = csv with UTM coordinates of contour polylines in 10m increments. This is a dataframe output of the contour_10m shapefile.

[full_stem_elevation_2013.csv](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/spatial_data/elevation/full_stem_elevation_2013.csv) = csv with full stem data from 2013 (scbi.stem2), but with elevation (m) for each stem. This was obtained from using the dem-sigeo raster in ArcGIS.




