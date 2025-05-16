library(shiny)
library(DT)
library(bslib)
library(lpSolve)
library(htmltools)

# Helper function to add clarity tags to UI elements
tagAppend <- function(tag, ...) {
  tagList(tag, ...)
}

source("ui_tab_input.R")
source("ui_tab_calculation.R")
source("server_tab_input.R")
source("server_tab_calculation.R")

ui <- fluidPage(
  theme = bs_theme(bootswatch = "minty"),  
  tags$head(    # Microsoft Clarity Analytics
    tags$script(HTML('
      (function(c,l,a,r,i,t,y){
        c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
        t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
        y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
      })(window, document, "clarity", "script", "rkmlsglfct");
    ')),
    
    # JavaScript to handle custom clarity events
    tags$script(HTML('
      $(document).on("shiny:connected", function() {
        Shiny.addCustomMessageHandler("clarity-track-event", function(message) {
          if (window.clarity && typeof window.clarity === "function") {
            clarity("event", message.type, message.metadata || {});
            console.log("Clarity event tracked:", message.type, message.metadata);
          }
        });
      });
    ')),
    tags$style(HTML("
      :root {
        --primary-color: #5BBDC4;        /* Minty theme primary color */
        --secondary-color: #6cc3d5;      /* Slightly lighter blue */
        --accent-color: #78c2ad;         /* Minty theme accent color */
        --light-bg: #f8f9fa;             /* Light background */
        --dark-text: #2c3e50;            /* Dark text color */
        --border-light: #e9ecef;         /* Light border */
        --info-bg: #d1ecf1;              /* Light info background */
        --shadow-sm: 0 2px 4px rgba(0, 0, 0, 0.05);
        --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
        --border-radius: 8px;
      }
      
      .header-container {
        background-color: var(--accent-color);
        color: white;
        padding: 15px 20px;
        margin-bottom: 20px;
        border-radius: var(--border-radius);
        box-shadow: var(--shadow-md);
      }
      .app-title {
        font-size: 28px;
        font-weight: bold;
        margin: 0;
      }
      .app-subtitle {
        font-size: 14px;
        margin-top: 5px;
        opacity: 0.9;
      }
      .sidebar {
        background-color: var(--light-bg);
        border-radius: var(--border-radius);
        padding: 15px;
        box-shadow: var(--shadow-sm);
      }
      .result-container {
        background-color: var(--light-bg);
        border-radius: var(--border-radius);
        padding: 15px;
        margin-top: 15px;
        box-shadow: var(--shadow-sm);
      }
      .info-box {
        padding: 10px; 
        background-color: var(--info-bg); 
        border-radius: 5px; 
        margin-bottom: 15px;
      }
      .btn-primary, .btn-success {
        border-radius: 5px;
        font-weight: 500;
        box-shadow: var(--shadow-sm);
      }
      .section-header {
        border-bottom: 2px solid var(--accent-color);
        padding-bottom: 8px;
        margin-bottom: 15px;
        color: var(--dark-text);
      }
      #debug_output, #result_output {
        background-color: white;
        border-radius: 5px;
        padding: 10px;
        border: 1px solid var(--border-light);
      }      .nav-tabs .nav-link.active {
        font-weight: bold;
        border-top: 3px solid var(--accent-color);
      }
      .sample-link {
        color: var(--accent-color);
        text-decoration: none;
        font-weight: 500;
      }
      .sample-link:hover {
        text-decoration: underline;
        color: var(--secondary-color);
      }
    "))
  ),
  div(class = "header-container",
      h1(class = "app-title", "🅿️ ParkRate Navigator 🧭"),
      p(class = "app-subtitle", "Find the most cost-effective parking option for your needs")
  ),
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
