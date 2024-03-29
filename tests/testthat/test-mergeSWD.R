t <- SDMtune:::t

test_that("Both presence and absence locations are merged", {
  x <- mergeSWD(t, t)
  np <- nrow(t@data[t@pa == 1, ])
  na <- nrow(t@data[t@pa == 0, ])
  n <- (np * 2) + (na * 2)

  expect_s4_class(x, "SWD")
  expect_equal(rownames(x@data), as.character(1:n))
  expect_equal(rownames(x@coords), as.character(1:n))
  expect_equal(nrow(x@data), n)
  expect_equal(nrow(x@coords), n)
  expect_equal(x@species, t@species)
  expect_equal(x@pa, c(rep(1, np * 2), rep(0, na * 2)))
})

test_that("Only presence locations are merged if only_presence is TRUE", {
  x <- mergeSWD(t, t, only_presence = TRUE)
  np <- nrow(t@data[t@pa == 1, ])
  na <- nrow(t@data[t@pa == 0, ])
  n <- (np * 2) + na

  expect_s4_class(x, "SWD")
  expect_equal(rownames(x@data), as.character(1:n))
  expect_equal(rownames(x@coords), as.character(1:n))
  expect_equal(nrow(x@data), n)
  expect_equal(nrow(x@coords), n)
  expect_equal(x@species, t@species)
  expect_equal(x@pa, c(rep(1, np *  2), rep(0, na)))
})

test_that("The function raises errors", {
  expect_snapshot_error(mergeSWD(t, t@data))

  x <- t
  x@species <- "Gypaetus barbatus"

  expect_snapshot_error(mergeSWD(x, t))
})

test_that("The function warns if datasets have different variables", {
  x <- t
  x@data$biome <- NULL

  expect_snapshot_warning(m <- mergeSWD(x, t))
  # Check that common columns are merged
  expect_named(m@data, names(x@data))
})
