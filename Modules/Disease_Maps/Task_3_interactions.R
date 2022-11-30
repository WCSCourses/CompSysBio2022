##################################################
## Project: Reproducible exploration and analysis of disease maps, 5th of December 2022
## Script purpose: Access programmatically the COVID-19 Disease Map on the MINERVA Platform
##                 Task 3: Interactions of bioentities
## Date: 25.11.2022
## Author: Marek Ostaszewski
##################################################

library(httr)
library(jsonlite)
library(dplyr)
library(minervar)

#########
### Recap from Tasks 1 and 2
#########
### Load the bioentities from the map
map <- "https://covid19map.elixir-luxembourg.org/minerva/api/"
components <- minervar::get_map_components(map)
ifn_index <- which(components$models$name == "Interferon 1 pathway")
bioentities <- components$map_elements[[ifn_index]]
### Create project-specific variables
map_project <- paste0(map,"projects/",minervar::get_default_project(map),"/")
###--------------------------------------------------

### Let's look at the interactions ot the map
interactions <- components$map_reactions[[ifn_index]]
interactions[1,]

### 'aliasId' in 'reactants', 'products' and 'modifiers' fields gives us participating elements
interactions[1,]$reactants
interactions[1,]$products
interactions[1,]$modifiers

### We can use a dedicated API call to find interactions with given identifiers:
### 'https://<map project api>/models/*/bioEntities/reactions/?participantId=<list of ids>'
### (https://minerva.pages.uni.lu/doc/api/16.0/project_maps.html#_get_reactions)

### Let's use the list of previous id's starting with the "TNF" to find reactions they participate in
combined_INF_ids <- paste(selected_ifn_HGNCs$id, collapse = ",")
get_interactions_api_call <- paste0(map_project,"/models/*/bioEntities/reactions/?participantId=", combined_INF_ids)

IFN_interactions <- fromJSON(minervar::ask_GET(get_interactions_api_call))

minervar::create_search_url("https://covid19map.elixir-luxembourg.org/minerva/", 
                            elements = IFN_interactions$id, prefix = "reaction:")

###########
### Task 3.1: Visualise (create a search URL) for the three-hits overlay targets
###########

###########
### Task 3.2: Create a similar search URL but without an API call
###########