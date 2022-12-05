##################################################
## Project: Reproducible exploration and analysis of disease maps, 5th of December 2022
## Script purpose: Access programmatically the COVID-19 Disease Map on the MINERVA Platform
##                 Task 1: Bioentities and their annotations
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

### The address of the COVID-19 Disease Map in MINERVA
map <- "https://covid19map.elixir-luxembourg.org/minerva/api/"

### Let's retrieve the components
components <- minervar::get_map_components(map)
### In case of connectivity problems, map components can be loaded from an .Rd file
# load(file = "c19dm_components.Rd")

### MINERVA allows multiple (sub)maps; the COVID-19 Disease Map has 23
### the first one is the overview diagram, let's access the Interferon 1 pathway
ifn_index <- which(components$models$name == "Interferon 1 pathway")
bioentities <- components$map_elements[[ifn_index]]
bioentities[2,]$references
### In case of problems with viewing nested data frames in RStudio
### we can flatten "bioentities" for viewing purposes
flat_bioentities <- jsonlite::flatten(bioentities, recursive = TRUE)

### Example 1.1: Annotations and identifiers
### Let's check what kind of bioentities we have in the map
table(bioentities$type)

### Let's examine the data structure of the first 10
jsonlite::write_json(path = "bioentities.json", bioentities[1:10,])

### Let's find bioentities with HGNC symbols starting with "IFN".
### First, let's gather information about all HGNC symbols in the bioentities list
### using 'minervar::get_components_annotations' function and then grep for entries starting with "IFN"
ifn_HGNCs <- minervar::get_components_annotations(components, "HGNC_SYMBOL", simple = FALSE)[[ifn_index]]
selected_ifn_HGNCs <- dplyr::filter(ifn_HGNCs, startsWith(resource, "IFN")) ### contains duplicates!

### Using these results we can find identifiers of these elements and create a search URL for them
minervar::create_search_url(mnv_url = "https://covid19map.elixir-luxembourg.org/minerva/",
                            elements = selected_ifn_HGNCs$id)

### Example 1.2: Data overlays
### Let's access data overlays in COVID-19 Disease Map

### The package 'minervar' does not support this query yet, we use the following MINERVA API call:
### https://minerva.pages.uni.lu/doc/api/16.0/project_overlays.html
### 
### To list data overlays in the COVID-19 Disease Map we need to use the API call
### 'https://<map api>/projects/<project id>/overlays/'
### 
### earlier call: minervar::get_map_components(map) used a default project
### to compose this API call, we will use a 'minervar::get_default_project(map)'

list_overlays_api_call <- paste0(map, "projects/", minervar::get_default_project(map), "/overlays/")
list_of_overlays <- jsonlite::fromJSON(minervar::ask_GET(list_overlays_api_call))

### Important! These are only public overlays; for user overlays, we need to log in and use a token

### To get an overlay, we use the following MINERVA API call:
### 'https://<map api>/projects/<project id>/overlays/<idObject>:downloadSource'

get_overlay_api_call <- paste0(map, "projects/", minervar::get_default_project(map), "/overlays/", "557:downloadSource")
overlay_data <- minervar::ask_GET(get_overlay_api_call)

### This is not a JSON structure, we need to parse it; '\t' are field separators, '\n' are line separators
### We can use read.table to parse it, but the overlay contains both a comment line (first) and hex codes with '#'
read.table(text = overlay_data, sep = "\t", header = T, comment.char = "")

#################
### Hands on task: find identifiers of "Interferon 1 pathway" elements that match identifiers
### in three overlays for airway secretory cells 
#################
