
### Packages ----
libs <- c('data.table', 'ggplot2', 'sf',
          'spatsoc', 'dplyr', 'amt')
lapply(libs, require, character.only = TRUE)


#### load data
raccoon <- fread("output/raccoon.csv")

############################################################
###### Calculate Home range area for each individual #######
###########################################################

epsg_in <- 4326
epsg_out <- 32617

sf_DF <- st_as_sf(
  raccoon,
  coords = c('long', 'lat'),
  crs = epsg_in
)

sf_DF <- st_as_sf(
  sf_DF,
  coords = c('long', 'lat'),
  crs = epsg_in)

sf_DF_utm <- st_transform(sf_DF, epsg_out)

# Option 1 from above transformed sf object
coords <- data.table(st_coordinates(sf_DF_utm))
raccoon$X <- coords$X
raccoon$Y <- coords$Y

## remove NAs for lat and long 
raccoon <- raccoon[!is.na(raccoon$X),]
raccoon <- raccoon[!is.na(raccoon$Y),]

ggplot(raccoon) +
  geom_point(aes(X, Y)) +
  facet_wrap(~loc_id)

# Sub by bounding box
raccoon <- raccoon[Y > 4800000 &
           Y < 4860000]

## calculate home range area
utm <- 'EPSG:32617'

areaDT <- build_polys(raccoon, 
                      projection = utm, 
                      hrType = 'kernel', 
                      hrParams = list(percent = 95, 
                                      extent = 7,
                                      grid = 400),
                      id = 'id', 
                      coords = c('X', 'Y'), 
                      splitBy = c('yr', 'location', 'loc_id', 'season'))

## convert to data.table
areaDT <- as.data.table(areaDT)

## extract id, yr, loc, and loc_id from "id" factor
areaDT[, c("id", "yr", "location", "loc_id", "season") := tstrsplit(id, "-", fixed=TRUE)][]

## export data
write.csv(areaDT, "output/area.csv")

ggplot(areaDT, aes(season, area/10000)) +
  geom_boxplot() + 
  geom_jitter(aes(color = location)) +
  facet_wrap(~location)

## quick stats
hist(log(areaDT$area/10000))

areaDT[, .N, by = "id"]

model1 <- lmer(log(area/10000) ~ 
                 season * location + 
                 yr + (1|id), data = areaDT)

jtools::summ(model1)

library(emmeans)
## emmeans provides the predicted value of strength for all combinations of tod, cover, and season
emdat <- data.frame(emmeans(model1, ~ 
                              loc_id + 
                              yr))

setnames(emdat, "loc_id", "yr")

## leave out season from the Tukey's test comparison
em <- emmeans(model1, ~ location * season)

## pairwise comparison corrected using Tukey's test
pairs <- pairs(em, adjust = "tukey")

## generate home range overlap list
overlapHR <- group_polys(
                      raccoon,
                      area = TRUE,
                      hrType = 'kernel',
                      hrParams = list(percent = 95, 
                                      extent = 7,
                                      grid = 700),
                      projection = utm,
                      id = 'id_loc_yr_ses',
                      coords = c('X', 'Y'))

## convert area from ha to km2 (/10000) and proportion to %
overlapHR$area <- overlapHR$area/10000
overlapHR$proportion <- overlapHR$proportion/100


overlapHR <- overlapHR[, c("id1", "location", "yr", "season") := tstrsplit(ID1, "-", fixed=TRUE)][]
overlapHR[, c("id2", "x", "y", "z") := tstrsplit(ID2, "-", fixed=TRUE)][][, c("x", "y", "z") := NULL] ## set up dummy variables (x, y, and z) and then delete them immediately

## delete rows where individual is overlapping with themselves 
overlapHR <- overlapHR[ c(id1 != id2)]

## export data
write.csv(overlapHR, "output/overlap.csv")

ggplot(overlapHR) +
  geom_boxplot(aes(location, proportion), notch = T) 
