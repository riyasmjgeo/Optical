### LULC classification ###
library("raster")  
library("cluster")

# bands stack
b1 = raster::raster ("LC08_L1TP_140043_20190213_20190222_01_T1_sr_band1.tif")
b2 = raster::raster ("LC08_L1TP_140043_20190213_20190222_01_T1_sr_band2.tif")
b3 = raster::raster ("LC08_L1TP_140043_20190213_20190222_01_T1_sr_band3.tif")

stacked = raster::stacked(c(b1, b2, b3)) 
rm (b1, b2, b3)

# Avoiding NA values
v = getValues(stacked)
i = which(!is.na(v))
v = na.omit(v)

# K-means classification
# There are many algorithms than currect. Check it out
E = kmeans(v, 7, iter.max = 200, nstart = 12, algorithm = "MacQueen")
kmeans_raster = raster(stacked)
kmeans_raster[i] = E$cluster
writeRaster(kmeans_raster, "kmeans_lulc_7", format = "GTiff", overwrite = TRUE)

# clara classification 
clus = clara(v, 18, samples=500, metric="manhattan", pamLike=T)
clara_raster = raster(stak_crop)
clara_raster[i] = clus$clustering
writeRaster(clara_raster, "clara_lulc_18", format = "GTiff", overwrite = TRUE)
