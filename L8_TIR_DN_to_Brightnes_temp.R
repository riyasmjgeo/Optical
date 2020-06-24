#*#*#*#* Function to read Landsat-8 TIR bands, subset the images and 
#*#*#*#* convert TIR bands DN to brightness temperature and save it as TIF files

##### VARIABLES- Edit the variables #####
## 1) Path to the folder containing Landsat-8 bands and metadata.
directory= "D:/TIR_2019-20/LC08_L1TP_140043_20191112_20191115_01_T1" 

## 2) Path to the directoy where output files will be saved.
# By default, it takes the input directory as output directory
# Remove "/" if it is the last character of the defined output path 
op_directory = directory

## 3) Define the path of *.shp file for subsetting 
# Assign shape = "define" for creating custom region of interest from a map
library(raster)
shape = shapefile("D:/TIR_2019-20/jcf.shp") 
##### VARIABLES- No need to edit anything below #####

bands <- length(list.files(directory,pattern = "*TIF"))
if (bands == 0)
  stop("Define your satellite image folder path properly")

# Finding out which satellite sensor data & name of satellite image data
files <- list.files(directory)

for (i in 1:length(files))
{
  file <- files[i]
  broke_name <- strsplit(file, "_B1.TI")
  broke_name <- broke_name[[1]]
  if (utils::tail(broke_name,1) == "F")
  {
    sat_fold <- broke_name[1]
    break()
  }
}

# Defining the crop extent
ext <- raster::extent (shape)

# Reading metadata
meta_data <- readLines(paste0(directory,"/",sat_fold,"_MTL.txt"))
count_i <- length(meta_data)
if (count_i==0){print("ERROR: MTL file not found")}
op_name <- list()
op_bands <- list()
j <-0

######### Landsat 8 starting###############
# Extracting values from meta data
for (i in 1:count_i)
{
  line <- meta_data[i]
  line_splited <- strsplit(line," ")
  words <- line_splited[[1]]
  counts <- length(words)
  for (j in 1:counts)
  {
    if (words[j]=="RADIANCE_MULT_BAND_10"){ tir1_rad_mult <- as.double(words[j+2])}
    if (words[j]=="RADIANCE_ADD_BAND_10"){ tir1_rad_add <- as.double(words[j+2])}
    if (words[j]=="RADIANCE_MULT_BAND_11"){ tir2_rad_mult <- as.double(words[j+2])}
    if (words[j]=="RADIANCE_ADD_BAND_11"){ tir2_rad_add <- as.double(words[j+2])}
    if (words[j]=="K1_CONSTANT_BAND_10"){ tir1_k1 <- as.double(words[j+2])}
    if (words[j]=="K2_CONSTANT_BAND_10"){ tir1_k2 <- as.double(words[j+2])}
    if (words[j]=="K1_CONSTANT_BAND_11"){ tir2_k1 <- as.double(words[j+2])}
    if (words[j]=="K2_CONSTANT_BAND_11"){ tir2_k2 <- as.double(words[j+2])}
    if (words[j]=="DATE_ACQUIRED"){ data_aq <- as.character(words[j+2])}
    if (words[j]=="SUN_ELEVATION"){ sun_ele <- as.double(words[j+2])}
  }
}

# Making a map for user to define crop extent
if (typeof(shape) == "character")
{
  b5 <- raster (files[8])
  b4 <- raster (files[7])
  b3 <- raster (files[6])
  stak <- raster::stack(c(b5,b4,b3))
  plotRGB(stak, scale = 65536)
  print("Please define your extent from the map in plot preview for further processing")
  print("You can click on the top left of custom subset region followed by the bottom right")
  ext <- drawExtent()
}

# Defining bands & toa calculation
tir1 <- as.integer(raster(paste0(directory,"/",sat_fold,"_B10.TIF")))
tir1 <- crop(tir1, ext)
#tir1 <- mask(tir1,shape)
tir1 <- replace(tir1, tir1==0, NA)


rad_tir1 <- (tir1 * tir1_rad_mult) + tir1_rad_add
temp_tir1 <- tir1_k2/ log((tir1_k1/rad_tir1)+1)
temp_tir1 <- temp_tir1-273.15
op_name [[1]] <- "First raster is TIR band 1"
op_bands [[1]] <- temp_tir1
writeRaster(temp_tir1,paste0(op_directory,"/","temp_tir1"),format="GTiff",overwrite=TRUE)

tir2 <- as.integer(raster(paste0(directory,"/",sat_fold,"_B11.TIF")))
tir2 <- crop(tir2, ext)
#tir2 <- mask(tir2,shape)
tir2 <- replace(tir2, tir2==0, NA)

rad_tir2 <- (tir2 * tir2_rad_mult) + tir2_rad_add
temp_tir2 <- tir2_k2/ log((tir2_k1/rad_tir2)+1)
temp_tir2 <- temp_tir2-273.15
op_name [[2]] <- "Second raster is TIR band 2"
op_bands [[2]] <- temp_tir2
writeRaster(temp_tir2,paste0(op_directory,"/","temp_tir2"),format="GTiff",overwrite=TRUE)
