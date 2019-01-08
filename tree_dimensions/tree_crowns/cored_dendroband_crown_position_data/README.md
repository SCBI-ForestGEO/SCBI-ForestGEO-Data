# dendro_cored_full

This file should be updated following each growing season, using the most recent version of dendro_trees and the mortality census.

## Date of Last Update

for crown assessments: Dec. 2018

for geographic coordinates: Oct. 2018

AJ project: live cored (466), live biannual (477), and both live/cored (46) = 989 trees for analysis

raw_data_AJ_crown_surveys.csv contains the data as input by AJ after field surveys. This version is being kept as an archive.

## This file includes the following information:

- species of trees present in the dendroband surveys (579 trees, includes live and dead)

- which of those trees are for the biannual survey, intraannual survey, or both

- all cored trees (2010-2011, 2016-2017) included in Ryan's analysis (see below) (726 trees, live and dead)

- crown positions and conditions for all alive trees, gathered in fall 2018 as part of AJ Seglem (SMSC student) project (Protocol for determining crown position is based on [Jennings 1999](https://academic.oup.com/forestry/article/72/1/59/589132) pages 69-70.)

- the local and global coordinates of all trees

- the UTM and lat/lon of each tree. These were obtained by merging this file with "scbi_stem_utm_lat_long.csv" found in V:\SIGEO\GIS_data\R-script_Convert local-global coord.

    a. For anyone trying to replicate this merge and using stem data from the 2013 ForestGEO survey, be aware that two trees (30365 [quad 308] and 131352 [quad 1316]) are not present in the 2013 census data due to mislabeling. This was caught in the 2018 census, and only appear in 2018 data going forward.

- the accompanying Rscript for creating this file is located above. Files used to create this include
    1. [census_data_for_cored_trees](https://github.com/EcoClimLab/climate_sensitivity_cores/blob/master/data/census_data_for_cored_trees.csv) - this contains only the cores used in Ryan's analysis (in [current_chronologies](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/tree/master/tree_cores/chronologies/current_chronologies)). It is a subset of the cores that appear in [measurement notes](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/tree/master/tree_cores/chronologies) and [all_core_chronologies](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/tree/master/tree_cores/all_cross-dated_data).
    
    2. [dendro_trees](https://github.com/SCBI-ForestGEO/Dendrobands/blob/master/data/dendro_trees.csv)
    
    3. Merged_dendroband_utm_lat_lon.csv from V drive: V:/SIGEO/GIS_data/dendroband surveys. This itself was created from Valentine's full coordinate csv for the plot, found in V drive: V:\SIGEO\GIS_data\R-script_Convert local-global coord.
    
    4. scbi.stem2.csv (2013 census data) from the V drive: V:/SIGEO/3-RECENSUS 2013/DATA/FINAL DATA to use, to share
    *- this should be updated to the 2018 census data as soon as the final file is available*
    
    5. [Mortality_Survey_2018](https://github.com/EcoClimLab/SCBI-ForestGEO-Data_private/blob/master/SCBI_mortality/raw%20data/Mortality_Survey_2018.csv)
    
    6. Crown assessments ("illum", "crown.condition", and "crown.position") were collected 8-19 Nov. by AJ Seglem (SMSC). Protocols for these are in the metadata.
