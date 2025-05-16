library(shiny)
library(DT)
library(bslib)
library(lpSolve)

source("ui_tab_input.R")
source("ui_tab_calculation.R")
source("server_tab_input.R")
source("server_tab_calculation.R")

ui <- fluidPage(
  theme = bs_theme(bootswatch = "minty"),
  titlePanel("Parking Rate Manager"),
  tabsetPanel(
    id = "main_tabs",
    tab_input,
    tab_calculation
  )
)

server <- function(input, output, session) {
  # Shared reactive data store
  data_store <- reactiveVal(data.frame(
    Location = character(),
    DurationType = character(),
    DurationFrom = numeric(),
    DurationTo = numeric(),
    Cost = numeric(),
    stringsAsFactors = FALSE
  ))

  # Run tab-specific logic
  server_tab_input(input, output, session, data_store)
  server_tab_calculation(input, output, session, data_store)
}

shinyApp(ui = ui, server = server)
