# Make a polygon covering pixels having a value less than -30

library(raster)
library(rgdal)

ras = raster("C:/Mega/Work_files/Results/SBAS/Decompose/vert_corected.tif")
ras = replace(ras, ras > -30, NA)
ras = replace(ras, ras < 0, 1)
plot(ras)

# Normal raster to polygon
#polygn = rasterToPolygons(ras, fun= NULL ,na.rm = TRUE, dissolve = TRUE)
# For converting pixels with specific value (in this case 1)
polygn = rasterToPolygons(ras, fun = function(x){x==1} ,na.rm = TRUE, dissolve = TRUE)
# OR maybe
#polygn = rasterToPolygons (ras)

# Exporting shapefile
setwd("C:/Mega/Work_files/Results/SBAS/Decompose/")
writeOGR(polygn, dsn = '.', layer = 'Vert_cor_30mm', driver = "ESRI Shapefile")
