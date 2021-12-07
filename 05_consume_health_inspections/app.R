library(shiny)
library(httr2)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Smoke Shop County Predictor - NY State"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      sliderInput("medianage",
                  "Median Age",
                  min = 1,
                  max = 100,
                  value = 30),
      numericInput("avghouseholdsize",
                   "Average Household Size",
                   value = 2)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      textOutput("predOutput")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$predOutput <- renderText({
    prediction_api <- Sys.getenv("PREDICTION_API")
    if (prediction_api == ""){
      paste("The API can't be reached")
    } else {
      req <- request(paste0(prediction_api, "/predict")) %>%
        req_headers("Accept" = "application/json") %>%
        req_url_query(`medianage` = input$medianage, 
                      `avghouseholdsize` = input$avghouseholdsize)
      
      resp <- req_perform(req)
      paste(resp)
    }
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
