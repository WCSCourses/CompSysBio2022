##################################################
## Project: Reproducible exploration and analysis of disease maps, 5th of December 2022
## Script purpose: Access programmatically the COVID-19 Disease Map on the MINERVA Platform
##                 Task 2: Search for drug targets
## Date: 25.11.2022
## Author: Marek Ostaszewski
##################################################

library(httr)
library(jsonlite)
library(dplyr)
library(minervar)

if(packageVersion("minervar") < "0.8.6") {
  stop("Please install package:minervar 0.8.6")
}

#########
### Recap from Task 1
#########
### Load the bioentities from the map
map <- "https://covid19map.elixir-luxembourg.org/minerva/api/"
components <- minervar::get_map_components(map)
ifn_index <- which(components$models$name == "Interferon 1 pathway")
bioentities <- components$map_elements[[ifn_index]]
list_overlays_api_call <- paste0(map, "projects/", minervar::get_default_project(map), "/overlays/")
get_overlay_api_call <- paste0(map, "projects/", minervar::get_default_project(map), "/overlays/", "557:downloadSource")
###-------------------------------------------------------------------

### To make more specific disease map queries, let's create an API stub for this project
map_project <- paste0(map,"projects/",minervar::get_default_project(map),"/")

### Let's find drug targets of a chosen drug in the entire SYSCID Map
### 'https://<map api>/projects/<project id>/drugs:search?query=aspirin'
drug <- "aspirin"
aspirin_targets <- minervar::ask_GET(paste0(map_project,"drugs:search?query=", drug), verbose = T)
aspirin_targets <- jsonlite::fromJSON(aspirin_targets)
jsonlite::write_json(aspirin_targets, path = "asp_trg.json")

###########
### Task 2.1: Save results to a file, examine content/structure using Visual Studio Code ('Format Document')
###########

### Let's reverse the query and find drugs targeting map bioentities

### For the query, we will need an alias - a unique identifier in the MINERVA PLatform 
### Let's find drugs targetting one of the biomarkers from the previous example, IFNA1 (id: 158615)
### API call: 'https://<map project api>/drugs:search?target=ALIAS:158615"
example_target <- "ALIAS:158615"
example_drugs <- minervar::ask_GET(paste0(map_project, "drugs:search?target=", example_target))
example_drugs_json <- fromJSON(example_drugs)
jsonlite::write_json(example_drugs_json, path = "example_drug.json")

###########
### Task 2.2: How many drugs target TNF? Which database supplies the evidence?
###########

###########
### Task 2.3: For identifiers from Task 1 (three overlay hits), which one has the highest number of drugs targeting it?
###########

