This folder contains all cross-dated data combined into a single .csv file.

### all_core_chronologies.csv

This file was created from the script [standardize_rwl_to_csv](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_cores/R-script). It includes only the "\_drop.rwl" cores in the [complete](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_cores/chronologies/current_chronologies/complete) folder, which themselves are all "included" cores as indicated in the [measurement notes files](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_cores/measurement_files).

The file has the following format:
  - Col1 - `tag` - ForestGEO tag number. Corresponds to tag numbers in [SCBI-ForestGEO census data](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_main_census)
  - Col2 - `coreID` - concatanation of the following: [tree tag number recorded when core was taken*][code designating core position: A- 1.3 m height; B- tree base][rarely, 'R' indicating that the core was re-measured]. 
     - *there should be no coreIDs with "B", since no B cores were considered "complete"*
  - Col3 - `sp`-  species code
  - Col3 - `core.position`-  position at which core was taken: A- 1.3 m height; B- tree base
  - Col4 - `status.at.coring` - status (live/ dead) at time of coring
  - Col5:end- `[year]` - [ring width (mm) in each year]

