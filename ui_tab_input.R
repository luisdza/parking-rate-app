tab_input <- tabPanel("Input Form",
  sidebarLayout(
    sidebarPanel(
      fileInput("csv_file", "Import CSV", accept = ".csv"),
      tags$hr(),      textInput("location", "Location", value = ""),
      selectInput("duration_type", "Duration Type", choices = c("Hourly", "Daily", "Monthly")),
      conditionalPanel(
        condition = "input.duration_type == 'Hourly'",
        numericInput("duration_from", "Duration From (hrs)", value = 1, min = 0),
        numericInput("duration_to", "Duration To (hrs)", value = 2, min = 0)
      ),
      numericInput("cost", "Cost (R)", value = 0, min = 0),      fluidRow(
        column(6, actionButton("add_row", "Add Entry", class = "btn-success")),
        column(6, actionButton("delete_row", "Delete Selected Entry", class = "btn-danger"))
      ),
      br(),
      actionButton("goto_calc", "Calculate Rates", class = "btn-primary", width = "100%")
    ),    mainPanel(
      DTOutput("rate_table")
    )
  )
)
