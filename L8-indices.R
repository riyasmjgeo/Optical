library(raster)
######## EDIT THIS PORTION ONLY ############
directory <- "c:/Work/Codes/LC081400432019021301T1-SC20190712023516/"
op_directory <- directory

# "f" for boundary croping, "y" for extent croping, "u" custom from map display or "n" for nothing
crop <- "y"
# Either path to shp file or loaded shp variable
ext2crop <- "c:/Work/Codes/LC081400432019021301T1-SC20190712023516/jcf.shp"

# assign value of 1 to specific the result
ndbi <- ndwi <- pavi <- arvi <- gemi <- gvmi <- msavi <- custom_eqn <- 0
ndvi <- 1
######## EDIT THIS PORTION ONLY ############


# Checking directory
if (length(list.files(directory, pattern = "*TIF", ignore.case = TRUE)) == 0) {
  stop("Define your satellite image folder path properly")
}
files <- list.files(directory)

# Reading band-1 for pattern recognition
b1 <- select.list(files, title = "CHOOSE BAND-1", graphics = TRUE)
b1_len <- nchar(b1)
b1_head <- substring(b1, 1, (b1_len - 5))
b1_tail <- substring(b1, (b1_len - 3), b1_len)

# Reading other bands
for (i in 2:7)
{
  i <- gettext(i)
  assign(paste0("b", i), paste0(b1_head, i, b1_tail))
}

# Read meta-data
mtl <- list.files(directory, pattern = "_MTL.txt", ignore.case = TRUE)
if (length(mtl) != 1) {
  mtl <- select.list(files, title = "CHOOSE MTL file", graphics = TRUE)
}
meta_data <- readLines(paste0(directory, mtl))
rm(i, mtl, b1_len, files)

# Defining the crop extent
if (crop != "n" && crop != "y" && crop != "u" && crop != "f") {
  stop("Define argument 'crop' properly. Use either n, y, f or u in double quotes. Type ?arvi in console to read more about the function")
}
if (crop != "n" && ext2crop == "none") {
  if (crop != "u") {
    stop("Define argument 'ext2crop' properly if croppping is required, otherwise choose argument 'crop' as n in double quotes")
  }
}
if (crop == "y" || crop == "f") {
  if (typeof(ext2crop) == "character") {
    shape <- raster::shapefile(ext2crop)
    ext <- raster::extent(shape)
  }
  if (typeof(ext2crop) == "S4") {
    ext <- raster::extent(ext2crop)
    shape <- ext2crop
  }
}

# Defining folders and metadata properly
if (endsWith(op_directory, "/")) {
  op_directory <- stringr::str_sub(op_directory, start = 1L, end = -2L)
}
if (endsWith(directory, "/")) {
  directory <- stringr::str_sub(directory, start = 1L, end = -2L)
}

######### Landsat 8 starting###############
if (crop == "u") {
  b5 <- raster(paste0(directory, "/", b5))
  b4 <- raster(paste0(directory, "/", b4))
  b3 <- raster(paste0(directory, "/", b3))
  stak <- raster::stack(c(b5, b4, b3))
  plotRGB(stak, scale = 65536)
  print("Please define your extent from the map in plot preview for further processing")
  print("You can click on the top left of custom subset region followed by the bottom right")
  ext <- drawExtent()
}

# Extracting parameters from meta-data
## Getting line numbers of two expected consicutive parameters
b7_ref_add <- grep("REFLECTANCE_ADD_BAND_7", meta_data)
b6_ref_add <- grep("REFLECTANCE_ADD_BAND_6", meta_data)

b7_ref_mult <- grep("REFLECTANCE_MULT_BAND_7", meta_data)
b6_ref_mult <- grep("REFLECTANCE_MULT_BAND_6", meta_data)

# Acquiring parameters if the order is continuous
if ((b7_ref_add - b6_ref_add) == 1 && (b7_ref_mult - b6_ref_mult) == 1) {
  j <- 0
  for (i in 7:1)
  {
    i <- gettext(i)
    line_splited <- strsplit(meta_data[b7_ref_add - j], "=")
    line_splited <- line_splited[[1]]
    assign(paste0("b", i, "_refl_add"), as.double(line_splited[2]))

    line_splited <- strsplit(meta_data[b7_ref_mult - j], "=")
    line_splited <- line_splited[[1]]
    i <- gettext(i)
    assign(paste0("b", i, "_refl_mult"), as.double(line_splited[2]))
    j <- j + 1
    rm(line_splited)
  }
  rm(b7_ref_add, b6_ref_add, b7_ref_mult, b6_ref_mult, i, j)
}

# Extracting date of acquisition and avoid blank space
data_aq <- grep("DATE_ACQUIRED", meta_data)
line_splited <- strsplit(meta_data[data_aq], " = ")
line_splited <- line_splited[[1]]
data_aq <- as.character(line_splited[2])
if (startsWith(data_aq, " ")) {
  data_aq <- substring(data_aq, 2, 11)
}
# Extracting sun-elevation
sun_ele <- grep("SUN_ELEVATION", meta_data)
line_splited <- strsplit(meta_data[sun_ele], " = ")
line_splited <- line_splited[[1]]
sun_ele <- as.double(line_splited[2])

rm(line_splited, meta_data)
# Actual band assignment and band maths
for (i in 1:7)
{
  i <- gettext(i)
  refl_add <- eval(parse(text = paste0("b", i, "_refl_add")))
  refl_mult <- eval(parse(text = paste0("b", i, "_refl_mult")))

  # raster croping, coversion to TOA
  if (crop == "y" || crop == "f" || crop == "u") {
    ras <- raster(paste0(directory, "/", b1_head, i, b1_tail))
    ras <- crop(ras, ext)
    if (crop == "f") {
      ras <- mask(ras, shape)
    }
    ras <- ((ras * refl_mult) + refl_add) / sin(sun_ele * (pi / 180))
    assign(paste0("b", i, "_toa"), ras)
    rm(ras)
  }
  else {
    ras <- paste0(directory, "/", b1_head, i, b1_tail)
    ras <- ((ras * refl_mult) + refl_add) / sin(sun_ele * (pi / 180))
    assign(paste0("b", i, "_toa"), raster(ras))
  }
}
rm(
  b1, b2, b3, b4, b5, b6, b7, ext2crop, b1_head, b1_tail, i, refl_add, refl_mult,
  b1_refl_add, b1_refl_mult, b2_refl_add, b2_refl_mult, b3_refl_add, b3_refl_mult,
  b4_refl_add, b4_refl_mult, b5_refl_add, b5_refl_mult, b6_refl_add, b6_refl_mult,
  b7_refl_add, b7_refl_mult, ext, shape, sun_ele
)
# Binding alias to TOA bands
makeActiveBinding("swir2", function() b7_toa, .GlobalEnv)
makeActiveBinding("swir1", function() b6_toa, .GlobalEnv)
makeActiveBinding("nir", function() b5_toa, .GlobalEnv)
makeActiveBinding("red", function() b4_toa, .GlobalEnv)
makeActiveBinding("green", function() b3_toa, .GlobalEnv)
makeActiveBinding("blue", function() b2_toa, .GlobalEnv)
makeActiveBinding("aero", function() b1_toa, .GlobalEnv)

# Computing required indices and exporting as tif file to op_directory
if (ndvi == 1) {
  ndvi <- (nir - red) / (nir + red)
  ndvi <- replace(ndvi, ndvi < -1, NA)
  ndvi <- replace(ndvi, ndvi > 1, NA)
  writeRaster(ndvi, paste0(op_directory, "/", "ndvi_", data_aq), format = "GTiff", overwrite = TRUE)
}

if (ndbi == 1) {
  ndbi <- (swir1 - nir) / (swir1 + nir)
  ndbi <- replace(ndbi, ndbi < -1, NA)
  ndbi <- replace(ndbi, ndbi > 1, NA)
  writeRaster(ndbi, paste0(op_directory, "/", "ndbi_", data_aq), format = "GTiff", overwrite = TRUE)
}

if (ndwi == 1) {
  ndwi <- (green - nir) / (nir + green)
  ndwi <- replace(ndwi, ndwi < -1, NA)
  ndwi <- replace(ndwi, ndwi > 1, NA)
  writeRaster(ndwi, paste0(op_directory, "/", "ndwi_", data_aq), format = "GTiff", overwrite = TRUE)
}

if (pavi == 1) {
  pavi <- ((nir^2) - (red^2)) / ((nir^2) + (red^2))
  writeRaster(pavi, paste0(op_directory, "/", "pavi_", data_aq), format = "GTiff", overwrite = TRUE)
}

if (arvi == 1) {
  gamma <- 1
  rb <- red - (gamma * (blu - red))
  arvi <- (nir - rb) / (nir + rb)
  writeRaster(arvi, paste0(op_directory, "/", "arvi_", data_aq), format = "GTiff", overwrite = TRUE)
  print("Please refer http://ieeexplore.ieee.org/document/134076/?arnumber=134076&tag=1  ")
  print("to see the value of Gamma. By default it is considered as 1.")
}

if (gemi == 1) {
  gem_c1 <- (2 * ((nir^2) - (red^2)) + (1.5 * nir) + (0.5 * red)) / (nir + red + 0.5)
  gemi <- gem_c1 * (1 - (0.25 * gem_c1)) - ((red - 0.125) / (1 - red))
  writeRaster(gemi, paste0(op_directory, "/", "gemi_", data_aq), format = "GTiff", overwrite = TRUE)
}

if (gvmi == 1) {
  gvmi <- ((nir + 0.1) - (swir2 + 0.02)) / ((nir + 0.1) + (swir2 + 0.02))
  writeRaster(gvmi, paste0(op_directory, "/", "gvmi_", data_aq), format = "GTiff", overwrite = TRUE)
}

if (msavi == 1) {
  msavi_c1 <- (2 * nir) + 1
  msavi_c2 <- ((2 * nir) + 1)^2
  msavi_c3 <- (msavi_c2 - (8 * (nir - red)))^0.5
  msavi <- (msavi_c1 - msavi_c3) / 2
  writeRaster(msavi, paste0(op_directory, "/", "msavi_", data_aq), format = "GTiff", overwrite = TRUE)
}

if (custom_eqn == 1) {
  cus.formula <- nir^2 / (swir2 - swir1)
  cus_eqn <- eval(parse(text = cus.formula))
  writeRaster(cus_eqn, paste0(op_directory, "/", "cus-eqn_", data_aq), format = "GTiff", overwrite = TRUE)
}