# SCBI Seedlings 

## Sampling location
[SCBI ForestGEO plot](https://forestgeo.si.edu/sites/north-america/smithsonian-conservation-biology-institute)

## Sampling dates
2010- 2019 (no sampling during 2013 and 2018)

## Protocols
Initial protocols are described in [Bourg et al. 2013](https://esajournals.onlinelibrary.wiley.com/doi/abs/10.1890/13-0010.1), which covers methods used from 2010 to 2012. A few modifications were added after 2014 (i.e., seedlings under 10 cm tall were not tagged and leaves were not counted), and fewer plots are measured after this year (mostly due to lack of funding). 

In 2014 we subset our original sample (~320 plots or 110 'stakes') and ramdomly selected plots based on their habitat type: 1) Riparian-ash dominat; 2) Tulip poplar dominant; and 3) Oak dominant. Check [this map](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/blob/master/seedlings/doc/Plots_after_2014/Habitat%20types%20-%203%20clusters.pdf) to see the distribution of these groups in each quadrat based on basal area of the ten dominant tree species. The dominant species make up approximately 80% of the basal area of each group (McGarvey 2014). In total 41 quadrats are currenlty measured representative of all habitat types. 


## About this repository: 
Data since 2010 are storaged in this repository, in addition to related files:
* [Raw_data](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/tree/master/seedlings/data/raw/raw-data_originals): Here we keep the original .xls versions for years 2013-2019 as saved in a physical drive at SCBI. **DO NOT CHANGE THESE FILES**.
* [Original Metadata](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/tree/master/seedlings/data/raw/metadata): File containg the original metadata. It includes the description of columns for the .xls files and species codes. 
* [Master data](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/tree/master/seedlings/data/cleaned): Curated raw data using R scripts. Use this master version for future analysis.
* [Clean Metadata](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/tree/master/seedlings/data): Metadata files for: a) data, and b) species found in all surveys.
* [R scripts](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/tree/master/seedlings/src): This folder constains R scripts to process SCBI seedling data.
* [Seedling guide](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/tree/master/seedlings/doc/Seedling%20guide): A picture guide for common seedlings found at SCBI (find a printed copy in the lab to bring to the field).
* [Plot location](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data_private/tree/master/seedlings/plot%20location): Files with seedling plot locations within SCBI plot. 


## Contributors
| name | GitHub ID| position* | role |
| -----| ---- | ---- |---- |
| Kristina Anderson-Teixeira | teixeirak | staff scientist, SCBI & STRI | PI overseeing project since 2020 |
| Erika Gonzalez-Akre | gonzalezeb | lab/data manager, SCBI | led 2012 census, oversaw subsequent censuses until 2019|
| William McShea | | staff scientist, SCBI & STRI | PI overseeing project since 2010 |
| Norm Bourg| |	research associate| SCBI	Plot PI, led census in 2010 |
| Jenny McGarvey | | research assistant, SCBI | led 2010-2011 census |
| Nidhi Vinod|| research assistant, SCBI | helped organize data in 2020 |

*refers to position at time of main contribution to this repository
[List does not yet include field assistants/ students/ volunteers who helped collect data]

## Publications using these data

Seedling data from 2010-2012 and methods are published in [Bourg et al. 2013](https://esajournals.onlinelibrary.wiley.com/doi/abs/10.1890/13-0010.1).  
* [McGarvey et al 2013](http://ctfs.si.edu/Public/pdfs/McGarveyEtAl.NENat2013.pdf) studied the effects of deer chronic browsing in Eastern forest. 
* [Ramage et al. 2017](https://onlinelibrary.wiley.com/doi/full/10.1002/ece3.3298) investigated how sapling growth rates were affected by conspecific adult neighbors 

