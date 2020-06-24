# Code to split a layer stack to seperate bands
library(raster)

# Path of band stack
ras_path = "C:/Users/riyas/Desktop/Work/Polarimetry/try_s2a/s2a_all_bands.tif"

ras = raster(ras_path)
# setwd()
for( i in 1:ras@file@nbands){
  ras_temp = raster(ras_path, band = i)
  writeRaster(ras_temp, paste0("band_", i), format = "GTiff", overwrite = TRUE)
}