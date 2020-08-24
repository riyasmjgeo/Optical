# Convert raster to vector
# Assign breakpoints
# Apply mask
# Avoid pixels having NA values in other raster
library(raster)
library(rgdal)
b1 = raster("C:/Mega/Work_files/Results/SBAS/K-means/Vert_corr17_18.tif")
b2 = raster("C:/Mega/Work_files/Results/SBAS/K-means/Vert_corr18_19.tif")
b3 = raster("C:/Mega/Work_files/Results/SBAS/K-means/Vert_corr19_20.tif")
shp = shapefile("C:/Mega/Work_files/Results/SBAS/Decompose/Verti_30mm.shp")

#masking
b1 [is.na(b2)] <- NA
b1 [is.na(b3)] <- NA
b2 [is.na(b1)] <- NA
b2 [is.na(b3)] <- NA
b3 [is.na(b1)] <- NA
b3 [is.na(b2)] <- NA

ras = b3             ## Edit here ###
ras = mask(ras,shp)
# assigning Break points
ras = replace(ras,ras< -50, 201)
ras = replace(ras,ras< -35, 202)
ras = replace(ras,ras< -20, 203)
ras = replace(ras,ras< -10, 204)
ras = replace(ras,ras< 0, 205)
ras = replace(ras,ras< 200, 206)

# Coversion to polygon and exporting 
polygn = rasterToPolygons(ras, fun= NULL ,na.rm = TRUE, dissolve = TRUE)
#polygn = rasterToPolygons(ras, fun = function(x){x==1} ,na.rm = TRUE, dissolve = TRUE)
setwd("C:/Mega/Work_files/Results/SBAS/K-means/classified/")
writeOGR(polygn, dsn = '.', layer = 'V19_20_classif', driver = "ESRI Shapefile")