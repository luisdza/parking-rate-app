library(shiny)
library(DT)

server_tab_input <- function(input, output, session, data_store) {
  # Helper functions to check for conflicts
  has_monthly <- function(df, row) {
    if (row$DurationType == "Monthly") {
      matching_monthly <- df[df$DurationType == "Monthly" & df$Location == row$Location, ]
      return(nrow(matching_monthly) > 0)
    }
    return(FALSE)
  }
  
  has_daily <- function(df, row) {
    if (row$DurationType == "Daily") {
      matching_daily <- df[df$DurationType == "Daily" & df$Location == row$Location, ]
      return(nrow(matching_daily) > 0)
    }
    return(FALSE)
  }
  
  is_overlap <- function(df, row) {
    if (row$DurationType != "Hourly") {
      return(FALSE)
    }
    
    matching_hourly <- df[df$DurationType == "Hourly" & df$Location == row$Location, ]
    if (nrow(matching_hourly) == 0) {
      return(FALSE)
    }
    
    for (i in seq_len(nrow(matching_hourly))) {
      existing <- matching_hourly[i, ]
      # Check for overlapping ranges
      if (!(row$DurationTo <= existing$DurationFrom || row$DurationFrom >= existing$DurationTo)) {
        return(TRUE)
      }
    }
    return(FALSE)
  }

  observeEvent(input$add_row, {
    new_row <- data.frame(
      Location = input$location,
      DurationType = input$duration_type,
      DurationFrom = as.numeric(input$duration_from),
      DurationTo = as.numeric(input$duration_to),
      Cost = as.numeric(input$cost)
    )

    current <- data_store()

    if (new_row$DurationType == "Hourly" && new_row$DurationFrom >= new_row$DurationTo) {
      showModal(modalDialog("Duration To must be greater than Duration From.", easyClose = TRUE))
      return()
    }
    
    if (is_overlap(current, new_row)) {
      showModal(modalDialog("Overlapping hourly range detected.", easyClose = TRUE))
      return()
    }
    
    if (has_monthly(current, new_row)) {
      showModal(modalDialog("Only one monthly fee allowed per location.", easyClose = TRUE))
      return()
    }
    
    if (has_daily(current, new_row)) {
      showModal(modalDialog("Only one daily fee allowed per location.", easyClose = TRUE))
      return()
    }
    
    data_store(rbind(current, new_row))
  })
  
  observeEvent(input$delete_row, {
    current <- data_store()
    selected_row <- input$rate_table_rows_selected
    if (length(selected_row) > 0) {
      data_store(current[-selected_row, ])
    }
  })
  
  observeEvent(input$clear_btn, {
    data_store(data.frame(
      Location = character(0),
      DurationType = character(0),
      DurationFrom = numeric(0),
      DurationTo = numeric(0),
      Cost = numeric(0)
    ))
  })
    output$rate_table <- renderDT({
    df <- data_store()
    if (nrow(df) == 0) {
      df <- data.frame(
        Location = character(0),
        DurationType = character(0),
        DurationFrom = numeric(0),
        DurationTo = numeric(0),
        Cost = numeric(0)
      )
    }
    
    datatable(df, 
      selection = "single", 
      rownames = FALSE,
      class = "compact stripe hover",
      options = list(
        pageLength = 100,
        lengthMenu = list(c(10, 25, 50, 100), c("10", "25", "50", "100")),
        searchHighlight = TRUE,
        columnDefs = list(list(
          targets = 4,
          render = JS("function(data, type, row) { return parseFloat(data).toFixed(2); }")
        ))
      )    ) %>% 
    formatStyle(
      columns = c("Location", "DurationType", "DurationFrom", "DurationTo", "Cost"),
      backgroundColor = "var(--light-bg)",
      borderRadius = "5px"
    ) %>%
    formatStyle(
      'DurationType',
      target = 'row',
      backgroundColor = styleEqual(
        c('Hourly', 'Daily', 'Monthly'),
        c('rgba(120, 194, 173, 0.1)', 'rgba(120, 194, 173, 0.2)', 'rgba(120, 194, 173, 0.3)')
      )
    )
  })
    observeEvent(input$csv_file, {
    req(input$csv_file)
    tryCatch({
      new_data <- read.csv(input$csv_file$datapath, stringsAsFactors = FALSE)
      
      # Validate columns in imported data
      required_cols <- c("Location", "DurationType", "DurationFrom", "DurationTo", "Cost")
      if (!all(required_cols %in% colnames(new_data))) {
        showModal(modalDialog("Invalid file format. Missing required columns.", easyClose = TRUE))
        return()
      }
      
      # Validate data types
      new_data$DurationFrom <- as.numeric(new_data$DurationFrom)
      new_data$DurationTo <- as.numeric(new_data$DurationTo)
      new_data$Cost <- as.numeric(new_data$Cost)
      
      # Validate and add each row
      current <- data_store()
      for (i in seq_len(nrow(new_data))) {
        row <- new_data[i, ]
        
        if (row$Location == "" || !(row$DurationType %in% c("Hourly", "Daily", "Monthly"))) {
          showModal(modalDialog(paste("Invalid data in row", i), easyClose = TRUE))
          return()
        }
        
        if (row$DurationType == "Hourly" && row$DurationFrom >= row$DurationTo) {
          showModal(modalDialog(paste("Invalid duration range in row", i), easyClose = TRUE))
          return()
        }
        
        if (is_overlap(current, row) || has_monthly(current, row) || has_daily(current, row)) {
          showModal(modalDialog(paste("Conflict detected in row", i), easyClose = TRUE))
          return()
        }
        
        current <- rbind(current, row)
      }

      data_store(current)
    }, error = function(e) {
      showModal(modalDialog(paste("Error reading file:", e$message), easyClose = TRUE))
    })
  })
  
  observeEvent(input$export_btn, {
    df <- data_store()
    if (nrow(df) == 0) {
      showModal(modalDialog("No data to export.", easyClose = TRUE))
      return()
    }
    
    showModal(modalDialog(
      title = "Export Data",
      textInput("export_filename", "File Name", value = "parking_rates.csv"),
      footer = tagList(
        modalButton("Cancel"),
        downloadButton("download_csv", "Download")
      )
    ))
  })
  
  output$download_csv <- downloadHandler(
    filename = function() {
      input$export_filename
    },
    content = function(file) {
      write.csv(data_store(), file, row.names = FALSE)
    }
  )
  
  # Observer to switch to calculation tab
  observeEvent(input$goto_calc, {
    session$sendCustomMessage(type = 'clarity-track-event', 
                             message = list(
                               type = 'navigate_to_calculation',
                               metadata = list(
                                 ratesCount = nrow(data_store())
                               )
                             ))
    updateTabsetPanel(session, "main_tabs", selected = "Calculation")
  })
  
  # Observer to track add row action for Clarity analytics
  observeEvent(input$add_row, {
    session$sendCustomMessage(type = 'clarity-track-event', 
                             message = list(
                               type = 'add_rate',
                               metadata = list(
                                 location = input$location,
                                 durationType = input$duration_type,
                                 cost = input$cost
                               )
                             ))
    # ...existing code...
  })
    # Observer to track delete row action for Clarity analytics
  observeEvent(input$delete_row, {
    session$sendCustomMessage(type = 'clarity-track-event', 
                             message = list(
                               type = 'delete_rate',
                               metadata = list(
                                 selectedRow = input$rate_table_rows_selected
                               )
                             ))
    # ...existing code...
  })
  
  # Observer to load example data file
  observeEvent(input$load_example_data, {
    tryCatch({
      example_file_path <- "example_rates_with_daily.csv"
      
      if (file.exists(example_file_path)) {
        new_data <- read.csv(example_file_path, stringsAsFactors = FALSE)
        
        # Clear current data
        data_store(data.frame(
          Location = character(0),
          DurationType = character(0),
          DurationFrom = numeric(0),
          DurationTo = numeric(0),
          Cost = numeric(0)
        ))
        
        # Add each row to the data store
        current <- data_store()
        for (i in seq_len(nrow(new_data))) {
          row <- new_data[i, ]
          current <- rbind(current, row)
        }
        
        data_store(current)
          # Track event in Clarity
        session$sendCustomMessage(type = 'clarity-track-event', 
                                message = list(
                                  type = 'load_example_data',
                                  metadata = list(
                                    rows_loaded = nrow(new_data),
                                    file_name = "example_rates_with_daily.csv"
                                  )
                                ))
                                
        showModal(modalDialog(
          title = "Example Data Loaded",
          "The example data has been successfully loaded.",
          easyClose = TRUE
        ))
      } else {
        showModal(modalDialog(
          title = "File Not Found",
          "Example file could not be found.",
          easyClose = TRUE
        ))
      }
    }, error = function(e) {
      showModal(modalDialog(
        title = "Error",
        paste("Failed to load example data:", e$message),
        easyClose = TRUE
      ))
    })
  })
}