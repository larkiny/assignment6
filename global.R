library(data.table)
library(dplyr)

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
