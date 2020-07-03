# Convert raster to vector
# Assign breakpoints
# Apply mask
library(raster)
library(rgdal)

ras = raster("C:/Mega/Work_files/Results/SBAS/K-means/Vert_corr19_20.tif")
shp = shapefile("C:/Mega/Work_files/Results/SBAS/Decompose/Verti_30mm.shp")

#masking
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