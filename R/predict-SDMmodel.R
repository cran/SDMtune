setGeneric("predict", function(object, ...)
  standardGeneric("predict")
)

#' Predict
#'
#' Predict the output for a new dataset given a trained \code{\link{SDMmodel}}
#' model.
#'
#' @param object \code{\linkS4class{SDMmodel}} object.
#' @param data data.frame, \code{\linkS4class{SWD}} or raster
#' \code{\link[raster]{stack}} with the data for the prediction.
#' @param type character. Output type, see details, used only for **Maxent** and
#' **Maxnet** methods, default is \code{NULL}.
#' @param clamp logical for clumping during prediction, used only for **Maxent**
#' and **Maxnet** methods, default is \code{TRUE}.
#' @param filename character. Output file name for the prediction map, if
#' provided the output is saved in a file.
#' @param format character. The output format, see
#' \code{\link[raster]{writeRaster}} for all the options, default is "GTiff".
#' @param extent \code{\link[raster]{Extent}} object, if provided it restricts
#' the prediction to the given extent, default is \code{NULL}.
#' @param parallel logical to use parallel computation during prediction,
#' default is \code{FALSE}.
#' @param progress character to display a progress bar: "text", "window" or ""
#' (default) for no progress bar.
#' @param ... Additional arguments to pass to the
#' \code{\link[raster]{writeRaster}} function.
#'
#' @details
#' * For models trained with the **Maxent** method the argument \code{type} can
#' be: "raw", "logistic" and "cloglog".
#' * For models trained with the **Maxnet** method the argument \code{type} can
#' be: "link", "exponential", "logistic" and "cloglog", see
#' \code{\link[maxnet]{maxnet}} for more details.
#' * For models trained with the **ANN** method the function uses the "raw"
#' output type.
#' * For models trained with the **RF** method the output is the probability of
#' class 1.
#' * For models trained with the **BRT** method the function uses the number of
#' trees defined to train the model and the "response" output type.
#' * Parallel computation increases the speed only for large datasets due to the
#' time necessary to create the cluster. For **Maxent** models the function
#' performs the prediction in **R** without calling the **MaxEnt** Java
#' software. This results in a faster computation for large datasets and might
#' result in slightly different results compare to the Java software.
#'
#' @include Maxent-class.R Maxnet-class.R ANN-class.R RF-class.R BRT-class.R
#' @import methods
#' @importFrom raster beginCluster clusterR endCluster predict clamp subset
#' @importFrom stats formula model.matrix
#'
#' @return A vector with the prediction or a Raster object if data is a raster
#' \code{\link[raster]{stack}}.
#' @exportMethod predict
#'
#' @author Sergio Vignali
#'
#' @references Wilson P.D., (2009). Guidelines for computing MaxEnt model output
#' values from a lambdas file.
#'
#' @examples
#' # Acquire environmental variables
#' files <- list.files(path = file.path(system.file(package = "dismo"), "ex"),
#'                     pattern = "grd", full.names = TRUE)
#' predictors <- raster::stack(files)
#'
#' # Prepare presence and background locations
#' p_coords <- virtualSp$presence
#' bg_coords <- virtualSp$background
#'
#' # Create SWD object
#' data <- prepareSWD(species = "Virtual species", p = p_coords, a = bg_coords,
#'                    env = predictors, categorical = "biome")
#'
#' # Split presence locations in training (80%) and testing (20%) datasets
#' datasets <- trainValTest(data, test = 0.2, only_presence = TRUE)
#' train <- datasets[[1]]
#' test <- datasets[[2]]
#'
#' # Train a model
#' model <- train(method = "Maxnet", data = train, fc = "l")
#'
#' # Make cloglog prediction for the test dataset
#' predict(model, data = test, type = "cloglog")
#'
#' # Make logistic prediction for the all study area
#' predict(model, data = predictors, type = "logistic")
#'
#' \donttest{
#' # Make logistic prediction for the all study area and save it in a file
#' predict(model, data = predictors, type = "logistic", filename = "my_map")
#' }
setMethod("predict",
          signature = "SDMmodel",
          definition = function(object, data, type = NULL, clamp = TRUE,
                                filename = "", format = "GTiff", extent = NULL,
                                parallel = FALSE, progress = "", ...) {

            if (class(object@model) != "Maxnet") {
              model <- object@model
            } else {
              model <- object@model@model
            }

            vars <- colnames(object@data@data)

            if (inherits(data, "Raster")) {
              data <- raster::subset(data, vars)
              if (parallel) {
                suppressMessages(raster::beginCluster())
                pred <- raster::clusterR(data,
                                         predict,
                                         args = list(model = model,
                                                     clamp = clamp,
                                                     type = type,
                                                     fun = predict),
                                         progress = progress,
                                         filename = filename,
                                         format = format,
                                         ext = extent,
                                         ...)
                raster::endCluster()
              } else {
                pred <- raster::predict(data, model = model,
                                        type = type,
                                        clamp = clamp,
                                        fun = predict,
                                        progress = progress,
                                        filename = filename,
                                        format = format,
                                        ext = extent,
                                        ...)
              }
            } else if (inherits(data, "SWD")) {
              data <- data@data[vars]
              pred <- predict(model, data, type = type, clamp = clamp)
              pred <- as.vector(pred)
            } else if (inherits(data, "data.frame")) {
              data <- data[vars]
              pred <- predict(model, data, type = type, clamp = clamp)
              pred <- as.vector(pred)
            }

            return(pred)
          })