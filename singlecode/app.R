library(data.table)
library(dplyr)

library(shiny)
library(googleCharts)

## We use the global.R file to set variables/data that we want to be able to access in both
## the ui.R and server.R code files

data <- data.table(read.csv("./data/midtermresult2.csv"))
# Get unique vector of topic names (also removing 'id' and 'audit' columns)
topicNames <- unique(sub("_.*", "", names(data)[-1:-2]))

data <- melt(data, 
             measure = patterns("percentc$", "click$", "time$"), 
             value.name = c("percent_correct", "clicks", "time"), 
             variable.name = "topic"
)

# The melt function resulted in the variable column, which is the topic column in our case,
# being set as an index value, so we need to convert those numeric index values to actual
# topic names
# Fancier way: data <- data[,topic := topicNames[topic]][]
data$topic = topicNames[data$topic]

# We have to convert this to a factor for the chart series
data$topic <- as.factor(data$topic)
data$id <- as.character(data$id)

# For aesthetic purposes, we will round the time values to 2 decimal places (for displaying in the slider input)
data$time <-round(data$time,2)

# We need to reorder the columns to the sequence expected by Google Bubble Chart
# See: https://developers.google.com/chart/interactive/docs/gallery/bubblechart#data-format
# Current config: ID = id, X-Axis = clicks, Y-Axis = percent correct, Bubble Color = topic, Bubble Size = program
data <- select(data, id, clicks, percent_correct, topic, program, time)


## RUN THE SHINY APP NOW

# We create a lower and upper limit for the x-axis and y-axis that is slightly beyond the
# range of actual values, just so the bubbles aren't packed to the edges of the plot area
xlim <- list(
  min = min(data$clicks) - 1,
  max = max(data$clicks) + 1
)

# We can set the bounds for the percent_correct axis manually, since we know the limits are 0.00-1.00 (again,
# plus a little buffer so the plot looks nice)
ylim <- list(
  min = -0.20,
  max = 1.20
)

app <- shinyApp(
  ui = fluidPage(
    # This line loads the Google Charts JS library
    googleChartsInit(),
    
    # Use the Google webfont "Source Sans Pro"
    tags$link(
      href=paste0("http://fonts.googleapis.com/css?",
                  "family=Source+Sans+Pro:300,600,300italic"),
      rel="stylesheet", type="text/css"),
    tags$style(type="text/css",
               "body {font-family: 'Source Sans Pro'}"
    ),
    
    # Set title for the chart
    h2("Assignment 6"),
    
    googleBubbleChart("chart",
                      width="100%", height = "475px",
                      # Set the default options for this chart; they can be
                      # overridden in server.R on a per-update basis. See
                      # https://developers.google.com/chart/interactive/docs/gallery/bubblechart
                      # for option documentation.
                      options = list(
                        fontName = "Source Sans Pro",
                        fontSize = 13,
                        # Set axis labels and ranges
                        hAxis = list(
                          title = "Avg # of Clicks",
                          viewWindow = xlim
                        ),
                        vAxis = list(
                          title = "Percent Correct",
                          viewWindow = ylim
                        ),
                        # Change the below to play with the bubble sizes
                        sizeAxis = list(
                          minSize = 5,  
                          maxSize = 10
                        ),
                        # The default padding is a little too spaced out
                        chartArea = list(
                          top = 50, left = 75,
                          height = "75%", width = "75%"
                        ),
                        # Allow pan/zoom
                        explorer = list(),
                        # Set bubble visual props
                        bubble = list(
                          opacity = 0.4, stroke = "none",
                          # Hide bubble label
                          textStyle = list(
                            color = "none"
                          )
                        ),
                        # Set fonts
                        titleTextStyle = list(
                          fontSize = 16
                        ),
                        tooltip = list(
                          textStyle = list(
                            fontSize = 12
                          )
                        )
                      )
    ),
    fluidRow(
      #Create the column and the slider input
      shiny::column(4, offset = 2,
                    sliderInput("time", "Time (s)", sep = "", round = 2,
                                min = min(data$time), max = max(data$time),
                                value = max(data$time),
                                animate=animationOptions(interval=100, loop=FALSE))
      ),
      #Create another column and the select list input
      shiny::column(4,
                    selectInput("topic", "Topic", c("All Topics", topicNames), multiple = FALSE, selected = "All Topics")
      )
    )
  ),
  server = function(input, output) {
    # Provide explicit colors for topics, so they don't get recoded when the order changes
    defaultColors <- c("#3366cc", "#dc3912", "#ff9900", "#109618", "#990099", "#0099c6", "#dd4477", "#f442df", "#41f4d0", "#a941f4", "#41f455")
    series <- structure(
      lapply(defaultColors, function(color) { list(color=color) }),
      names = levels(data$topic)
    )
    
    # This block of code gets called whenever the slider or the select list values change
    # Basically, we just apply a filter to the data set based on the currently selected values
    # in the time slider and the topic select list (note that we create a new variable to hold
    # the filtered data, so we preserve the original data set each time)
    filteredData <- reactive({
      if(input$topic != "All Topics") {
        df <- data %>%
          filter(topic == input$topic, time <= input$time) %>%
          select(id, clicks, percent_correct, topic, program)
      } else {
        df <- data %>%
          filter(time <= input$time) %>%
          select(id, clicks, percent_correct, topic, program) %>%
          arrange(topic)
      }
    })
    
    # This sets up the reactive endpoint to provide updated data set to the chart each time
    # either the slider or select list value changes
    output$chart <- reactive({
      # Return the data and options
      list(
        data = googleDataTable(filteredData()),
        options = list(
          series = series
        )
      )
    })
  }
)

runApp(app)