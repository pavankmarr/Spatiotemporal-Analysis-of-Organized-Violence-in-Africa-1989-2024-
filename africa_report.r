library(dplyr)
library(lubridate)
library(DT)
library(plotly)
library(crosstalk)
library(htmltools)
library(leaflet)

cleaned_data <- readRDS("globaldata.rds") %>%
  filter(region == "Africa") %>%
  filter(best >= 5) %>%
  mutate(
    Date = as.Date(date_start),
    Year = as.integer(year(Date)), 
    Month = month(Date, label = TRUE, abbr = FALSE),
    country = as.factor(country), 
    Violence_Type = as.factor(case_when( 
      type_of_violence == 1 ~ "State-based",
      type_of_violence == 2 ~ "Non-state",
      type_of_violence == 3 ~ "One-sided",
      TRUE ~ "Unknown"
    ))
  ) %>%
  group_by(Year, Month, Date, conflict_name, side_a, side_b, country, adm_1, where_coordinates, latitude, longitude, Violence_Type) %>%
  summarize(
    `Total Events` = n(),
    `Est. Total Fatalities` = sum(best, na.rm = TRUE),
    `Civilian Fatalities` = sum(deaths_civilians, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(Year), desc(Month), desc(`Est. Total Fatalities`)) %>%
  rename(
    `Conflict Name` = conflict_name,
    `Side A (Actor 1)` = side_a,
    `Side B (Actor 2)` = side_b,
    Country = country,
    `Province/State` = adm_1,
    `Specific Location` = where_coordinates,
    Latitude = latitude,
    Longitude = longitude,
    `Type of Violence` = Violence_Type
  )

shared_data <- SharedData$new(cleaned_data)

master_filters <- bscols(
  widths = c(3, 3, 3, 3),
  filter_select("country_filter", "Select Country", shared_data, ~Country),
  filter_slider("year_filter", "Year Range", shared_data, ~Year, round = TRUE, sep = ""),
  filter_select("type_filter", "Violence Type", shared_data, ~`Type of Violence`),
  filter_slider("fatality_filter", "Total Fatalities", shared_data, ~`Est. Total Fatalities`)
)

table_sketch <- htmltools::withTags(table(
  class = 'display',
  thead(
    tr(lapply(names(cleaned_data), th))
  ),
  tfoot(
    tr(lapply(names(cleaned_data), function(x) th("")))
  )
))

interactive_table <- datatable(
  shared_data,
  filter = "top", 
  rownames = FALSE,
  container = table_sketch,
  class = 'cell-border stripe hover compact',
  extensions = 'Buttons',
  options = list(
    pageLength = 10, 
    autoWidth = FALSE,
    scrollX = TRUE,  
    searchHighlight = TRUE,
    deferRender = TRUE,
    pagingType = "full_numbers",
    stateSave = FALSE,
    dom = 'Btplir',
    buttons = c('copy', 'csv', 'excel', 'pdf'),
    language = list(
      paginate = list(
        `next` = "Next",
        previous = "Prev",
        first = "First",
        last = "Last"
      )
    ),
    footerCallback = JS(
      "function(row, data, start, end, display) {",
      "  var api = this.api();",
      "  var intVal = function(i) {",
      "    return typeof i === 'string' ? i.replace(/[\\$,]/g, '')*1 : typeof i === 'number' ? i : 0;",
      "  };",
      "  var events = api.column(12, {search:'applied'}).data().reduce(function(a, b) { return intVal(a) + intVal(b); }, 0);",
      "  var totalFat = api.column(13, {search:'applied'}).data().reduce(function(a, b) { return intVal(a) + intVal(b); }, 0);",
      "  var civFat = api.column(14, {search:'applied'}).data().reduce(function(a, b) { return intVal(a) + intVal(b); }, 0);",
      "  $(api.column(11).footer()).html('FILTERED TOTALS:');",
      "  $(api.column(12).footer()).html(events);",
      "  $(api.column(13).footer()).html(totalFat);",
      "  $(api.column(14).footer()).html(civFat);",
      "}"
    )
  )
) %>%
  formatStyle('Year', formatter = JS("function(data){return data;}")) %>%
  formatStyle(
    c('Est. Total Fatalities', 'Civilian Fatalities'),
    backgroundColor = '#f9f9f9',
    fontWeight = 'bold'
  )

interactive_map <- leaflet(shared_data, height = 500) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addCircleMarkers(
    lat = ~Latitude,
    lng = ~Longitude,
    radius = ~sqrt(`Est. Total Fatalities`) * 1.5,
    color = "#e74c3c",
    stroke = FALSE,
    fillOpacity = 0.6,
    popup = ~paste("<b>Conflict:</b>", `Conflict Name`, 
                   "<br><b>Date:</b>", Date, 
                   "<br><b>Location:</b>", `Specific Location`, 
                   "<br><b>Total Fatalities:</b>", `Est. Total Fatalities`,
                   "<br><b>Civilian Fatalities:</b>", `Civilian Fatalities`),
    clusterOptions = markerClusterOptions()
  )

interactive_graph <- plot_ly(shared_data, 
        x = ~Date, 
        y = ~`Est. Total Fatalities`, 
        color = ~Country, 
        type = 'scatter', 
        mode = 'markers',
        marker = list(sizemode = 'diameter', opacity = 0.7),
        sizes = c(5, 40),
        size = ~`Est. Total Fatalities`,
        text = ~paste("Conflict:", `Conflict Name`, 
                      "<br>Date:", Date, 
                      "<br>Fatalities:", `Est. Total Fatalities`, 
                      "<br>Location:", `Specific Location`),
        hoverinfo = 'text',
        height = 400) %>%
  layout(
    title = "Interactive Conflict Timeline",
    yaxis = list(title = "Est. Total Fatalities"),
    xaxis = list(title = "Timeline"),
    showlegend = FALSE,
    margin = list(t = 50, b = 50, l = 50, r = 50)
  )

browsable(
  tagList(
    master_filters,
    tags$br(),
    tags$hr(),
    tags$h4("Download Raw Data"),
    interactive_table,
    tags$br(),
    tags$hr(),
    bscols(
      widths = c(6, 6),
      tagList(tags$h4("Geospatial Distribution"), interactive_map),
      tagList(tags$h4("Temporal Fatality Trends"), interactive_graph)
    )
  )
)
