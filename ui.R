
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(googleCharts)

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

shinyUI(fluidPage(

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
))
