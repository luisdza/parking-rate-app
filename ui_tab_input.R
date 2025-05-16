tab_input <- tabPanel("Input Form",
  sidebarLayout(
    sidebarPanel(
      class = "sidebar",
      h4(class = "section-header", "Import Data"),
      fileInput("csv_file", "Import CSV", accept = ".csv",
                buttonLabel = "Browse...", 
                placeholder = "No file selected"),
      tags$hr(),
      
      h4(class = "section-header", "Add Parking Rate"),
      textInput("location", "Location", value = "", 
                placeholder = "e.g., Downtown Garage"),
      selectInput("duration_type", "Rate Type", 
                  choices = c("Hourly", "Daily", "Monthly"),
                  width = "100%"),
      
      conditionalPanel(
        condition = "input.duration_type == 'Hourly'",
        fluidRow(
          column(6, numericInput("duration_from", "From (hrs)", value = 1, min = 0)),
          column(6, numericInput("duration_to", "To (hrs)", value = 2, min = 0))
        )
      ),
      
      numericInput("cost", "Cost (R)", value = 0, min = 0, 
                  width = "100%"),
      
      fluidRow(
        column(6, actionButton("add_row", "Add Entry", 
                              class = "btn-success", 
                              icon = icon("plus"),
                              width = "100%")),
        column(6, actionButton("delete_row", "Delete Selected", 
                              class = "btn-danger", 
                              icon = icon("trash"),
                              width = "100%"))
      ),
      
      tags$hr(),
      actionButton("goto_calc", "Calculate Optimal Rates", 
                  class = "btn-primary", 
                  icon = icon("calculator"),
                  width = "100%")
    ),
    mainPanel(
      h3(class = "section-header", "Parking Rates Data"),
      div(class = "result-container",
        DTOutput("rate_table")
      )
    )
  )
)
