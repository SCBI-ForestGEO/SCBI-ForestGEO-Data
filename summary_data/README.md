# SCBI ForestGEO plot data summaries

## Aboveground biomass (AGB)
AGB calculations (whole plot and by species) were made in [this script](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/Calculate_Biomass.R).

### Units
Mg C ha-1 (using 0.47 conversion factor for biomass -> C)

### Time period
2008, 2013

### biomass allometries 
We used aboveground biomass allometries compiled for SCBI (found in [this script](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/scbi_Allometries.R).

## Woody aboveground net primary productivity (ANPP_stem)

ANPP_stemp calculations (whole plot and by species) were made in [this script](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/Calculate_ANPP.R).

### Time period
2008-2013

### Units
Mg C ha-1 y-1  (using 0.47 conversion factor for biomass -> C)

### biomass allometries 
We used aboveground biomass allometries compiled for SCBI (found in [this script](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/R_scripts/scbi_Allometries.R).
 
### Growth outliers
To identify and deal with outliers, surviving trees were grouped into size bins 1-5cm, 5-10cm, 10-50cm, and >50cm and the yearly change in AGB
of trees that had a growth rate more than 4 std outside the mean for their size bin were replaced with the mean yearly change in AGB of their siz bin.

### Recruitment
Recruitment is included in our [main calculations](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/summary_data/ANPP_total_and_by_species.csv), excluded from [these](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/summary_data/ANPP_total_and_by_species_without_recruitment.csv).

