# Raster layer to matrix and then to SpatialGrid or Pixels
library(raster)
r <- raster(matrix(runif(20),5,4))
r[r>.5] <- NA
g <- as(r, 'SpatialGridDataFrame')
p <- as(r, 'SpatialPixels')

plot(r)
points(p)