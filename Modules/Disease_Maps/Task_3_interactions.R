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
library(purrr)

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


### Let's work with an external network
### OmniPathDB will be used, pulled directly using an API call, or loaded locally

# omnipath_query <- httr::GET("https://omnipathdb.org/interactions/?fields=sources,references&datasets=omnipath,pathwayextra,kinaseextra,ligrecextra,dorothea,tf_target&genesymbols=1")
# omnipath_network <- httr::content(omnipath_query, type = "text/tab-separated-values", 
#                                   show_col_types = FALSE, encoding = "UTF-8")
# omnipath_network <- dplyr::filter(omnipath_network, is_directed == 1 & consensus_direction == 1) %>% 
#   dplyr::select(source_genesymbol, target_genesymbol, is_directed, consensus_direction, references)
# write.table(omnipath_network, file = "omnipath_network.tsv", sep = "\t",
#             col.names = T, row.names = F, quote = F)

omnipath_network <- read.table("omnipath_network.tsv", sep = "\t", header = T)

### Let's filter the OmniPath network to interactions only invovling selected IFNs

ifn_network <- dplyr::filter(omnipath_network, 
                             source_genesymbol %in% selected_ifn_HGNCs$resource |
                               target_genesymbol %in% selected_ifn_HGNCs$resource)

### Let's create a CellDesigner diagram from this network
### First, greate a GPML diagram (simple graphical representation)
tm_gpml <- minervar::network_to_gpml(
  source_table = cbind(source = ifn_network$source_genesymbol, 
                       target = ifn_network$target_genesymbol,
                       type = purrr::map_chr(ifn_network$consensus_direction, 
                                             ~ ifelse(. == 1, "activation", "inhibition"))))
### Second, convert the diagram into a CellDesigner file
cat(tm_gpml, file = "./textmining.gpml")
tm_cd <- minervar::convert_format("./textmining.gpml", "GPML", "CellDesigner_SBML")
cat(tm_cd, file = "./textmining.xml")

### Finally, let's download the IFN1 diagram and combine the contents
ifn_diagram <- minervar::download_diagram(map_api = map, project_id = minervar::get_default_project(map), 
                                          diagram_id = 936) ### components$models$idObject[ifn_index]
cat(ifn_diagram, file = "./ifn_cd.xml")

merged_diagram <- minervar::merge_unzipped_files(c("./textmining.xml", "./ifn_cd.xml"))

cat(merged_diagram, file = "./final_cd.xml")

###########
### Task 3.2: Construct an expanded network for overlay genes, and merge it with the IFN diagram
###########
