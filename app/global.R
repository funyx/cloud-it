library(odbc)
library(DBI)
library(RMySQL)
library(dplyr)
library(dbplyr)
library(shiny)
library(shiny.router)
library(shiny.fluent)
library(config)

## pages
require(file = "pages/auth.R")
require(file = "pages/dashboard.R")

## modules
require(file = "modules/router.R")