# Vancouver Forestry App

## Link

<https://runzw.shinyapps.io/assignment-b3-runzw/>

## My Choice

Option B

## Description

This app shows the vancouver_trees data:

1.  in the form of a table

2.  in a plot which counts the number of trees in different height

within a selected date range.

## Features

Users can:

1.  select a date range to see data within it.

    -   `dateRangeInput()` is used to display a filter

    -   The values of selected dates are extracted from `input$dateRange[1]` and `input$dateRang[2]`.

2.  switch tabs to view the plot and the table separately.

    -   `tabsetPanel()` is used to separate the plot and the table into two tabs.

3.  access an interactive table where they can search, page, and sort the data.

    -   `DT::dataTableOutput()` and `DT::renderDataTable()` are used to show an interactive table.

4.  download the plot and the table.

    -   `downloadButton()` is used to create two buttons for downloading the plot and the table, respectively.
    -   `downloadHandler()` is implemented by `write.csv()` and `ggsave` to .
    -   The download files are named after the selected date range, e.x. "vancouver_trees_2013-03-11_2020-04-25.png".
