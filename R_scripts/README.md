## Scripts for SCBI-ForestGEO-Data

Here we share various scripts built for different analysis of the SCBI tree data. 


|R file	|Description |
|---|---|
|	[neighborhood_basal_area.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/neighborhood_basal_area.R)| This script recreates the efforts done by Alan Tepley from [Gonzalez et al 2016](https://esajournals.onlinelibrary.wiley.com/doi/epdf/10.1002/ecs2.1595), whereby neighborhood basal area was calculated by summing the basal area of all trees within a given distance of a focal tree. Specifically, basal area for this paper was calculated to 30m at a distance increment of 0.5m. Initial calculations were done in Excel (see original output [here](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_dimensions/tree_crowns)). |
| [Calculate_ANPP.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/Calculate_ANPP.R)| To calculate ANPP, total and per species, for 1cm threshold and 10 cm threshold without growth rate outliers|
| [Calculate_Biomass.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/Calculate_Biomass.R)| To calculate Biomass, total and per species, for 1cm threshold and 10 cm threshold.|
| [scbi_Allometries.R](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/scbi_Allometries.R)|To estimate AGB for all stems at SCBI| 


# stem3 is a temporary file !
scbi.stem3_TEMPORARY.csv is a temporary file while waiting for CTFS-FOrestGEO to send back the final R.data files.
Most errors identified while collecting/entering/checking data the third census were corrected in this file. For a list of errors fixes, see @ValentineHerr and [her code in the Shenandoah project](https://github.com/EcoClimLab/Shenandoah/blob/master/scripts/3_Prepare_SCBI_full_and_mortality_census.R).
Note: the file is coming from SCBI0813[SCBI0813$Visit_Number %in% 3,], after running line 19 in [script 4](https://github.com/EcoClimLab/Shenandoah/blob/master/scripts/4_ANALYSIS_Changes_in_Biomass_Abundance_and_MeanDBH.R) of the shanandoah project.