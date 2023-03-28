
## load packages
library(data.table)

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


