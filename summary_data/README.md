# ANPP calculations

ANPP calculations were made in [this script](https://github.com/EcoClimLab/SCBI-ForestGEO-Data_private/blob/master/R_scripts/Calculate_ANPP.R).

## Units
ANPP is in Mg C ha1- y-1.


## Aboveground biomass alometries (AGB)
We used aboveground biomass allometries compiled for SCBI (found in [this script] (https://github.com/EcoClimLab/SCBI-ForestGEO-Data_private/blob/master/R_scripts/scbi_Allometries.R).0
 
## Growth outliers
To identify and deal with outliers, surviving trees were grouped into size bins 1-5cm, 5-10cm, 10-50cm, and >50cm and the yearly change in AGB
of trees that had a growth rate more than 4 std outside the mean for their size bin were replaced with the mean yearly change in AGB of their siz bin.

