# Convert DN to percent of reflected energy.
# DN to reflection should be done prior to this and use those bands as input.

library(raster)
# Assign the folder contains the bands.
bands = list.files("C:/Users/riyas/Desktop/Work/Polarimetry/robins_lulc/Original/", pattern = "*TIF", ignore.case = TRUE)
setwd("C:/Users/riyas/Desktop/Work/Polarimetry/robins_lulc/Original/")
tot = 0
stak = c()

# Make stack from bands
for (i in bands)
{
  band_temp = raster(i)
  tot = tot + band_temp
  stak = append(stak, band_temp)
}

setwd("C:/Users/riyas/Desktop/Work/Polarimetry/robins_lulc/Perc_bands/")

# Finding the percentage of each band
for (j in 1:length(bands))
{
  band_temp = stak[[j]]
  band_perc = (band_temp/tot)*100
  
  var1 = bands[j]
  var1 = strsplit(var1, "_")[[1]]
  var1 = var1[2]
  band_num = strsplit(var1, ".tif")[[1]]
  assign(paste0("b",band_num), band_perc)
  #writeRaster(band_perc, paste0("b",band_num), format = "GTiff", overwrite = TRUE)
}

rm (tot,band_temp, band_perc)

# K-Means classification
stacked = raster::stack(b01,b02,b03,b04,b05,b06,b07,b08,b09,b10,b11,b12)
v = getValues(stacked)
i = which(!is.na(v))
v = na.omit(v)
E = kmeans(v, 7, iter.max = 200, nstart = 12, algorithm = "MacQueen")
kmeans_raster = raster(stacked)
kmeans_raster[i] = E$cluster
writeRaster(kmeans_raster, "kmeans_lulc_7", format = "GTiff", overwrite = TRUE)
