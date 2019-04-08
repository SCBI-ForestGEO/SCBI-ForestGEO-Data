# Main census data

## rdata and csv files

Descriptions of these files can be found in [metadata](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_main_census/metadata) folder.

[tree_coord_local_plot.csv](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/tree_main_census/data/census-csv-files/tree_coord_local_plot.csv) is the full record of local and global coordinates for tagged trees. 

- local coordinates based on 20x20 m quadrats (qx = lx, qy=ly) 
- global or plot coordinates based on the full dimension of the SCBI plot 400x640 m (px = gx, py=gy)




# stem3 is a temporary file !
scbi.stem3_TEMPORARY.csv is a temporary file while waiting for CTFS-FOrestGEO to send back the final R.data files.
Most errors identified while collecting/entering/checking data the third census were corrected in this file. For a list of errors fixes, see @ValentineHerr and [her code in the Shenandoah project](https://github.com/EcoClimLab/Shenandoah/blob/master/scripts/3_Prepare_SCBI_full_and_mortality_census.R).
Note: the file is coming from SCBI0813[SCBI0813$Visit_Number %in% 3,], after running line 19 in [script 4](https://github.com/EcoClimLab/Shenandoah/blob/master/scripts/4_ANALYSIS_Changes_in_Biomass_Abundance_and_MeanDBH.R) of the shanandoah project.