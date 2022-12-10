library(shiny)
library(datateachr)
library(tidyverse)
library(dplyr)
library(DT)
library(scales)
data(vancouver_trees)

ui <- fluidPage(
  titlePanel("Vancouver Trees App"),
  h5("Discover the pattern of tree planting in Vancouver from a time-sensitive perspective!"),
  #Offer
  uiOutput("datasetUrl"),
  h5(),
  sidebarLayout(
    sidebarPanel(
      width = 0,
      # Feature 1 (ui side): a date range filter can be used to choose data within a certain date range
      dateRangeInput('dateRange',
        label = 'Date range (from start to end): ',
        start = as.Date("1989-10-27", "%Y-%m-%d"), end = as.Date("2019-06-16", "%Y-%m-%d"),
        separator = "to",
        width = "20%"
      )
    ),
    mainPanel(
      h4("The tree data in your selected range is shown below; choose your preferred view."),
      # Feature 2 (only on ui side): two tabs for users to view the plot and the table separately
      tabsetPanel(
        type = "tabs",

        tabPanel("Table",
          # Feature 3 (ui side): shows an interactive table using the DT package
          DT::dataTableOutput("id_table"),
          # Feature 4 (ui side): a download button for users to download the table
          downloadButton("downloadTable", "Download Table")),

        tabPanel("Plot",
          h5("This plot shows the number of trees in each height within the time range"),
          plotOutput("id_histogram"),
          # Feature 4 (ui side): a download button for users to download the plot
          downloadButton("downloadPlot", "Download Plot"))
      )
    )
  )
)

server <- function(input, output){
  vancouver_trees_filtered <- reactive({
    vancouver_trees %>%
      # Feature 1 (server side): extract the start date and the end date from the ui widget
      filter(date_planted <= input$dateRange[2],
             date_planted >= input$dateRange[1])
  })

  plot_filtered <- reactive({
    vancouver_trees_filtered() %>%
      ggplot(aes(height_range_id)) +
      geom_histogram(binwidth = 1) +
      # Scale down y-axis
      scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x), # Set scales to be 10^n
                    labels = trans_format("log10", math_format(10^.x)))
  })

  # Create filename with dates so users can differentiate downloaded files
  file_name_with_date <- reactive({
    paste("vacouver_trees_", paste(input$dateRange, collapse = "_"))
  })

  output$id_histogram <- renderPlot({
    plot_filtered()
  })

  # Feature 3 (server side): shows an interactive table using the DT package
  output$id_table <- DT::renderDataTable(DT::datatable({
    data <- vancouver_trees_filtered()
  }))

  # Feature 4 (server side): a download handler to implement plot download
  output$downloadPlot <- downloadHandler(
    filename = function(){
      paste(file_name_with_date(), ".png")
    },
    # For plots, use ggsave
    content = function(file) {
      ggsave(file, plot = plot_filtered(), device = "png")
    }
  )

  # Feature 4 (server side): a download handler to implement table download
  output$downloadTable <- downloadHandler(
    filename = function(){
      paste(file_name_with_date(), ".csv")
    },
    # for csv files, use write.csv
    content = function(file) {
      write.csv(vancouver_trees_filtered(), file)
    }
  )

  # The source url for vancouver_trees
  url <- a("vancouver_trees dataset", href="https://opendata.vancouver.ca/explore/dataset/street-trees/information/?disjunctive.species_name&disjunctive.common_name&disjunctive.on_street&disjunctive.neighbourhood_name")

  # Load data url into the ui
  output$datasetUrl <- renderUI({
    tagList("For more information on the data soruce, see ", url)
  })
}

shinyApp(ui = ui, server = server)
