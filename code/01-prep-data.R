
## load packages
library(data.table)
library(ggplot2)

## load data
raccoon <- fread("input/raccoon.csv")

## remove un-needed columns
raccoon[,c("Altitude", "Primary Key", 
           "Comments", "Fix #", "Fix Status", 
           "# Sats", "Location ID", 
           "Fix Time Raw") := NULL]

setnames(raccoon, 
         c("Fix Date", "Fix Time New", 
           "Time Zone Adjusted", "Hour", 
           "Time difference", "Date Difference", 
           "Latitude", "Longitude", "Temp",
           "Location Type", "Year", 
           "Animal ID", "Collar ID"), 
         c("date", "time", "tz-time",
           "hr", "timediff", "datediff",
           "lat", "long", "temp", 
           "location", "yr", "id", "collar_id"))

## convert dates/times to POSIXct
raccoon$date <- as.POSIXct(raccoon$date, 
                           format = "%m-%d-%y")
raccoon$time <- as.POSIXct(raccoon$time, 
                           format = "%H:%M:%S")

## convert dates/times and data.table format
raccoon[, idate := as.IDate(date)]
raccoon[, itime := as.ITime(time)]
raccoon[, datetime := as.POSIXct(paste(idate,itime), format = "%Y-%m-%d %H:%M:%S" )]

## quick plot 

ggplot(raccoon[location == "Conservation Area" & Session == 3 & yr == "2013"],
       aes(long, lat, color = idate)) +
  geom_point() +
  geom_path() +
  facet_wrap(~yr*id)
