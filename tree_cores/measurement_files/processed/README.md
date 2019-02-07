## Shifted measurement files

These are the core measurement files where data have been shifted based on visual inspection of cores and the results of the cross-dating analysis (COFECHA). These files were used to create chronologies. 

Data files (.rwl; viewable in text edit program) are in Tucson Format:
  - Col1- core ID, which is a concatanation of the following: [species code][tree tag number][code designating core position: A- breast heigth; B- tree base][rarely, 'R' indicating that the core was re-measured]
  - Col2- decade (in the first row, this is the year of the first ring) 
  - Col3-12- ring width (micrometers), -9999 indicates end of an individual core

Live trees cored in 2010 and 2011 are kept together in a single .raw file seperated by species and year. Dead trees cored in 2016 and 2017 are seperated by individual tree core with the species code followed by tree ID number followed by A(core is from 1.3 dbh) or B(core is from base of tree). All trees are compiled into [species]_all files, which were used to create the chronologies. 

Shifted and altered files are copies of their original with alterations as suggested by visual inspection and/or COFECHA and verified by visual inspection of said cores. See [`measurement_notes_2010_raw`](https://github.com/EcoClimLab/SCBI-ForestGEO-Data_private/blob/master/tree_cores/measurement_files/measurement_notes_2010_raw.csv) and [`measurement_notes_2016_17_raw`](https://github.com/EcoClimLab/SCBI-ForestGEO-Data_private/blob/master/tree_cores/measurement_files/measurement_notes_2016_17_raw.csv) for justifications of any changes made to individual core files.
