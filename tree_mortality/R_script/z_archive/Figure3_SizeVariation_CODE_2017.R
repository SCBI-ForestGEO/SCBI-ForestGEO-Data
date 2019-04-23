###########################################################################
# Purpose: Create figure 3: Size-Related variation in mortality percentage and mortality biomass
# Data: ForestGEO census data AND XXXXXXXX (year(s))annual mortality data
# Author: Based on Tori Meakem - 10/26/2016; # Adapted by Ryan Helcoski - 8/11/2017
# Point of contac: HelcoskiR@si.edu
##########################################################################
### NOTE!! This is currently only to be used for including 2016 and 2017 mortality data into the previous figure 3 that only included up to 2015. It is not standardized to be used for coming years


# Clean Environment ####
rm(list = ls())


# Set up working directory
setwd("")


# Load libraries ####

# Load functions ####
source("R_script/Figure3_SizeVariation_FUNCTIONS_2017.R")

# INPUT DATA LOCATION ####
Input_data_location <- "INPUT_FILES/"

# OUTPUT DATA LOCATION ####
Output_data_location_Stats <- "OUTPUT_FILES/Stats/"
Output_data_location_Graphs <- "OUTPUT_FILES/Graphs/"

# Load Data ####

## Load ForestGEO Census data (stem R tables)
load(paste0(Input_data_location, "scbi.stem1.rdata"))
load(paste0(Input_data_location, "scbi.stem2.rdata"))

## Load annual mortality data
# load(paste0(Input_data_location, "allmort17.rdata"))

allmort17 <- read.csv(paste0(Input_data_location, "allmort17.csv"))


### NOTE### this was a minor correction of an incorrect date entered in 2016, date was accidently entered as 2106 instead of 2016. It has since been corrected in the original raw csv file, however, this  script is using the original allmort17.csv. It has been corrected in the newest version and is no longer necessary
#allmort17[allmort17$date.2016 %in% 53539,]$date.2016 <- as.numeric(as.Date("2016-08-02"))

# set up parameters ####
hectar = 25.6 #Plot size in hectares
ddiv = c(10, 12.5, 15.5, 19.5,24,30,37.5,46.5,58,72,90,112,140,174,217,270.5,337,420,523,652,812.5,10000) #Approximately log-even DBH size bins
nreps = 1000 #number of bootstrap replicates for calculating CIs
datadir = paste0(Output_data_location_Stats, "TreeMort") #Name of output file for stats tables and Rdata
outfilestem = "Rate" #Name of output file appended to datadir
gridsize = 50 # the dimension of the subplots to be used for bootstrapping: it is gridsize x gridsize m
alpha = c(0.05, 0.01) # the p-value for confidence intervals

# CODE BEGINS ####

## Remove all previously dead stems; mark each tree as live (mind$mort=0) or dead (mind$mort=1)
## Also includes initial dbh (dinit) and biomass change per year (agb) using exact time measurements


### !!!! TO DO FOR RYAN : REPLACE indcalcmort12, indcalcmort23 and indcalcmort34 BY ONLY ONE FUNCTION WERE YOU CAN SPECIFY WHAT YEARS TO USE AND THEN WRITE A LOOP TO GO THROUGH EACH YEARS !!!! ######
mind12 <- indcalcmort12(scbi.stem1,scbi.stem2,10) #2008-13 census
mind23 <- indcalcmort23(allmort17) #2013-2014
mind34 <- indcalcmort34(allmort17) #2014-2015
mind45 <- indcalcmort45(allmort17) #2015-2016
mind56 <- indcalcmort56(allmort17) #2016-2017

#Make subset with dead trees only
mortagb12<-mind12[mind12$mort==1&!is.na(mind12$mort),]
mortagb23<-mind23[mind23$mort==1&!is.na(mind23$mort),]
mortagb34<-mind34[mind34$mort==1&!is.na(mind34$mort),]
mortagb45<-mind45[mind45$mort==1&!is.na(mind45$mort),]
mortagb56<-mind56[mind56$mort==1&!is.na(mind56$mort),]

#Put all 5 censuses into a list
minds<-list(mind12,mind23,mind34,mind45,mind56)
mortagb<-list(mortagb12,mortagb23,mortagb34,mortagb45,mortagb56)
emszdata<-list() #Empty list prepared for biomass mortality
mszdata<-list() #Empty list prepared for mortality
ncensus<-c("2008-2013","2013-2014","2014-2015", "2015-2016" , "2016-2017") #Census names

Runall(minds,mortagb,ncensus) #This function runs everything


