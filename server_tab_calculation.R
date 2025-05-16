server_tab_calculation <- function(input, output, session, data_store) {
  # Calculate optimal rate
  observeEvent(input$calculate_btn, {
    req(data_store())
    df <- data_store()
    
    # Validate we have data
    if (nrow(df) == 0) {
      showNotification("No parking rates available", type = "warning")
      return()
    }
    
    # Get user inputs with validation
    hours_per_day <- as.numeric(input$hours_per_day)
    days_per_month <- as.numeric(input$days_per_month)
    
    tryCatch({
      # Separate rates by type
      hourly_rates <- df[df$DurationType == "Hourly" & 
                        hours_per_day >= df$DurationFrom & 
                        hours_per_day <= df$DurationTo, ]
      daily_rates <- df[df$DurationType == "Daily", ]
      monthly_rates <- df[df$DurationType == "Monthly", ]
      
      # Calculate costs for each type
      costs <- c()
      names_vec <- c()
      
      # Add hourly rates
      if (nrow(hourly_rates) > 0) {
        hourly_costs <- hourly_rates$Cost * hours_per_day * days_per_month
        costs <- c(costs, hourly_costs)
        names_vec <- c(names_vec, paste0("H", 1:length(hourly_costs)))
      }
      
      # Add daily rates
      if (nrow(daily_rates) > 0) {
        daily_costs <- daily_rates$Cost * days_per_month
        costs <- c(costs, daily_costs)
        names_vec <- c(names_vec, paste0("D", 1:length(daily_costs)))
      }
      
      # Add monthly rates
      if (nrow(monthly_rates) > 0) {
        monthly_costs <- monthly_rates$Cost
        costs <- c(costs, monthly_costs)
        names_vec <- c(names_vec, paste0("M", 1:length(monthly_costs)))
      }
      
      names(costs) <- names_vec
      
      if (length(costs) == 0) {
        showNotification("No applicable rates found", type = "warning")
        return()
      }
      
      # Create constraint matrix for optimization
      f.con <- matrix(1, nrow = 1, ncol = length(costs))
      f.dir <- "="
      f.rhs <- 1
      
      # Solve using linear programming
      solution <- lp("min", costs, f.con, f.dir, f.rhs, all.bin = TRUE)
      
      if (solution$status != 0) {
        showNotification("Could not find optimal solution", type = "error")
        return()
      }
      
      # Get the selected option
      selected_idx <- which(solution$solution == 1)
      selected_name <- names(costs)[selected_idx]
      
      # Create results data frame
      results <- data.frame(
        Option = names(costs),
        Cost = costs,
        Selected = FALSE,
        stringsAsFactors = FALSE
      )
      results$Selected[selected_idx] <- TRUE
      
      # Update outputs
      output$result_output <- renderText({
        sprintf("Optimal parking option: %s with monthly cost: R%.2f", 
                selected_name, solution$objval)
      })
      
      output$debug_output <- renderText({
        paste("Assumptions:",
              sprintf("- Hours per day: %.1f", hours_per_day),
              sprintf("- Days per month: %d", days_per_month),
              sprintf("- Total hours per month: %.1f", hours_per_day * days_per_month),
              "",
              "Calculation details:",
              sprintf("- Total options evaluated: %d", length(costs)),
              sprintf("- Optimal monthly cost: R%.2f", solution$objval),
              sep = "\n")
      })
      
    }, error = function(e) {
      showNotification(
        paste("Error in calculation:", e$message),
        type = "error"
      )
    })
  })
}