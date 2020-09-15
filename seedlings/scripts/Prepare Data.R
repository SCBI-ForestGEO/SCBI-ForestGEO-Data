#Purpose: Format seedling data to create clean data files
#Developed by: Nidhi Vinod-- vinodn@si.edu, Mentor and reviewed by: Erika Gonzalez-Akre
#R version 3.6.3(2020-01-29)

#clean environment#### 
rm(list=ls())
#load libraries
library(tidyverse)
library(readr)

#First: Create a dataframe per census year from raw csv data. We were reading  data directly from Github online but sometimes that was too slow so now we are reading data from within the R project

seed2010 <-read.csv("data/raw/Seedling2010.csv")
seed2011 <-read.csv("data/raw/Seedling2011.csv")
seed2012 <-read.csv("data/raw/Seedling2012.csv")
seed2014 <-read.csv("data/raw/Seedling2014.csv")
seed2015 <-read.csv("data/raw/Seedling2015.csv")
seed2016 <-read.csv("data/raw/Seedling2016.csv")
seed2017 <-read.csv("data/raw/Seedling2017.csv")
seed2019 <-read.csv("data/raw/Seedling2019.csv")

#deleting unwanted columns:

#seed2010:deleted "Note", "X.leaves","PlotInfo.PlotID" column
seed2010 = subset(seed2010, select = -c(Note, PlotInfo.PlotID, X.leaves))

#seed2011: deleted "Note", "No.leaves", "PlotInfo.PlotID" and "2010Tag" column
seed2011 = subset(seed2011, select = -c(Note, X2010.Tag, PlotInfo.PlotID, X.leaves))

#seed2012: deleted "No.leaves"
seed2012 = subset(seed2012, select = -c(n.leaves))

#seed2014: deleted "Height.2012" and ""Notes.2012"
seed2014 = subset(seed2014, select = -c(Height.2012, Notes.2012))

#seed2015: deleted "Height.cm.2014" and "Notes.2014"
seed2015 = subset(seed2015, select = -c(Height.cm.2014, Notes.2014))

#seed2016: deleted "hgt.2015" and "Notes.2015"
seed2016 = subset(seed2016, select = -c(hgt.2015, Notes.2015))

#seed2017: deleted "hgt.2015", "Notes.2015", "hgt.2016", "Notes.2016"
seed2017 = subset(seed2017, select = -c(hgt.2015, Notes.2015, hgt.2016, Notes.2016))

#seed2019: deleted "hgt.2015", "hgt.2016", "hgt.2017", "Notes.2017"
seed2019 = subset(seed2019, select = -c(hgt.2015, hgt.2016, hgt.2017, Notes.2017))

#renaming columns

seed2010 <- seed2010 %>% rename(Date = "ï..Census.date", perc.L = "L....", perc.Invasive1 = "I.....", Invasive1 = "InvSp")

seed2011 <- seed2011 %>% rename(Date = "ï..Census.date", perc.L = "X.L", perc.Invasive1 = "X.Invas", Invasive1 = "InvSp", Invasive2 = "X", perc.Invasive2 = "X.1", Invasive3 = "X.2")

seed2012 <- seed2012 %>% rename(Date = "ï..Census.date", perc.L = "L.perc", perc.Invasive1 = "I.perc", Invasive1 = "InvSp", Invasive2 = "X.1", perc.Invasive2 = "X.2", Invasive3 = "X.3", perc.Invasive3 = "X.4", Invasive4 = "X.5")

seed2014 <- seed2014 %>% rename(Date = "ï..Census.date", Tag = "Tag..", Height.cm = "Height.cm.2014", Notes = "Notes.2014", X = "x", Y = "y", perc.L = "X.L", perc.Invasive1 = "X.invasive1", perc.Invasive2 = "X.invasive2", perc.Invasive3 = "X.invasive3", perc.Invasive4 = "X.invasive4")

seed2015<- seed2015 %>% rename(Date = "ï..Census.date", Tag = "Tag..", Height.cm = "hgt.2015", Notes = "Notes.2015", X = "x", Y = "y", perc.L = "X.Leaflitter", perc.Invasive1 = "X.invasive1", perc.Invasive2 = "X.invasive2", Invasive3 = "X")

seed2016<- seed2016 %>% rename(Date = "ï..Census.date", Tag = "Tag.", Height.cm = "hgt.2016", Notes = "Notes.2016", X = "x", Y = "y", perc.L = "X.Leaflitter", perc.Invasive1 = "X.invasive1", perc.Invasive2 = "X.invasive2", Invasive3 = "X")

seed2017<- seed2017 %>% rename(Date = "ï..Census.date", Tag = "Tag.", Height.cm = "hgt.2017", Notes = "Notes.2017", X = "x", Y = "y", perc.L = "X.Leaflitter", perc.Invasive1 = "X.invasive1", perc.Invasive2 = "X.invasive2", perc.Invasive3 = "X.invasive3", perc.Invasive4 = "X.invasive4", perc.Invasive5 = "X.invasive5", perc.Invasive6 = "X.invasive6")

seed2019<- seed2019 %>% rename(Date = "ï..Census.date", Tag = "Tag.", Height.cm = "hgt.2019", Notes = "Notes.2019", X = "x", Y = "y", perc.L = "X.Leaflitter", perc.Invasive1 = "X.invasive1", perc.Invasive2 = "X.invasive2", perc.Invasive3 = "X.invasive3", perc.Invasive4 = "X.invasive4", perc.Invasive5 = "X.invasive5", perc.Invasive6 = "X.invasive6")


#Adding Columns:
seed2010 = add_column(seed2010, X = NA, Y = NA, Invasive2 = NA, perc.Invasive2 = NA, Invasive3 = NA, perc.Invasive3 = NA, Invasive4 = NA, perc.Invasive4 = NA, Invasive5 = NA, perc.Invasive5 = NA, Invasive6 = NA, perc.Invasive6 = NA)
seed2011 = add_column(seed2011, X = NA, Y = NA, perc.Invasive3 = NA, Invasive4 = NA, perc.Invasive4 = NA, Invasive5 = NA, perc.Invasive5 = NA, Invasive6 = NA, perc.Invasive6 = NA)
seed2012 = add_column(seed2012, perc.Invasive4 = NA, Invasive5 = NA, perc.Invasive5 = NA, Invasive6 = NA, perc.Invasive6 = NA)
seed2014 = add_column(seed2014, Invasive5 = NA, perc.Invasive5 = NA, Invasive6 = NA, perc.Invasive6 = NA)
seed2015 = add_column(seed2015, perc.Invasive3 = NA, Invasive4 = NA, perc.Invasive4 = NA, Invasive5 = NA, perc.Invasive5 = NA, Invasive6 = NA, perc.Invasive6 = NA)
seed2016 = add_column(seed2016, perc.Invasive3 = NA, Invasive4 = NA, perc.Invasive4 = NA, Invasive5 = NA, perc.Invasive5 = NA, Invasive6 = NA, perc.Invasive6 = NA)

#merging columns for seed2017 and 2019: NOtes and Additional Plot Comments
seed2017$Notes.PlotComments = paste(seed2017$Notes, seed2017$Additional.plot.comments, sep = " / ")
seed2017 = subset(seed2017, select = -c(Notes, Additional.plot.comments))
seed2017$Notes.PlotComments[seed2017$Notes.PlotComments == " / "] <- NA
seed2017<- seed2017 %>% rename(Notes = Notes.PlotComments)

seed2019$Notes.PlotComments = paste(seed2019$Notes, seed2019$Additional.plot.comments, sep = " / ")
seed2019 = subset(seed2019, select = -c(Notes, Additional.plot.comments))
seed2019$Notes.PlotComments[seed2019$Notes.PlotComments == " / "] <- NA
seed2019<- seed2019 %>% rename(Notes = Notes.PlotComments)

#rearrange column order
seed2010<-seed2010[,c(1:4,8,17:18,5,12,6:7,9,21,22,19,20,13,14,23,24,10,11,15,16)]
seed2011<-seed2011[,c(1:4,9:12,8,16,17,5,7,6,13:15, 18:24)]
seed2012<-seed2012[,c(1:4,9:11,14,8,12,13,5,7,6,15,16:24)]
seed2014<-seed2014[,c(1:4,6,7,8,9,5,10:12, 13:24)]
seed2015<-seed2015[,c(1:4,6:9,5,10:24)]
seed2016<-seed2016[,c(1:4,6:9,5,10:24)]
seed2017<-seed2017[,c(1:4,6:8,24,5,9:11,12:23)]
seed2019<-seed2019[,c(1:4,6:8,24,5,9:11,12:23)]

#check that all dataframes have columns in same order
names(seed2012) # they do now.

#create a dataframe to check spCodes for all years
spcodes<-as.data.frame (unique(c(as.character(seed2010$SpCode), as.character(seed2011$SpCode), as.character(seed2012$SpCode),as.character(seed2014$SpCode),as.character(seed2015$SpCode),as.character(seed2016$SpCode),as.character(seed2017$SpCode),as.character(seed2019$SpCode))))

#change colum name to improve view
names(spcodes)[1] <- "spcode"

#now make sure only species codes are in the sp column! ie. not tag numbers
#correct typos
#
#do the same for invasives: built a df  

invasive<-as.data.frame (unique(c(as.character(seed2010$Invasive1,seed2010$Invasive2))))
                , 
                as.character(seed2010$Invasive2),
                as.character(seed2010$Invasive3))))



#Final step
#save cleaned data to clean seedlings folder
write.csv(seed2010, "data/cleaned/seedling_2010.csv", row.names=F)
write.csv(seed2011, "data/cleaned/seedling_2011.csv", row.names=F)
write.csv(seed2012, "data/cleaned/seedling_2012.csv", row.names=F)
write.csv(seed2014, "data/cleaned/seedling_2014.csv", row.names=F)
write.csv(seed2015, "data/cleaned/seedling_2015.csv", row.names=F)
write.csv(seed2016, "data/cleaned/seedling_2016.csv", row.names=F)
write.csv(seed2017, "data/cleaned/seedling_2017.csv", row.names=F)
write.csv(seed2019, "data/cleaned/seedling_2019.csv", row.names=F)
