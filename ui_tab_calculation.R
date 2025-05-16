tab_calculation <- tabPanel("Calculation",
  sidebarLayout(
    sidebarPanel(
      class = "sidebar",
      h4(class = "section-header", "🔧Usage Parameters"),
        div(class = "info-box",
        p("Enter your typical parking usage to find the most cost-effective option.")
      ),
        numericInput("hours_per_day", 
                  "Hours per Day", 
                  value = 4,
                  min = 1,
                  max = 24,
                  width = "100%") %>% tagAppend(tags$div(
                    `data-clarity-region` = "hours-per-day",
                    `data-clarity-unmask` = TRUE
                  )),
        numericInput("days_per_month", 
                  "Days per Month", 
                  value = 22,
                  min = 1,
                  max = 31,
                  width = "100%") %>% tagAppend(tags$div(
                    `data-clarity-region` = "days-per-month",
                    `data-clarity-unmask` = TRUE
                  )),
      
      tags$hr(),
        actionButton("calc_btn", "Calculate Optimal Rate", 
                  class = "btn-primary", 
                  icon = icon("calculator"),
                  style = "margin-top: 10px;",
                  width = "100%",
                  `data-clarity-mask` = FALSE,
                  `data-clarity-region` = "calculate-optimal-rate-button",
                  `data-clarity-unmask` = TRUE)
    ),
    
    mainPanel(
      h3(class = "section-header", "Results"),
      div(class = "result-container",
        tags$h4(icon("check-circle", class = "text-success"), " Optimization Results"),
        tags$p("The most cost-effective parking option based on your usage:"),
        div(`data-clarity-region` = "result-output", `data-clarity-unmask` = TRUE,
          verbatimTextOutput("result_output")
        ),
        
        tags$hr(),
        
        tags$h4(icon("list-alt"), " Calculation Details"),
        tags$p("Comparing all available parking options:"),
        div(`data-clarity-region` = "debug-output", `data-clarity-unmask` = TRUE,
          verbatimTextOutput("debug_output")
        )
      )
    )
  )
)
