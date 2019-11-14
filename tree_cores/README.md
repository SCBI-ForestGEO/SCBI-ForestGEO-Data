# SCBI Tree Cores

## Overview 
This folder contains tree-ring data from the SCBI ForestGEO plot. It includes two sets of cores (live tree cores taken 2010-2011, dead tree cores taken 2016-2017), which have been combined to build chronologies. 
- **[chronologies](https://github.com/EcoClimLab/SCBI-ForestGEO-Data/tree/master/tree_cores/chronologies)** - These are our current best chronologies, some of which are complete and others of which are in the process of development. These were developed for an analysis led by Ryan Helcoski (see [this repository](https://github.com/SCBI-ForestGEO/climate_sensitivity_cores)) and match chronologies used in that analysis as of December 2018. This repository is considered the master version of SCBI chronologies, and future developments will be registered here.
- **[cross-dated_cores_CSVformat](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_cores/cross-dated_cores_CSVformat)** - This folder contains all cross-dated cores (those in [chronologies](https://github.com/EcoClimLab/SCBI-ForestGEO-Data/tree/master/tree_cores/chronologies)) rearranged into .csv format, which is more convenient than .rwl for certain types of analyses. 
- **[R-script](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_cores/R-script)**-This folder contains scripts used to manipulate the data in this repository. Included are scripts for data rearrangement and general-interest scripts; those used for specific analyses are housed elsewhere.
- **[measurement files](https://github.com/EcoClimLab/SCBI-ForestGEO-Data/tree/master/tree_cores/measurement_files)**- This folder contains raw and intermediary data files, the latter of which were produced during the process of chronology building. These files are not ready for analysis (*i.e.*, not fully cross-dated), but are archived here in case they are ever needed. 


## Sampling location
[SCBI ForestGEO plot](https://forestgeo.si.edu/sites/north-america/smithsonian-conservation-biology-institute)


## Sampling dates
Live tree cores: June 2010 - March 2011

Dead tree cores: summer 2016, summer 2017


## Protocols

**1. Live tree cores taken in 2010-11.** 997 live trees from SCBI ForestGEO Plot were cored between June 2010 and March 2011. In total 703 of these cores were measured using the Velmex system, their ring data saved in Tucson format, and the physical cores stored. The remaining cores were visually inspected, but no data were extracted. Some of these data were published in [Bourg et al. 2013](http://onlinelibrary.wiley.com/doi/10.1890/13-0010.1/full)

**2. Cores taken as part of our annual mortality census in 2016 and 2017.** The census is described in [Gonzalez-Akre et al. (2015)](https://esajournals.onlinelibrary.wiley.com/doi/abs/10.1002/ecs2.1595). All trees found dead in 2016 and 2017 were cored at breast height and their base except in areas where extreme rot or other hazards prevented boring or resulted in a very poor quality core. In 2016, 230 total cores were measured using the Velmex system, their ring data saved in Tucson format, and the physical cores stored. In 2017, 286 total cores were measured using the WinDENDRO system, their scans saved in high resolution, their ring data saved in both WinDENDRO and Tucson format, and the physical cores stored.

## Species

As of 2018, we have final chronologies for 14 canopy species, including the top 12 contributors to ANPP_stem (all species contributing >1% of ANPP_stem). We have cores for other species for which we not yet developed chronologies because of insufficient sample size and/or the difficult nature of working with cores from the species. 

All species for which cores were taken and the statuses of their chronologies are given [here](https://github.com/EcoClimLab/SCBI-ForestGEO-Data/blob/master/tree_cores/chronologies/chronology_list.csv).


## Tree data
Data on trees from which cores were taken is available through the core census data (all years) and annual tree mortality census (2016, 2017). Please see [this page](https://github.com/EcoClimLab/SCBI-ForestGEO-Data) for links to the data.


## Physical Samples

Mounted, sanded cores are stored at the Smithsonian Conservation Biology Institute (attic of the office annex), except for a small number that have been removed for isotopic analysis (LITU and QURU cores to J. Mathias in 2018). Cores are available upon reasonable request.

## Data use

Data are published and open access. **However, as these data are currently being used in an intern-led analysis, we ask that anyone interested in using them please contact the PI (Kristina Anderson-Teixeira) to ensure that there is no conflict.**  We welcome inquiries about potential collaboration.

Studies using these data should cite:
- [Bourg et al. 2013](http://onlinelibrary.wiley.com/doi/10.1890/13-0010.1/full) (original publication of 2010-11 data)
- [Helcoski et al. 2019](https://nph.onlinelibrary.wiley.com/doi/10.1111/nph.15906) (2016-17 data, and cross-dating of all cores)


## Contributors
| name | GitHub ID| position* | role |
| -----| ---- | ---- |---- |
| Kristina Anderson-Teixeira | teixeirak | staff scientist, SCBI & STRI | PI overseeing project since 2016 |
| Alan Tepley | tepleya | senior research fellow, SCBI | co-investigator: planning, training, guiding analysis | 
| Jonathan Thompson |  | staff scientist, SCBI (now Senior Investigator, Harvard Forest) | PI overseeing collection of 2010-2011 cores |
| Neil Pederson |  | Senior Investigator, Harvard Forest | oversight of chronology building |
| Ryan Helcoski | RHelcoski | research assistant, SCBI | collected and measured 2017 cores, compiled chronologies |
| Jennifer McGarvey | | research assistant, SCBI | collected and measured 2010-2011 cores (does not feel future co-authorship would be appropriate)| 
| Victoria Meakem |  | research assistant, SCBI | collected and measured 2016 cores (does not feel future co-authorship would be appropriate)|
| Ian McGregor | mcgregorian1 | research assistant, SCBI | work with cores data, including R scripts for data manipulation |
 
*refers to position at time of main contribution to this repository

[List does not yet include field and lab assistants/ students/ volunteers who helped collect and process cores]

## Funding 
- ForestGEO 
- Virginia Native Plant Society
