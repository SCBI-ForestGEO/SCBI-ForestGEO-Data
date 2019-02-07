# SCBI tree ring measurement files

This folder contains measurement files and notes for SCBI tree cores. *These files will not be useful to most users of these data, but are archived here in case they are ever needed.*

**[Raw measurement files](https://github.com/EcoClimLab/SCBI-ForestGEO-Data_private/tree/master/tree_cores/measurement_files/raw)** are the original output of measurement software.  

**[Processed measurement files](https://github.com/EcoClimLab/SCBI-ForestGEO-Data_private/tree/master/tree_cores/measurement_files/processed)** were shifted during the process of chronology building; however, *subsequent shifts were implemented later during the process, so these files do not always match the chronologies*.

**measurement notes** - These files contain a list of all trees cored, date ranges, and initial status of inclusion or rejection in original chronologies, and notes. These files were used when measuring raw cores in 2010,2011,2016 and 2017 they have not been updated to reflect inclusion or rejection in current chronologies.

Data files (.rwl; viewable in text edit program) are in Tucson Format:
  - Col1- core ID, which is a concatanation of the following: [tree tag number recorded when core was taken*][code designating core position: A- 1.3 m height; B- tree base][rarely, 'R' indicating that the core was re-measured]. *Tag number used in ID is almost always the correct ForestGEO tag number; however, in the very rare instance of a typo (n=1 at present), the tag number was corrected in measurement notes ifle but not in all data files. 
  - Col2- decade (in the first row, this is the year of the first ring) 
  - Col3-12- ring width (micrometers), -9999 indicates end of an individual core
  
Live trees cored in 2010 and 2011 are kept together in a single .raw file seperated by species and year. Dead trees cored in 2016 and 2017 are seperated by individual tree core with the species code followed by tree ID number followed by A(core is from 1.3 dbh) or B(core is from base of tree).

Metadata on the cores is included in [`measurement_notes_2010`](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/blob/master/tree_cores/measurement_files/measurement_notes_2010_chronology.csv) and [`measurement_notes_2016_17`](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/blob/master/tree_cores/measurement_files/measurement_notes_2016_17_chronology.csv).
  - In 2016-2017 notes, core ID is a concatanation of the following: [species code] [tree tag number recorded when core was taken*][code designating core position: A- 1.3 m height; B- tree base][rarely, 'R' indicating that the core was re-measured]. *Tag number and species code used in ID is almost always correct; however, in the very rare instance of an error, the tag number / species code was corrected in measurement notes file but not in the core ID. 

