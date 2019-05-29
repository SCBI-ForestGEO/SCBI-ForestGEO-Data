# Tree heights at SCBI

Height data has been collected by different researchers over the years, which are included in the SCBI_tree_heights.csv.

This table summarizes the different contributions.

|Year|Researcher|Data Collector|Instrument|Method|Math|# observations|Publication|
|---|----------|-------|-------|-----|-------|-----|--------|
|2012|Jonathan Thompson|Chris Lewis, Jennifer McGarvey|Impulse 200 Standard Rangefinder|digital|tangent|230|[Anderson-Texeira et al 2015](https://doi.org/10.1111/1365-2435.12470)
|2013|Jonathan Thompson|Jennifer McGarvey|Impulse 200 Standard Rangefinder|digital|tangent|60|[Anderson-Texeira et al 2015](https://doi.org/10.1111/1365-2435.12470)
|2015|Atticus Stovall|Atticus Stovall|clinometer and tape measure|manual|tangent|48|[Stovall et al 2018, For. Ecology & Man.](https://doi.org/10.1016/j.foreco.2018.06.004)
|2015|Atticus Stovall|Atticus Stovall|terrestrial laser scanning (TLS)|automatic|NA|329|[Stovall et al 2018 Data in Brief](https://doi.org/10.1016/j.dib.2018.06.046)
|2018|Sarah Macey|Sarah Macey, Daniel Spiwak |Nikon ForestryPro rangefinder|digital|sine|18
|2019|Ian McGregor|Ian McGregor|Nikon ForestryPro rangefinder|digital|sine|36

### Thompson data
The data for Thompson was collected in 2012 and 2013, before the official 2013 ForestGEO census data (for DBH) was completed. In the original data, Thompson's heights were listed with the 2008 ForestGEO DBH. Because of the minimal difference between the measurement years and the second census year, this has been updated. 
- All Thompson data have only the 2013 DBH reported. If a tree was reported dead in the 2013 census, the 2008 DBH is reported. 

### Stovall data (TLS)
TLS data was collected in winter, with very high confidence in the results, with no issues from occlusion in the upper canopy. Height allometry was validated with manual estimates, seen in Figure S1 of the associated publication.
- note: manual measurement data for Stovall et al 2018 are not in online publication. Full data with TLS dbh is from [heights_Stovall_TLS_raw_2015.csv](https://github.com/SCBI-ForestGEO/SCBI-ForestGEO-Data/tree/master/tree_dimensions/tree_heights/raw_data), whereas the TLS-measured height with dbh from the 2013 ForestGEO census is available from the Data in Brief publication.
- note: It is recommended when using Stovall's data, the TLS measurements of DBH (modeled) be used, due to the 2-year gap between the field DBH measurements and the TLS measurements (plus the wellness of fit between the two; see Stovall publications). There were some outliers where the modeled TLS DBH failed, thus in adding this data, if TLS measurements for DBH were >10cm difference compared to the 2013 field DBH, then the 2013 DBH is recorded in the table.
- **NB: Each observation in the table has exactly one measure for DBH, either from 2008, 2013, 2015 (TLS), or 2018**
