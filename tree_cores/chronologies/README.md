# SCBI Tree Ring Chronologies

This folder contains the following:

- [chronology list](https://github.com/EcoClimLab/SCBI-ForestGEO-Data/blob/master/tree_cores/chronologies/chronology_list.csv) - This file summarizes current chronologies, including species, numbers of cores included and rejected, and status of the chronology. Also included are statistics on abundance and ANPP_stem of each species within the 25.6ha plot, as described [here](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/blob/master/summary_data/ANPP_total_and_by_species.csv). This includes information on chronologies only, not on individual cores or trees. All cores included in the completed chronologies were taken from trees at dbh ("A" cores in 2016 and 2017), incomplete chronologies may still include cores taken at base height. Only complete chronologies should be used for analysis, all other chronologies and cores have not been reviewed thoroughly.

- [current_chronologies](https://github.com/EcoClimLab/SCBI-ForestGEO-Data/tree/master/tree_cores/chronologies/current_chronologies) - This folder contains the most recent chronologies, as .rwl files (viewable in text edit program). These are the most up to date chronologies, separated into complete and incomplete folders. Refer to [chronology list](https://github.com/EcoClimLab/SCBI-ForestGEO-Data/blob/master/tree_cores/chronologies/chronology_list.csv) for chronology information, including numbers of cores and chronology status  (completed, incomplete, or  too few cores to form a proper chronology). As a general rule, any file with the word "drop" in the title is a compilation of more than 3 trees. These are in Tucson Format:
  - Col1- core ID, which is a concatanation of the following: 
  
    - tree tag number recorded when core was taken*
      
    - code designating core position: A- 1.3 m height; B- tree base
    
    - rarely, 'R' indicating that the core was re-measured. 
    
    \**Tag number used in ID is almost always the correct ForestGEO tag number; however, in the very rare instance of a typo (n=1 at present), the tag number was corrected in measurement notes file but not in all data files.* 
    
  - Col2- decade (in the first row, this is the year of the first ring) 
  - Col3-12- ring width (micrometers), -9999 indicates end of an individual core
  
- [cofecha_output](https://github.com/EcoClimLab/SCBI-ForestGEO-Data/tree/master/tree_cores/chronologies/cofecha_output) - Cofecha is a program for validating cross-dating. Files can be opened in a text editor. COFECHA files can be used to view information on specific trees and cores including individual correlation with the overall chronology, number of years included in each core, growing seasons, etc. Note that COFECHA files have been completed for all chronologies, even species with too few cores to be useful. Again, refer back to Refer to [chronology list](https://github.com/EcoClimLab/SCBI-ForestGEO-Data/blob/master/tree_cores/chronologies/chronology_list.csv) to determine if the select chronology is completed, incomplete, or has too few cores to form a proper chronology.
