source("global.R")

header <- tagList(
    img(src = "appsilon-logo.png", class = "logo"),
    div(Text(variant = "xLarge", "Sales Reps Analysis"), class = "title"),
    CommandBar(
        items = list(
            CommandBarItem("New", "Add", subitems = list(
                CommandBarItem("Email message", "Mail", key = "emailMessage", href = "mailto:me@example.com"),
                CommandBarItem("Calendar event", "Calendar", key = "calendarEvent")
            )),
            CommandBarItem("Upload sales plan", "Upload"),
            CommandBarItem("Share analysis", "Share"),
            CommandBarItem("Download report", "Download")
        ),
        farItems = list(
            CommandBarItem("Grid view", "Tiles", iconOnly = TRUE),
            CommandBarItem("Info", "Info", iconOnly = TRUE)
        ),
        style = list(width = "100%")
    )
)
navigation <- Nav(
    groups = list(
        list(links = list(
            list(name = "Home", url = route_link("/"), key = "home", icon = "Home"),
            list(name = "Analysis", url = route_link("analysis"), key = "analysis", icon = "AnalyticsReport")
            # list(name = "shiny.fluent", url = "http://github.com/Appsilon/shiny.fluent", key = "repo", icon = "GitGraph"),
            # list(name = "shiny.react", url = "http://github.com/Appsilon/shiny.react", key = "shinyreact", icon = "GitGraph"),
            # list(name = "Appsilon", url = "http://appsilon.com", key = "appsilon", icon = "WebAppBuilderFragment")
        ))
    ),
    initialSelectedKey = "home",
    styles = list(
        root = list(
            height = "100%",
            boxSizing = "border-box",
            overflowY = "auto"
        )
    )
)
footer <- Stack(
    horizontal = TRUE,
    horizontalAlign = "space-between",
    tokens = list(childrenGap = 20),
    Text(variant = "medium", "Built with ❤ by Appsilon", block = TRUE),
    Text(variant = "medium", nowrap = FALSE, "If you'd like to learn more, reach out to us at hello@appsilon.com"),
    Text(variant = "medium", nowrap = FALSE, "All rights reserved.")
)
layout <- function(mainUI) {
    div(
        class = "grid-container",
        div(class = "header", header),
        div(class = "sidenav", navigation),
        div(class = "main", mainUI),
        div(class = "footer", footer)
    )
}

router <- make_router(
    route("/", home_page()),
    route("analysis", analysis_page(), analysis_page_sv)
)

# Add shiny.router dependencies manually: they are not picked up because they're added in a non-standard way.
shiny::addResourcePath("shiny.router", system.file("www", package = "shiny.router"))
shiny_router_js_src <- file.path("shiny.router", "shiny.router.js")
shiny_router_script_tag <- shiny::tags$script(type = "text/javascript", src = shiny_router_js_src)


ui <- fluentPage(
    layout(router$ui),
    tags$head(
        tags$link(href = "style.css", rel = "stylesheet", type = "text/css"),
        shiny_router_script_tag
    )
)

server <- function(input, output, session) {
    router$server(input, output, session)
}

shinyApp(ui, server)