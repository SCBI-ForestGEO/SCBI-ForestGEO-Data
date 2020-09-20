#  Smithsonian Conservation Biology Institute (SCBI) ForestGEO Data

[![DOI](https://zenodo.org/badge/128393291.svg)](https://zenodo.org/badge/latestdoi/128393291)

This is the public data portal for the [SCBI ForestGEO plot](https://forestgeo.si.edu/sites/north-america/smithsonian-conservation-biology-institute), which points to archive locations for our various data products (some in this repository, many elsewhere). Although some data products are not yet posted publicly, we are very open to collaboration and welcome inquiries regarding any data products listed here. 


## Available data products

### Location & Maps
- Geographic Coordinates: 38°53'36.6" N, 78°08'43.4" W
- [UTM Coordinates of SCBI plot corners](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/spatial_data/UTM%20coordinates)
- [Spatial data including multiple GIS files](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/spatial_data) 

### Biophysical environment
- **Climate data** - available through [ForestGEO Climate Data Portal](https://github.com/forestgeo/Climate/tree/master/Climate_Data/Met_Stations/SCBI)

- **Topograpy** - [This folder](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/spatial_data) contains shapefiles and elevation data to create topographic maps for the SCBI plot. Elevation ranges from 273-338 m.a.s.l.. 

- **Disturbance history** - [This file](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/plot%20disturbances/SCBI_plot_disturbance_events.csv) is a log of known disturbance events that have affected this forest. This does not currently include the land use history, which is described in [Bourg et al. 2013](http://onlinelibrary.wiley.com/doi/10.1890/13-0010.1/full), or a full record of pests and pathogens, available [here](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/species_lists/insects_pathogens/insects_pathogens.csv).

### Species lists
- **[Tree ecology](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/species_lists/Tree%20ecology)**

- **[Full plant list](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/species_lists/Full%20plant%20list)**

- **[Insect pests and pathogens](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/species_lists/insects_pathogens)**

### Tree censuses
- **Main ForestGEO census data** - Three (3) full censuses following ForestGEO protocol of our 25.6ha plot have been conducted in 2008, 2013, and 2018. Data are available upon request through [ForestGEO Data Portal](http://ctfs.si.edu/datarequest/). Copies are also posted [here](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_main_census), but the master version resides on the ForestGEO Data Portal, and anyone wishing to use the data should obtain from there. 

- **[Tree mortality (annual)](https://github.com/EcoClimLab/SCBI-ForestGEO-Data/tree/master/tree_mortality)**


### Tree dimensions (and size-scaling thereof)

- **Biomass** 
    - Expert-selected biomass allometries - [Gonzalez-Akre et al. 2016](https://esajournals.onlinelibrary.wiley.com/doi/abs/10.1002/ecs2.1595).
    - Terrestrial LiDAR-derived non-destructive woody biomass - [Stovall et al. 2018, *Data in Brief*](https://www.sciencedirect.com/science/article/pii/S2352340918306978) accompanying [Stovall et al. 2018, *Forest Ecology and Management*](https://www.sciencedirect.com/science/article/pii/S2352340918306978). The former contains data, latter describes allometries. 
    - Biomass allometries for this site will be curated as part of [ForestGEO's allodb](https://github.com/forestgeo/allodb).

- **Tree heights** 
    - [Compilation of all conventional height measurements](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_dimensions/tree_heights)
    - Terrestrial LiDAR-derived heights - [Stovall et al. 2018, *Data in Brief*](https://www.sciencedirect.com/science/article/pii/S2352340918306978) accompanying [Stovall et al. 2018, *Forest Ecology and Management*](https://www.sciencedirect.com/science/article/pii/S0378112718304663). The former contains data, latter describes allometries. 
    - Height allometries for this site will be curated as part of [ForestGEO's allodb](https://github.com/forestgeo/allodb).

- **Crown positions** 
    - Crown position of trees that die is recorded as part of our [annual tree mortality census](https://github.com/EcoClimLab/SCBI-ForestGEO-Data/tree/master/annual_mortality_census).
    - New data (as 2018) on SCBI [crown position](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/tree_dimensions/tree_crowns).
    
- **Crown dimensions** 
    - [Dryad data publication](https://datadryad.org//resource/doi:10.5061/dryad.6nc8c?show=full) accompanying [Anderson-Teixeira *et al.* 2015, *Functional Ecology*](https://besjournals.onlinelibrary.wiley.com/doi/abs/10.1111/1365-2435.12470). The former contains data, latter describes allometries. 

- **Sapwood depth** 
    - [Raw measurement files](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_dimensions/sapwood).
    - [Anderson-Teixeira *et al.* 2015, *Functional Ecology*](https://besjournals.onlinelibrary.wiley.com/doi/abs/10.1111/1365-2435.12470) describes allometries based on these data.

- **Bark thickness** 
    - [Dryad data publication](https://datadryad.org//resource/doi:10.5061/dryad.6nc8c?show=full) accompanying [Anderson-Teixeira *et al.* 2015, *Functional Ecology*](https://besjournals.onlinelibrary.wiley.com/doi/abs/10.1111/1365-2435.12470). The former contains data, latter describes allometries. 
 
### Tree species traits 
- **Leaf traits data (SLA) for 56 woody species** - Archived [here](https://github.com/EcoClimLab/SCBI-ForestGEO-Data/tree/master/leaf%20traits) and contributed to [TRY Plant Trait Database](https://www.try-db.org/TryWeb/Home.php)

- **Leaf hydraulic traits** - Contact us for details. 
    
### Tree growth & physiology
- [**Tree cores**](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_cores) - We have ring width measurements for 703 cores from live trees (taken between June 2010 and March 2011; some published in [Bourg et al. 2013](http://onlinelibrary.wiley.com/doi/10.1890/13-0010.1/full)) and 516 cores from trees found dead in the 2016 or 2017 mortality census, and we have finished chronologies for 14 species.

- **Manual dendrometer bands** - Biannual and intra-annual measurements of dendrometer bands (n= ~550 and 150 trees, respectively) have been taken every year since 2010 and 2011, respectively. Details and data are in [this repository](https://github.com/SCBI-ForestGEO/Dendrobands). Contact us for access. 

- **Automated dendrometer bands** - Some of the data are publisehd in the [Dryad data publication](http://dx.doi.org/10.5061/dryad.b327c) accompanying [Herrmann *et al.* 2016, *PLOSONE*](https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0169020). Contact us for complete data. 

- **Sap flow** 
    - [Dryad data publication](https://datadryad.org//resource/doi:10.5061/dryad.6nc8c?show=full) accompanying [Anderson-Teixeira *et al.* 2015, *Functional Ecology*](https://besjournals.onlinelibrary.wiley.com/doi/abs/10.1111/1365-2435.12470).
    - Contributed to [SAPFLUXNET](http://sapfluxnet.creaf.cat/app).
    - Contact us for complete data.

- **Leaf phenology** 
    - We have some [leaf phenology observations](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/leaf%20phenology) at SCBI.


### Carbon cycling

- **Biomass** - Summaries of biomass by species are given [here](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/summary_data).

- **Woody productivity** - Summaries of woody productivity by species are given [here](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/summary_data).

- **Woody mortality** - Woody mortality has been/ can be calculated from our [tree mortality census data](https://github.com/EcoClimLab/SCBI-ForestGEO-Data/tree/master/tree_mortality).

- **Dead wood** - Contact us for details.

- **Soils** - Contact us for details.


### Tree reproduction 

- **Seed rain** - Seed rain data (from fruits and seeds) were collected from litterfall traps on a biweekly or monthly basis from 2009–2011. Methods and dataset are published in [Bourg et al. 2013](http://onlinelibrary.wiley.com/doi/10.1890/13-0010.1/full)

- **Seedlings** - At SCBI, we have been recording seedling survival since 2010. Seedling data from 2010-2012 and methods has been published in [Bourg et al. 2013](http://onlinelibrary.wiley.com/doi/10.1890/13-0010.1/full). Also, [McGarvey et al 2013](http://ctfs.si.edu/Public/pdfs/McGarveyEtAl.NENat2013.pdf) used these data to study the effects of deer chronic browsing in Eastern forest. Data since 2013 is avialable upon request. Contact us for details.

### Invasive species

- **Invasive plants survey**- Contact us for details.


### Arthropods
- **Malaise trap** - We have been running a [Global Malaise Trap Program](http://biodiversitygenomics.net/projects/gmp/)  since 2014, and have DNA barcode sequences in the [BOLD database](boldsystems.org) for the first year (almost 14,000 sequences).  Analysis is ongoing, but data are available on request.


## Additional resources


**NOTE: SCBI is a [NEON](https://www.neonscience.org/) site.** For a list of NEON data products (not included in the list below), please visit the [NEON data portal](http://data.neonscience.org/browse-data?showAllDates=true&siteCode=SCBI&dpCode=DP1.10066.001&dpCode=DP1.10023.001&dpCode=DP1.30006.001&dpCode=DP2.30020.001&dpCode=DP1.10058.001&dpCode=DP1.10031.001&dpCode=DP1.00096.001&dpCode=DP1.00002.001&dpCode=DP1.10014.001&dpCode=DP1.00001.001&dpCode=DP3.30019.001&dpCode=DP2.30011.001&dpCode=DP1.10092.001&dpCode=DP1.00097.001&dpCode=DP3.30026.001&dpCode=DP1.00003.001&dpCode=DP3.30010.001&dpCode=DP1.10033.001&dpCode=DP1.00098.001&dpCode=DP2.30012.001&dpCode=DP1.10104.001&dpCode=DP1.10076.001&dpCode=DP3.30018.001&dpCode=DP1.10093.001&dpCode=DP1.10067.001&dpCode=DP1.10101.001&dpCode=DP1.10017.001&dpCode=DP1.30003.001&dpCode=DP1.00042.001&dpCode=DP3.30024.001&dpCode=DP4.00001.001&dpCode=DP1.10020.001&dpCode=DP1.10047.001&dpCode=DP3.30011.001&dpCode=DP1.00043.001&dpCode=DP1.10003.001&dpCode=DP2.30026.001&dpCode=DP1.10064.001&dpCode=DP1.10078.001&dpCode=DP1.10102.001&dpCode=DP3.30012.001&dpCode=DP1.10022.001&dpCode=DP1.00014.001&dpCode=DP3.30025.001&dpCode=DP2.30014.001&dpCode=DP3.30022.001&dpCode=DP1.00066.001&dpCode=DP1.30001.001&dpCode=DP1.00040.001&dpCode=DP1.10109.001&dpCode=DP1.00006.001&dpCode=DP1.10010.001&dpCode=DP1.00023.001&dpCode=DP1.10053.001&dpCode=DP3.30006.001&dpCode=DP1.10100.001&dpCode=DP1.00041.001&dpCode=DP3.30014.001&dpCode=DP1.10108.001&dpCode=DP2.30016.001&dpCode=DP1.10080.001&dpCode=DP1.00033.001&dpCode=DP1.00024.001&dpCode=DP1.30010.001&dpCode=DP1.00004.001&dpCode=DP2.30022.001&dpCode=DP3.30016.001&dpCode=DP2.30019.001&dpCode=DP1.10098.001&dpCode=DP1.10072.001&dpCode=DP1.00094.001&dpCode=DP1.10038.001&dpCode=DP1.10055.001&dpCode=DP1.10107.001&dpCode=DP1.00022.001&dpCode=DP1.10043.001&dpCode=DP3.30015.001&dpCode=DP1.00005.001&dpCode=DP1.10086.001&dpCode=DP1.00095.001&dpCode=DP1.10008.001&dpCode=DP1.10026.001&dpCode=DP3.30020.001&dpCode=DP1.10099.001&dpCode=DP2.30018.001&dpCode=DP1.30008.001).
- [*Digital Atlas of the Flora of Virginia*](http://www.vaplantatlas.org/)

## Contact
Kristina Anderson-Teixeira (teixeirak@si.edu) or Erika Gonzalez-Akre (gonzalezeb@si.edu)
