## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
options(knitr.table.format = "html")

## ----load data, echo=FALSE, message=FALSE--------------------------------
default_model <- SDMtune:::bm_maxent

## ---- eval=FALSE---------------------------------------------------------
#  system.file(package="dismo")

## ----import--------------------------------------------------------------
library(SDMtune)

## ----check maxent, eval=F------------------------------------------------
#  dismo::maxent()

