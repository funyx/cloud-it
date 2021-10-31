analysis_page <- function(id = "analysis") {
    ns <- NS(id)
    makePage(
        "Sales representatives",
        "Best performing reps",
        div(
            Stack(
                horizontal = TRUE,
                tokens = list(childrenGap = 10),
                makeCard("Filters",
                    size = 4,
                    style = "max-height: 320px",
                    Stack(
                        tokens = list(childrenGap = 10),
                        Stack(
                            horizontal = TRUE,
                            tokens = list(childrenGap = 10),
                            DatePicker.shinyInput(
                                ns("fromDate"),
                                value = as.Date("2020/01/01"),
                                label = "From date"
                            ),
                            DatePicker.shinyInput(
                                ns("toDate"),
                                value = as.Date("2020/12/31"),
                                label = "To date"
                            )
                        ),
                        Label("Filter by sales reps", className = "my_class"),
                        NormalPeoplePicker.shinyInput(
                            ns("selected_people"),
                            class = "my_class",
                            options = fluentPeople,
                            pickerSuggestionsProps = list(
                                suggestionsHeaderText = "Matching people",
                                mostRecentlyUsedHeaderText = "Sales reps",
                                noResultsFoundText = "No results found",
                                showRemoveButtons = TRUE
                            )
                        ),
                        Slider.shinyInput(
                            ns("slider"),
                            value = 0,
                            min = 0,
                            max = 1000000,
                            step = 100000,
                            label = "Minimum amount",
                            valueFormat = JS("function(x) { return '$' + x}"),
                            snapToStep = TRUE
                        ),
                        Toggle.shinyInput(
                            ns("closedOnly"),
                            value = TRUE,
                            label = "Include closed deals only?"
                        )
                    )
                ),
                makeCard("Deals count",
                    size = 8,
                    style = "max-height: 320px",
                    plotlyOutput(ns("plot"))
                )
            ),
            uiOutput(ns("analysis"))
        )
    )
}

analysis_page_sv <- function(input, output, session) {
    callModule(function(input, output, session) {
        ns <- NS("analysis")
        filtered_deals <- reactive({
            req(input$fromDate)
            selected_people <- (
                if (length(input$selected_people) > 0) {
                    input$selected_people
                } else {
                    fluentPeople$key
                })
            minClosedVal <- if (isTRUE(input$closedOnly)) 1 else 0

            filtered_deals <- fluentSalesDeals %>%
                filter(
                    rep_id %in% selected_people,
                    date >= input$fromDate,
                    date <= input$toDate,
                    deal_amount >= input$slider,
                    is_closed >= minClosedVal
                ) %>%
                mutate(is_closed = ifelse(is_closed == 1, "Yes", "No"))
        })

        output$map <- renderLeaflet({
            points <- cbind(
                filtered_deals()$LONGITUDE,
                filtered_deals()$LATITUDE
            )
            leaflet() %>%
                addProviderTiles(
                    providers$Stamen.TonerLite,
                    options = providerTileOptions(noWrap = TRUE)
                ) %>%
                addMarkers(data = points)
        })

        output$plot <- renderPlotly({
            p <- ggplot(filtered_deals(), aes(x = rep_name)) +
                geom_bar(fill = unique(filtered_deals()$color)) +
                ylab("Number of deals") +
                xlab("Sales rep") +
                theme_light()
            ggplotly(p, height = 300)
        })

        output$analysis <- renderUI({
            Stack(
                horizontal = TRUE,
                tokens = list(childrenGap = 10),
                makeCard("Map",
                    size = 4,
                    style = "max-height: 500px; overflow: auto",
                    leafletOutput(ns("map"))
                ),
                makeCard("Top results",
                    size = 8,
                    style = "max-height: 500px; overflow: auto",
                    div(
                        if (nrow(filtered_deals()) > 0) {
                            DetailsList(
                                items = filtered_deals(),
                                columns = tibble(
                                    fieldName = c(
                                        "rep_name",
                                        "date",
                                        "deal_amount",
                                        "client_name",
                                        "city",
                                        "is_closed"
                                    ),
                                    name = c(
                                        "Sales rep",
                                        "Close date",
                                        "Amount",
                                        "Client",
                                        "City",
                                        "Is closed?"
                                    ),
                                    key = fieldName
                                )
                            )
                        } else {
                            p("No matching transactions.")
                        }
                    )
                )
            )
        })
    }, "analysis")
}