tab_calculation <- tabPanel("Calculation",
  sidebarLayout(
    sidebarPanel(
      numericInput("hours_per_day", 
                  "Hours per Day", 
                  value = 4,
                  min = 1,
                  max = 24),
      numericInput("days_per_month", 
                  "Days per Month", 
                  value = 22,
                  min = 1,
                  max = 31),
      actionButton("calc_btn", "Calculate Optimal Rate", 
                  class = "btn-primary", 
                  width = "100%")
    ),    mainPanel(
      h4("Optimization Results"),
      verbatimTextOutput("result_output"),
      tags$hr(),
      h4("Calculation Details"),
      verbatimTextOutput("debug_output")
    )
  )
)
