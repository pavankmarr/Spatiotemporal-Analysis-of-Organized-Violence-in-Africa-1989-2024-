# Spatiotemporal Analysis of Organized Violence in Africa (1989–2024)

**Author:** [Pavankumar Rajasekaran]  
**Contact:** [prajasea@gmu.edu]  
**Affiliation:** [George Mason University / Genocide Prevention Program at the Carter School for Peace and Conflict Resolution]  

## Project Overview

This repository contains the source code, data, and documentation necessary to generate an interactive Quarto dashboard analyzing organized violence across the African continent. The project bridges computational data science and peace and conflict studies, utilizing geospatial and temporal data to visualize macro-level conflict trends, actor behaviors, and civilian impact over a 35-year period.

## Data Source

The primary empirical data driving this analysis is the **Uppsala Conflict Data Program (UCDP) Georeferenced Event Dataset (GED) Global version 24.1** (or corresponding version). 

* **Citation:** Sundberg, Ralph, and Erik Melander, 2013, "Introducing the UCDP Georeferenced Event Dataset", *Journal of Peace Research*, vol.50, no.4, 523-532.
* **Temporal Scope:** 1989 – 2024
* **Geographic Scope:** Africa

### Methodological Note on Data Processing
To optimize the computational performance of the `crosstalk` HTML widgets and to isolate statistically significant macro-level trends, the raw UCDP dataset has been pre-filtered. The dashboard strictly displays events that resulted in an estimated threshold of **5 or more total fatalities** (the `best` estimate variable). 

## Repository Contents

* `[Your_Filename].qmd`: The primary Quarto markdown file containing the narrative text, variable codebook, and the embedded R code required to construct the HTML dashboard.
* `globaldata.rds`: The serialized R data file containing the UCDP GED dataset. *(Note: Ensure this file is in the same working directory as the .qmd file prior to rendering).*
* `references.bib`: The BibTeX file containing the necessary academic citations for the project.
* `README.md`: This documentation file.

## Prerequisites and Dependencies

To successfully render the Quarto document and reproduce the interactive dashboard locally, you will need **R**, **RStudio** (or another Quarto-supported IDE), and the **Quarto CLI** installed. 

The following R packages are strictly required:

* `dplyr`: For data manipulation and piping.
* `lubridate`: For temporal data parsing and manipulation.
* `DT`: For rendering the interactive DataTables.
* `plotly`: For generating the interactive temporal scatter plots.
* `leaflet`: For geospatial mapping and coordinate clustering.
* `crosstalk`: For enabling client-side cross-widget interactivity (linking the map, graph, and table).
* `htmltools`: For structuring the HTML layout and custom table tagging.

## Instructions for Reproduction

1. **Clone/Download** this repository to your local machine.
2. **Ensure** that `globaldata.rds`, `references.bib`, and the `.qmd` file are all located in the same root directory.
3. **Install** any missing R packages via the R console: 
   `install.packages(c("dplyr", "lubridate", "DT", "plotly", "crosstalk", "htmltools", "leaflet"))`
4. **Render** the document. If using RStudio, open the `.qmd` file and click the **"Render"** button. Alternatively, run the following command in your terminal:
   `quarto render [Your_Filename].qmd`
5. The output will be a self-contained `html` file that can be opened in any modern web browser.

## Codebook and Variable Operationalization

For a full breakdown of how variables such as "Type of Violence," "Side A / Side B," and fatality estimates are operationalized within this dashboard, please refer to the **"Operationalization of Key Variables"** section within the rendered HTML document.