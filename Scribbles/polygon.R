# Polygon 
library (raster)

ras = raster::raster ("raster_xxx.tif")

# Normal raster to polygon
polygn = rasterToPolygons(ras, fun= NULL ,na.rm = TRUE, dissolve = TRUE)
# For converting pixels with specific value (in this case 1)
polygn = rasterToPolygons(ras, fun = function(x){x==1} ,na.rm = TRUE, dissolve = TRUE)
# OR maybe
polygn = rasterToPolygons (ras)

# Exporting shapefile
library(rgdal)
writeOGR(polygn, dsn = '.', layer = 'polygon_name', driver = "ESRI Shapefile")
