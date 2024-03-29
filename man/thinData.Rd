% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/thinData.R
\name{thinData}
\alias{thinData}
\title{Thin Data}
\usage{
thinData(coords, env, x = "x", y = "y", verbose = TRUE, progress = TRUE)
}
\arguments{
\item{coords}{data.frame or matrix with the coordinates, see details.}

\item{env}{\link[terra]{rast} containing the environmental variables.}

\item{x}{character. Name of the column containing the x coordinates.}

\item{y}{character. Name of the column containing the y coordinates.}

\item{verbose}{logical, if \code{TRUE} prints an informative message.}

\item{progress}{logical, if \code{TRUE} shows a progress bar.}
}
\value{
a matrix or a data frame with the thinned locations.
}
\description{
Remove all but one location per raster cell. The function removes NAs and if
more than one location falls within the same raster cell it selects randomly
one.
}
\details{
\itemize{
\item \strong{coords} and \strong{env} must have the same coordinate reference
system.
\item The \code{coords} argument can contain several columns. This is useful if the
user has information related to the coordinates that doesn't want to loose
with the thinning procedure. The function expects to have the x coordinates
in a column named "x", and the y coordinates in a column named "y". If this
is not the case, the name of the columns containing the coordinates can be
specified using the arguments \code{x} and \code{y}.
}
}
\examples{
\donttest{# Acquire environmental variables
files <- list.files(path = file.path(system.file(package = "dismo"), "ex"),
                    pattern = "grd",
                    full.names = TRUE)

predictors <- terra::rast(files)

# Prepare background locations, by sampling  also on areas with NA values
bg_coords <- terra::spatSample(predictors,
                               size = 9000,
                               method = "random",
                               xy = TRUE,
                               values = FALSE)
nrow(bg_coords)

# Thin the locations
# The function will remove the coordinates that have NA values for some
# predictors. Note that the function expects to have the coordinates in two
# columns named "x" and "y"

colnames(bg_coords)
thinned_bg <- thinData(bg_coords,
                       env = predictors)
nrow(thinned_bg)

# Here we sample only on areas without NA values and then we double the
# coordinates
bg_coords <- terra::spatSample(predictors,
                               size = 9000,
                               method = "random",
                               na.rm = TRUE,
                               xy = TRUE,
                               values = FALSE)

thinned_bg <- thinData(rbind(bg_coords, bg_coords),
                       env = predictors)

nrow(thinned_bg)

# In case of a dataframe containing more than two columns (e.g. a dataframe
# with the coordinates plus an additional column with the age of the species)
# and custom column names, use the function in this way
age <- sample(c(1, 2),
              size = nrow(bg_coords),
              replace = TRUE)

data <- cbind(age, bg_coords)
colnames(data) <- c("age", "X", "Y")

thinned_bg <- thinData(data,
                       env = predictors,
                       x = "X",
                       y = "Y")
head(data)}
}
\author{
Sergio Vignali
}
