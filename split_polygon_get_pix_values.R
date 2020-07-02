# This splits SHP to single polygons, extracts pixel covering each polygon 
# and make a plot pixel values while discriminating polygon-wise

library(raster); library(ggplot2)

# Shp file, unique attribute column in shp file, and the raster file,  
clip_featr = shapefile("C:/Mega/Work_files/Results/SBAS/Validation/stable_area.shp")
uniq_shp_column = clip_featr$Name
base_ras = raster("C:/Mega/Work_files/Results/SBAS/Decompose/vertical.tif")

# variables
k = 0
dn = pixels = polyid = c()

# looping through each polygon shapes in the shapefile
for (i in uniq_shp_column){
  temp_poly = clip_featr[clip_featr@data$Name == i,]  #### Need to edit: @data defines the actual data with a name 
  temp_ext = extent(temp_poly)
  temp_ras = crop(base_ras, temp_ext)
  temp_ras = mask(temp_ras, temp_poly)
  temp_ras = as.matrix(temp_ras)
  temp_ras = as.list(temp_ras)
  ras_values = c()
  
  # Avoiding NA values in the raster pixels and appending them to a variable defined b4 this loop
  non_na_values = 0
  for (j in 1:length(temp_ras)){
    if (is.na(temp_ras[j]) == FALSE){
      non_na_values = non_na_values+1
      dn = append(dn, temp_ras[j][[1]])
    } 
  }
  
  # Assigning category value (from the unique shp column) to every pixel
  # Creates a temporary variable and append that to the list defined before loop
  if (non_na_values > 0){
    polyid_temp = list(1:non_na_values)[[1]]
    polyid_temp [1:non_na_values] = i
    polyid = append(polyid, polyid_temp)
  }
}

# X-axis: Simply the number of pixels to plot
pixels = list(1:length(dn))[[1]]

# Making a data frame with of the values derived and plotting
df = data.frame(pixels=pixels, dn=dn, categories = polyid)
#head(df)

# Plotting
ggplot(df, aes(x=pixels, y=dn, group=categories)) + geom_point(aes(color=categories, shape=categories))+
  scale_shape_manual(values=list(1:length(uniq_shp_column))[[1]])+
  scale_color_manual(values=c('black','red', 'blue', 'green','black', 'darkorchid1', 'grey'))