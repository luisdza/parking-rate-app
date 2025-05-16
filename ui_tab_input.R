tab_input <- tabPanel("Input Form",
  sidebarLayout(
    sidebarPanel(
      class = "sidebar",      h4(class = "section-header", "📤 Import Data"),
                fileInput("csv_file", "Import CSV", accept = ".csv",
                buttonLabel = "Browse...", 
                placeholder = "No file selected") %>% tagAppend(tags$div(
                  `data-clarity-region` = "csv-file-input",
                  `data-clarity-unmask` = TRUE
                )),
      div(class = "info-box",
        p(HTML("Try our <a href='#' id='load_example_data' class='sample-link' data-clarity-region='load-sample-data'>example data file</a> to see how the app works.")),
        tags$script(HTML("
          $(document).on('click', '#load_example_data', function(e) {
            e.preventDefault();
            Shiny.setInputValue('load_example_data', Math.random());
          });
        "))
      ),
      tags$hr(),
      
      h4(class = "section-header", "🚗 Add Parking Rate"),
                textInput("location", "Location", value = "", 
                placeholder = "e.g., Downtown Garage") %>% tagAppend(tags$div(
                  `data-clarity-region` = "location-input",
                  `data-clarity-unmask` = TRUE
                )),
                  selectInput("duration_type", "Rate Type", 
                  choices = c("Hourly", "Daily", "Monthly"),
                  width = "100%") %>% tagAppend(tags$div(
                    `data-clarity-region` = "rate-type-select",
                    `data-clarity-unmask` = TRUE
                  )),
      
      conditionalPanel(
        condition = "input.duration_type == 'Hourly'",
                fluidRow(
                   column(6, numericInput("duration_from", "From (hrs)", value = 1, min = 0) %>% 
                   tagAppend(tags$div(
                     `data-clarity-region` = "duration-from-input",
                     `data-clarity-unmask` = TRUE
                   ))),
          column(6, numericInput("duration_to", "To (hrs)", value = 2, min = 0) %>%
                   tagAppend(tags$div(
                     `data-clarity-region` = "duration-to-input",
                     `data-clarity-unmask` = TRUE
                   )))
        )
      ),
        numericInput("cost", "Cost", value = 0, min = 0, 
                  width = "100%") %>% tagAppend(tags$div(
                    `data-clarity-region` = "cost-input",
                    `data-clarity-unmask` = TRUE
                  )),
        fluidRow(
        column(6, actionButton("add_row", "Add Entry", 
                              class = "btn-success", 
                              icon = icon("plus"),
                              width = "100%",
                              `data-clarity-mask` = FALSE,
                              `data-clarity-region` = "add-entry-button",
                              `data-clarity-unmask` = TRUE)),
        column(6, actionButton("delete_row", "Delete Selected", 
                              class = "btn-danger", 
                              icon = icon("trash"),
                              width = "100%",
                              `data-clarity-mask` = FALSE,
                              `data-clarity-region` = "delete-row-button",
                              `data-clarity-unmask` = TRUE))
      ),
      
      tags$hr(),
                 actionButton("goto_calc", "Calculate Optimal Rates", 
                  class = "btn-primary", 
                  icon = icon("calculator"),
                  width = "100%",
                  `data-clarity-mask` = FALSE,
                  `data-clarity-region` = "goto-calc-button",
                  `data-clarity-unmask` = TRUE)
    ),
    mainPanel(
      h3(class = "section-header", "Parking Rates Data"),
      div(class = "result-container",
        div(`data-clarity-region` = "rate-table", `data-clarity-unmask` = TRUE,
          DTOutput("rate_table")
        )
      )
    )
  )
)
