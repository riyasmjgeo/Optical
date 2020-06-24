# Replacing pixel values in raster

library (raster)

# Bands assignment
ras3 = raster ("LC08_L1TP_140043_20190213_20190222_01_T1_sr_band3.tif")
ras4 = raster ("LC08_L1TP_140043_20190213_20190222_01_T1_sr_band4.tif")

# Replacing pixels in ras4 according to values in ras3
ras4 = replace (ras4, ras3<10, 1)

# Avoid NA values in a raster
ras4 [is.na(ras4)] <- 0