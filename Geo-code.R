# Geo-coding SBAS composite image
library(raster)

directory = "/home/riyas/Data/Work_files/SBAS_delete/Ascending/"
comb = raster(paste0(directory,"/Composite.tif"))

# Need to identify checking the first and last values
xmin = 86.099822998046875
xmax = 86.49986267089843750

ymin = 23.50006866455078125
ymax = 23.89984703063964844

# Project
extent(comb) <- c(xmin, xmax, ymin, ymax)
projection(comb) <- CRS("+proj=longlat +datum=WGS84")
# comb<-replace (comb, comb==0, NA)

# Export
writeRaster(comb,paste0(directory,"/ascending"),format="GTiff",overwrite=TRUE)
