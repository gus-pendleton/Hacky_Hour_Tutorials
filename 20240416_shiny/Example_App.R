# Load packages

library(ggplot2)

library(shiny)

library(ggprism)

library(ThemePark)

library(bslib)

# Load practice data
load("data/themes.RData")

example_data <- read.csv("data/example_data.csv")

# Define our user interface (ui)

# A fluidPage is a flexible html page
ui <- fluidPage(
  theme = bs_theme(version = 5, "morph"), # Set a theme for the page overall
  
  titlePanel("Help me choose a theme"), # Give our page a title
  
  # Define a row of elements
  fluidRow(
    
    # I use column to help set the width of each row
    # Each row's width should add up to 12
  column(width = 2,
         # Create a selection box with our different theme choices
         selectInput(inputId = "theme", label = "Pick a theme", choices = themes)
         ),
  
  column(width = 5,
         # Create a plot output we call scatter
         plotOutput(outputId = "scatter")
         ),
  
  column(width = 5,
         # Create a plot output we call distribution
         plotOutput(outputId = "distribution")
         )
  )
)

# Next, we define the serve (what the app "does" interactively)
server <- function(input, output){
  
  # Define how we make that scatterplot output
  output$scatter <- renderPlot({
    ggplot(example_data, aes(x = X, y = Y)) + 
      geom_point() + 
      do.call(input$theme, args = list()) # We use "do.call" because each theme is a string rn
  })
  
  # Define how we make that distribution output
  output$distribution <- renderPlot({
    ggplot(example_data, aes(x = X)) + 
      geom_histogram() + 
      do.call(input$theme, args = list())
  })
  
}

# Run the app, using our ui and server
shinyApp(ui, server)