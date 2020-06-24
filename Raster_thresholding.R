## IP = FOLDER CONTAINING TIR BAND CONVERTED BRIGHTNESS TEMP (temp_tir1_l8.tif). 
## REQUIREMENT = DEFINE A THRESHOLD VALUE ANALYSING THE HISTOGRAM 
## OP a) 3 BINARY COAL FIRE MAP BASED THE THRESHOLD, THRESH. +1 AND THRESH -1. 
## OP b) DN COAL FIRE MAP BASED ON THRESHOLD

#### Variables ####
library(raster)
library(rgdal)
dir = "C:/Work/2017/LC08_L1TP_140043_20171224_20180103_01_T1/"
date = substring(dir, 31,38)
setwd(dir)
ras = raster(paste0(dir,"temp_tir1_l8.tif"))
ras [ras==0] = NA
hist(ras, nclass=200)                   #histogram- define number of bins

# Thresholding by threshold value
thrsh = 26                        #modify
ras_thrsh = ras
ras_thrsh [ras_thrsh<thrsh]= NA
ras_thrsh [ras_thrsh>thrsh]= 1
writeRaster(ras_thrsh, paste0(dir, date,"_",thrsh), format = "GTiff", overwrite = TRUE)

# Thresholding by value 'threshold+1'
ras_more = ras
lim = thrsh+1
ras_more [ras_more<(thrsh+1)]= NA
ras_more [ras_more>(thrsh+1)]= 1
writeRaster(ras_more, paste0(dir, date, "_",lim), format = "GTiff", overwrite = TRUE)

# Thresholding by value 'threshold -1'
ras_less = ras
lim = thrsh-1
ras_less [ras_less<(thrsh-1)]= NA
ras_less [ras_less>(thrsh-1)]= 1
writeRaster(ras_less, paste0(dir, date, "_",lim), format = "GTiff", overwrite = TRUE)

# Thresholding with threshold value and keep the real DN value for pixels
ras = replace(ras, ras<thrsh, NA)
writeRaster(ras, paste0(dir, date,"_dn_",thrsh), format = "GTiff", overwrite = TRUE)
