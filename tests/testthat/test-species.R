library(testthat)

test_that("All species are valid in latest mort census", {
 
  
  # read latest mortality census survey
  all_mort_files <- list.files(raw_data_path, pattern = "Mortality_Survey_.*csv", full.names = T)

  i <- which.max(as.numeric(substr(all_mort_files, nchar(all_mort_files)-7, nchar(all_mort_files)-4)))
    
  mort <- read.csv(all_mort_files[i])
  
  
  # read species table

  spptable <- read.csv("tree_main_census/data/census-csv-files/scbi.spptable.csv")
  
  
  # check if all species exist in species table
 
    expect_true(all(mort[,grepl("^sp", names(mort))] %in% spptable$sp))
})