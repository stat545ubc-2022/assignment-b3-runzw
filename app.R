library(shiny)
library(datateachr)
library(tidyverse)
library(dplyr)
library(DT)
library(scales)
data(vancouver_trees)

ui <- fluidPage(
  titlePanel("Vancouver Forestry App"),
  sidebarLayout(
    sidebarPanel(

      # Feature 1 (ui side): a date range filter can be used to choose data within a certain date range
      dateRangeInput('dateRange',
        label = 'Date range:',
        start = as.Date("1989-10-27", "%Y-%m-%d"), end = as.Date("2019-06-16", "%Y-%m-%d")
      )
    ),
    mainPanel(

      # Feature 2 (only on ui side): two tabs for users to view the plot and the table separately
      tabsetPanel(
        type = "tabs",

        tabPanel("Table",
          # Feature 3 (ui side): shows an interactive table using the DT package
          DT::dataTableOutput("id_table"),
          # Feature 4 (ui side): a download button for users to download the table
          downloadButton("downloadTable", "Download Table")),

        tabPanel("Plot",
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
      scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x), # Set scales to be 10^n
                    labels = trans_format("log10", math_format(10^.x)))
  })

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
    content = function(file) {
      ggsave(file, plot = plot_filtered(), device = "png")
    }
  )

  # Feature 4 (server side): a download handler to implement table download
  output$downloadTable <- downloadHandler(
    filename = function(){
      paste(file_name_with_date(), ".csv")
    },
    content = function(file) {
      write.csv(vancouver_trees_filtered(), file)
    }
  )
}

shinyApp(ui = ui, server = server)
