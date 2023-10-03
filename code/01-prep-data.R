
## load packages
library(data.table)
library(ggplot2)

## load data
raccoon <- fread("input/raccoon.csv")

## remove un-needed columns
raccoon[,c("Altitude", "Primary Key", 
           "Comments", "Fix #", "Fix Status", 
           "# Sats",
           "Fix Time Raw") := NULL]

setnames(raccoon, 
         c("Fix Date", "Fix Time New", 
           "Time Zone Adjusted", "Hour", 
           "Time difference", "Date Difference", 
           "Latitude", "Longitude", "Temp",
           "Location Type", "Year", 
           "Animal ID", "Collar ID", "Location ID"), 
         c("date", "time", "tz-time",
           "hr", "timediff", "datediff",
           "lat", "long", "temp", 
           "location", "yr", "id", "collar_id", "loc_id"))

## convert dates/times to POSIXct
raccoon$date <- as.POSIXct(raccoon$date, 
                           format = "%m-%d-%y")
raccoon$time <- as.POSIXct(raccoon$time, 
                           format = "%H:%M:%S")

## convert dates/times and data.table format
raccoon[, idate := as.IDate(date)]
raccoon[, itime := as.ITime(time)]
raccoon[, datetime := as.POSIXct(paste(idate,itime), format = "%Y-%m-%d %H:%M:%S" )]

#### remove erroneous fixes ####

## remove NAs for lat and long 
raccoon <- raccoon[!is.na(raccoon$lat),]
raccoon <- raccoon[!is.na(raccoon$long),]

## change names of locations
raccoon$location[raccoon$location == "Conservation Area"] <- "CA"
raccoon$location[raccoon$location == "Swine Farm"] <- "SF"

## add unique identifier for each ID
raccoon$id_loc_yr_ses <- as.factor(paste(raccoon$id,
                                      raccoon$location,
                                      raccoon$yr, 
                                      raccoon$Session, 
                                   sep = "_"))

## assign unique var to loc, yr, session
raccoon$loc_yr_ses <- as.factor(paste(raccoon$location,
                                         raccoon$yr, 
                                         raccoon$Session, 
                                         sep = "_"))

fwrite(raccoon, "output/raccoon.csv")


