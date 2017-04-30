library(dplyr)

shinyServer(function(input, output, session) {
  
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
})
