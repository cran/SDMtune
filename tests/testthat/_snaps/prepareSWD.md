# The function warns if some locations are discarded

    ! 1 location is NA for some environmental variables and has been discarded

---

    ! 2 locations are NA for some environmental variables and have been discarded

# The function raises errors

    ! `env` must be a <SpatRaster> object
    x You have supplied a <character> instead.

# The function raises an error if a raster object is used

    ! Objects from the raster package are no longer supported!
    i SDMtune now uses terra to handle spatial data. See function `terra::rast()` to migrate.

