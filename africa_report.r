library(dplyr)
library(lubridate)
library(DT) 

ucdp_data <- readRDS("globaldata.rds") %>%
  filter(region == "Africa") %>%
  select(date_start, conflict_name, side_a, side_b, 
         country, adm_1, where_coordinates, type_of_violence, 
         best, deaths_civilians)

ucdp_data %>%
  mutate(
    Year = as.integer(year(as.Date(date_start))), 
    Month = month(as.Date(date_start), label = TRUE, abbr = FALSE),
    country = as.factor(country), 
    Violence_Type = as.factor(case_when( 
      type_of_violence == 1 ~ "State-based",
      type_of_violence == 2 ~ "Non-state",
      type_of_violence == 3 ~ "One-sided",
      TRUE ~ "Unknown"
    ))
  ) %>%
  group_by(Year, Month, conflict_name, side_a, side_b, country, adm_1, where_coordinates, Violence_Type) %>%
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
    `Type of Violence` = Violence_Type
  ) %>%
  datatable(
    filter = "top", 
    rownames = FALSE,
    class = 'cell-border stripe hover',
    options = list(
      pageLength = 10, 
      autoWidth = FALSE,
      scrollX = TRUE,  
      searchHighlight = TRUE,
      deferRender = TRUE,
      pagingType = "full_numbers",
      stateSave = FALSE,
      dom = 'tplir',
      language = list(
        paginate = list(
          `next` = "Next",
          previous = "Prev",
          first = "First",
          last = "Last"
        )
      )
    )
  ) %>%
  formatStyle('Year', formatter = JS("function(data){return data;}")) %>%
  formatStyle(
    c('Est. Total Fatalities', 'Civilian Fatalities'),
    backgroundColor = '#f9f9f9',
    fontWeight = 'bold'
  )