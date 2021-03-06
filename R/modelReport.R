#' Model Report
#'
#' Make a report that shows the main results.
#'
#' @param model \linkS4class{SDMmodel} object.
#' @param folder character. The name of the folder in which to save the output.
#' The folder is created in the working directory.
#' @param test \linkS4class{SWD} object with the test locations, default is
#' `NULL`.
#' @param type character. The output type used for "Maxent" and "Maxnet"
#' methods, possible values are "cloglog" and "logistic", default is
#' \code{NULL}.
#' @param response_curves logical, if `TRUE` it plots the response curves in the
#' html output, default is `FALSE`.
#' @param only_presence logical, if `TRUE` it uses only the range of the
#' presence location for the marginal response, default is `FALSE`.
#' @param jk logical, if `TRUE` it runs the jackknife test, default is `FALSE`.
#' @param env \link[raster]{stack}. If provided it computes and adds a
#' prediction map to the output, default is `NULL`.
#' @param clamp logical for clumping during prediction, used for response curves
#' and for the prediction map, default is `TRUE`.
#' @param permut integer. Number of permutations, default is 10.
#' @param factors list with levels for factor variables,
#' see \link[raster]{predict}
#'
#' @details The function produces a report similar to the one created by MaxEnt
#' software.
#'
#' @export
#'
#' @author Sergio Vignali
#'
#' @examples
#' \donttest{
#' # If you run the following examples with the function example(), you may want
#' # to set the argument ask like following: example("modelReport", ask = FALSE)
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
#' model <- train(method = "Maxnet", data = train, fc = "lq")
#'
#' # Create the report
#' \dontrun{
#' modelReport(model, type = "cloglog", folder = "my_folder", test = test,
#'             response_curves = TRUE, only_presence = TRUE, jk = TRUE,
#'             env = predictors, permut = 2)
#' }
#' }
modelReport <- function(model, folder, test = NULL, type = NULL,
                        response_curves = FALSE, only_presence = FALSE,
                        jk = FALSE, env = NULL, clamp = TRUE, permut = 10,
                        factors = NULL) {

  if (!requireNamespace("kableExtra", quietly = TRUE)) {
    stop("You need the packege \"kableExtra\" to run this function,",
         " please install it.",
         call. = FALSE)
  }

  if (!requireNamespace("cli", quietly = TRUE)) {
    stop("You need the packege \"cli\" to run this function,",
         " please install it.",
         call. = FALSE)
  }

  if (!requireNamespace("crayon", quietly = TRUE)) {
    stop("You need the packege \"crayon\" to run this function,",
         " please install it.",
         call. = FALSE)
  }

  if (!requireNamespace("htmltools", quietly = TRUE)) {
    stop("You need the packege \"htmltools\" to run this function,",
         " please install it.",
         call. = FALSE)
  }

  if (file.exists(file.path(getwd(), folder))) {
    msg <- message(crayon::red(cli::symbol$fancy_question_mark),
                   " The folder '", folder,
                   "' already exists, do you want to overwrite it?")
    continue <- utils::menu(choices = c("Yes", "No"), title = msg)
  } else {
    continue <- 1
  }
  if (continue == 1) {
    template <- system.file("templates", "modelReport.Rmd", package = "SDMtune")

    folder <- file.path(getwd(), folder)
    dir.create(file.path(folder, "plots"), recursive = TRUE,
               showWarnings = FALSE)
    species <- gsub(" ", "_", tolower(model@data@species))
    title <- paste(class(model@model), "model for", model@data@species)
    args <- c(paste0("--metadata=title:\"", title, "\""))
    output_file <- paste0(species, ".html")

    rmarkdown::render(template,
                      output_file = output_file,
                      output_dir = folder,
                      params = list(model = model, type = type, test = test,
                                    folder = folder, env = env, jk = jk,
                                    response_curves = response_curves,
                                    only_presence = only_presence,
                                    clamp = clamp, permut = permut,
                                    factors = factors),
                      output_options = list(pandoc_args = args),
                      quiet = TRUE
                      )
    utils::browseURL(file.path(folder, output_file))
  }
}
