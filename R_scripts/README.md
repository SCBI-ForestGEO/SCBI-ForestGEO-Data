## Scripts for SCBI-ForestGEO-Data

Here we share various scripts built for different analysis of the SCBI tree data. 


|R file	|Description |
|---|---|
|	[neighborhood_basal_area.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/neighborhood_basal_area.R)| This script recreates the efforts done by Alan Tepley from [Gonzalez et al 2016](https://esajournals.onlinelibrary.wiley.com/doi/epdf/10.1002/ecs2.1595), whereby neighborhood basal area was calculated by summing the basal area of all trees within a given distance of a focal tree. Specifically, basal area for this paper was calculated to 30m at a distance increment of 0.5m. Initial calculations were done in Excel (see original output [here](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_dimensions/tree_crowns)). |
| [Calculate_ANPP.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/Calculate_ANPP.R)| To calculate ANPP, total and per species, for 1cm threshold and 10 cm threshold without growth rate outliers|
| [Calculate_Biomass.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/Calculate_Biomass.R)| To calculate Biomass, total and per species, for 1cm threshold and 10 cm threshold.|
| [scbi_Allometries.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/scbi_Allometries.R)|To estimate AGB for all stems at SCBI| 
