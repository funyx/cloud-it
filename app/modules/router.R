library(shiny)
library(shiny.router)
router <- make_router(
    route("/", dashboard_page("dashboard")),
    route("/auth", auth_page("auth"))
)