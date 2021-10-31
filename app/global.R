library(odbc)
library(DBI)
library(RMySQL)
library(dplyr)
library(dbplyr)
library(config)
library(ggplot2)
library(glue)
library(leaflet)
library(plotly)
library(sass)
library(shiny)
library(shiny.router)
library(shiny.fluent)

options(shiny.router.debug = T)

## helpers
makeCard <- function(title, content, size = 12, style = "") {
    div(
        class = glue("card ms-depth-8 ms-sm{size} ms-xl{size}"),
        style = style,
        Stack(
            tokens = list(childrenGap = 5),
            Text(variant = "large", title, block = TRUE),
            content
        )
    )
}

makePage <- function(title, subtitle, contents) {
    tagList(
        div(
            class = "page-title",
            span(title,
                class = "ms-fontSize-32 ms-fontWeight-semibold", style =
                    "color: #323130"
            ),
            span(subtitle,
                class = "ms-fontSize-14 ms-fontWeight-regular", style =
                    "color: #605E5C; margin: 14px;"
            )
        ),
        contents
    )
}

## pages
source(file = "pages/home.R")
source(file = "pages/analysis.R")

## modules
# source(file = "modules/router.R")