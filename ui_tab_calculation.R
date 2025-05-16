tab_calculation <- tabPanel("Calculation",
  sidebarLayout(
    sidebarPanel(
      class = "sidebar",
      h4(class = "section-header", "Usage Parameters"),      div(class = "info-box",
        p("Enter your typical parking usage to find the most cost-effective option.")
      ),
      
      numericInput("hours_per_day", 
                  "Hours per Day", 
                  value = 4,
                  min = 1,
                  max = 24,
                  width = "100%"),
      
      numericInput("days_per_month", 
                  "Days per Month", 
                  value = 22,
                  min = 1,
                  max = 31,
                  width = "100%"),
      
      tags$hr(),
      
      actionButton("calc_btn", "Calculate Optimal Rate", 
                  class = "btn-primary", 
                  icon = icon("calculator"),
                  style = "margin-top: 10px;",
                  width = "100%")
    ),
    
    mainPanel(
      h3(class = "section-header", "Results"),
      div(class = "result-container",
        tags$h4(icon("check-circle", class = "text-success"), " Optimization Results"),
        tags$p("The most cost-effective parking option based on your usage:"),
        verbatimTextOutput("result_output"),
        
        tags$hr(),
        
        tags$h4(icon("list-alt"), " Calculation Details"),
        tags$p("Comparing all available parking options:"),
        verbatimTextOutput("debug_output")
      )
    )
  )
)
