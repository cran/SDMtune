skip_on_cran()

data <- SDMtune:::t
model <- SDMtune:::bm_maxnet
model_mx <- SDMtune:::bm_maxent
model_cv <- SDMtune:::bm_maxnet_cv
model_ann <- train("ANN", data = data, size = 10)
model_rf <- train("RF", data = data)
model_brt <- train("BRT", data = data)
h <- list(fc = c("l", "lq", "lqp"), reg = seq(.2, 2., .2))

test_that(".get_presence", {
  expect_s3_class(.get_presence(data), "data.frame")
})

test_that(".get_absence", {
  expect_s3_class(.get_absence(data), "data.frame")
})

test_that(".subset_swd", {
  expect_s4_class(swd <- .subset_swd(data, fold = as.logical(data@pa)), "SWD")
  expect_true(unique(swd@pa) == 1)
})

test_that(".get_model_class", {
  expect_equal(.get_model_class(model), "Maxnet", ignore_attr = TRUE)
  expect_equal(.get_model_class(model_cv), "Maxnet", ignore_attr = TRUE)
})

test_that(".get_model_reg", {
  expect_equal(.get_model_reg(model), 1)
  expect_equal(.get_model_reg(model_cv), 1)
})

test_that(".get_model_fc", {
  expect_equal(.get_model_fc(model), "lqph")
  expect_equal(.get_model_fc(model_cv), "lqph")
})

test_that(".get_footer", {
  expect_equal(.get_footer(model), "fc: lqph\nreg: 1")
  expect_equal(.get_footer(model_cv), "fc: lqph\nreg: 1")
  expect_equal(.get_footer(model_mx), "fc: lqph\nreg: 1\niter: 500")
  expect_equal(.get_footer(model_ann),
               "size: 10\ndecay: 0\nrang: 0.7\nmaxit: 100")
  expect_equal(.get_footer(model_rf), "mtry: 3\nntree: 500\nnodesize: 1")
  expect_equal(.get_footer(model_brt),
               paste0("distribution: bernoulli\nn.trees: 100\n",
                      "interaction.depth: 1\nshrinkage: 0.1\nbag.fraction: 0.5"))
})

test_that(".get_total_model", {
  expect_equal(.get_total_models(20, 12, 5), 80)
})

test_that(".get_metric_label", {
  expect_equal(.get_metric_label("auc"), "AUC")
  expect_equal(.get_metric_label("tss"), "TSS")
  expect_equal(.get_metric_label("aicc"), "AICc")
})

test_that(".get_sdmtune_colnames", {
  expect_equal(.get_sdmtune_colnames("auc"),
               c("train_AUC", "test_AUC", "diff_AUC"))
  expect_equal(.get_sdmtune_colnames("tss"),
               c("train_TSS", "test_TSS", "diff_TSS"))
  expect_equal(.get_sdmtune_colnames("aicc"), c("AICc", "delta_AICc"))
})

test_that(".create_sdmtune_result", {
  # Produce the correct result with auc
  expect_equal(.create_sdmtune_result(model, metric = "auc", train_metric = 0.9,
                                      val_metric = 0.8),
               list(fc = "lqph", reg = 1, train_AUC = 0.9, test_AUC = 0.8,
                    diff_AUC = 0.1))
  # Produce the correct result with tss
  expect_equal(.create_sdmtune_result(model, metric = "tss", train_metric = 0.9,
                                      val_metric = 0.8),
               list(fc = "lqph", reg = 1, train_TSS = 0.9, test_TSS = 0.8,
                    diff_TSS = 0.1))
  # Produce the correct result with aicc
  expect_equal(.create_sdmtune_result(model, metric = "aicc",
                                      train_metric = 0.9, val_metric = NA),
               list(fc = "lqph", reg = 1, AICc = 0.9, delta_AICc = NA))
  # Produce the correct output type
  expect_type(.create_sdmtune_result(model, metric = "aicc",
                                     train_metric = 0.9, val_metric = NA),
              "list")
  # Produce the correct result with SDMmodelCV
  expect_equal(.create_sdmtune_result(model_cv, metric = "aicc",
                                      train_metric = 0.9, val_metric = NA),
               list(fc = "lqph", reg = 1, AICc = 0.9, delta_AICc = NA))
})

test_that(".create_sdm_output", {
  # Produce the correct output type
  expect_s4_class(.create_sdmtune_output(list(model, model), metric = "auc",
                                         train_metric = data.frame(x = c(1, 2),
                                                                   y = c(.8, .9)),
                                         val_metric = data.frame(x = c(1, 2),
                                                                 y = c(.6, .8))),
                                         "SDMtune")
  # Produce the correct result with aicc
  expect_length(.create_sdmtune_output(list(model, model), metric = "aicc",
                                      train_metric = data.frame(x = c(1, 2),
                                                                y = c(.8, .9)),
                                      val_metric = NA)@models, 2)
  # Produce the correct result with auc
  expect_equal(.create_sdmtune_output(list(model, model), metric = "auc",
                                      train_metric = data.frame(x = c(1, 2),
                                                                y = c(.8, .9)),
                                      val_metric = data.frame(x = c(1, 2),
                                                              y = c(.6, .8))
                                      )@results$diff_AUC, c(.2, .1))
  # Produce the correct result with tss
  expect_equal(.create_sdmtune_output(list(model, model), metric = "tss",
                                      train_metric = data.frame(x = c(1, 2),
                                                                y = c(.8, .9)),
                                      val_metric = data.frame(x = c(1, 2),
                                                              y = c(.6, .8))
  )@results$diff_TSS, c(.2, .1))
  # Produce the correct result with aicc
  expect_equal(.create_sdmtune_output(list(model, model), metric = "aicc",
                                      train_metric = data.frame(x = c(1, 2),
                                                                y = c(.8, .9)),
                                      val_metric = NA)@results$delta_AICc,
               c(0, .1))
  # Produce the correct result with SDMmodelCV
  expect_length(.create_sdmtune_output(list(model_cv, model_cv),
                                       metric = "aicc",
                                       train_metric = data.frame(x = c(1, 2),
                                                                 y = c(.8, .9)),
                                       val_metric = NA)@models, 2)
})

test_that(".get_train_args", {
  # The output is correct using maxnet
  expect_named(.get_train_args(model),
               c("data", "method", "fc", "reg"))
  # The output is correct using maxent
  expect_named(.get_train_args(model_mx),
               c("data", "method", "fc", "reg", "iter"))
  # The output is correct using ann
  expect_named(.get_train_args(model_ann),
               c("data", "method", "size", "decay", "rang", "maxit"))
  # The output is correct using rf
  expect_named(.get_train_args(model_rf),
               c("data", "method", "mtry", "ntree", "nodesize"))
  # The output is correct using brt
  expect_named(.get_train_args(model_brt),
               c("data", "method", "distribution", "n.trees",
                 "interaction.depth", "shrinkage", "bag.fraction"))
  # Give the correct output type
  expect_type(.get_train_args(model), "list")
})

test_that(".create_model_from_settings", {
  m <- .create_model_from_settings(model, list(fc = "l", reg = 2))
  expect_s4_class(m, "SDMmodel")
  expect_s4_class(m@model, "Maxnet")
  expect_equal(m@model@fc, "l")
  expect_equal(m@model@reg, 2)
})

test_that("The function .get_hypers_grid generates the correct grid", {
  expect_type(.get_hypers_grid(model, h), "list")
})

test_that("The function .start_server creates the url", {
  folder <- tempfile("SDMtune")
  expect_invisible(x <- .start_server(folder))
  expect_true(startsWith(x, "http://127.0.0.1:"))
  expect_true(endsWith(x, "/chart_template.html"))
  expect_true(grepl("/session/SDMtune", x))
  # No error are raised if the server is already running
  expect_error(.start_server(folder), NA)
  unlink(folder)
})

test_that("The function .check_args function raises exceptions", {
  h <- list("fc" = c("l", "lq", "lqp"),
            "reg" = seq(.2, 2., .2),
            "a" = 10000)

  # Throws exception if metric is aicc and env is not provided
  expect_snapshot_error(.check_args(model, metric = "aicc", hypers = h))

  # Throws exception if metric is aicc and model is SDMmodelCV
  expect_snapshot_error(.check_args(model_cv, metric = "aicc", hypers = h))

  # Throws exception if model is SDMmodel metric is not aicc and test
  # is not provided
  expect_snapshot_error(.check_args(model, metric = "auc", hypers = h))

  # Throws exception if provided hypers are not tunable
  h <- list("fc" = c("l", "lq", "lqp"),
            "lambda" = c(500, 600))
  expect_snapshot_error(.check_args(model, "auc", data, hypers = h))
  h <- list("beta" = c(1, 2, 3),
            "lambda" = c(500, 600))
  expect_snapshot_error(.check_args(model, "auc", data, hypers = h))
})

test_that("The function .args_name", {
  expect_vector(.args_name("trainANN"), ptype = character(), size = 5)
  expect_vector(.args_name("trainBRT"), ptype = character(), size = 6)
  expect_vector(.args_name("trainMaxent"), ptype = character(), size = 4)
  expect_vector(.args_name("trainMaxnet"), ptype = character(), size = 3)
  expect_vector(.args_name("trainRF"), ptype = character(), size = 4)
})

test_that("The function .get_method gives the right output", {
  # Maxent
  expect_snapshot(.get_method(SDMtune:::bm_maxent))
  # Maxnet
  expect_snapshot(.get_method(SDMtune:::bm_maxnet))
  # ANN
  data <- SDMtune:::t
  data@data <- data@data[, 1:4]
  m <- train("ANN",
             data = data,
             size = 10)
  expect_snapshot(.get_method(m))
  # BRT
  m <- trainBRT(data = data)
  expect_snapshot(.get_method(m))
  # RF
  m <- train("RF", data = data)
  expect_snapshot(.get_method(m))

  # Cross validation
  expect_snapshot(.get_method(SDMtune:::bm_maxnet_cv))
})

# TODO: Remove with version 2.0.0
test_that("Raises and error if raster package is used", {
  expect_snapshot_error(.raster_error("rast"))
})
