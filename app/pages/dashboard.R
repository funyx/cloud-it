dashboard_page <- function(id) {
  ns <- NS(id)
  Text("Dashboard")
}

dashboard_page_cb <- function(id, prefix = "") {
  moduleServer(id, function(input, output, session) {
    output$result <- renderText({
      paste0(prefix, toupper(input$txt))
    })
  })
}
