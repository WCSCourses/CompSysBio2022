#############
### Solutions
#############

#############
### Task 1
#############

### Get all data overlays
all_data <- lapply(list_of_overlays$idObject[1:3],
                   function(ido) minervar::ask_GET(paste0(map, "projects/", minervar::get_default_project(map), "/overlays/", ido, ":downloadSource")))

### Convert data overlays to data tables
all_data_tables <- lapply(all_data,
                          function(data) read.table(text = data, sep = "\t", header = T, comment.char = ""))

### Create a list of gene symbols common for all three overlays
overlay_names <- c(all_data_tables[[1]]$name, all_data_tables[[2]]$name, all_data_tables[[3]]$name)

### Get the identifiers with HGNC symbols matching these names
overlay_ifn_HGNCs <- dplyr::filter(ifn_HGNCs, resource %in% overlay_names)

### Create the search url based on the acquired ids
minervar::create_search_url(mnv_url = "https://covid19map.elixir-luxembourg.org/minerva/",
                            elements = overlay_ifn_HGNCs$id)


###########
### Task 2.2: How many drugs target TNF? Which database supplies the evidence?
###########

### TNF targets are in `example_drugs_json` data.frame; the number of drug targets is given by:
nrow(example_drugs_json)

### To get the information about source databases, we can look into "references" and collect the "type" field
table(sapply(example_drugs_json$references, "[[", "type"))

###########
### Task 2.3: For identifiers from Task 1 (three overlay hits), which one has the highest number of drugs targeting it?
###########

#############
### Solution
#############

### See solution for Task 1 for `overlay_hits`

### Let's cycle through the aliases and fetch all drugs targeting the biomarkers
all_drugs <- sapply(overlay_ifn_HGNCs$id, 
                    function(x) fromJSON(ask_GET(paste0(map_project, "drugs:search?target=ALIAS:", x))))

### We can now ask about the length of each entry, for non-empty lists
sapply(all_drugs, function(x) ifelse(length(x) == 0, 0, nrow(x)))

### Combining this with the overlay hits table gives us the answer

cbind(overlay_ifn_HGNCs, 
      drugs_targetting = sapply(all_drugs, function(x) ifelse(length(x) == 0, 0, nrow(x))))

###########
### Task 3.1: Visualise (create a search URL) for the three-hits overlay targets
###########

###########
### Solution
###########

### We combine the overlay_hits ids into a substring and use it in an API query to find reactions with these elements
combined_three_overlay_ids <- paste(overlay_ifn_HGNCs$id, collapse = ",")
get_my_interactions_api_call <- paste0(map_project,"/models/*/bioEntities/reactions/?participantId=", combined_three_overlay_ids)

### We parse the output and create the search url
minervar::create_search_url("https://covid19map.elixir-luxembourg.org/minerva/", 
                            elements = fromJSON(minervar::ask_GET(get_my_interactions_api_call))$id, prefix = "reaction:")

###########
### Task 3.2: Create a similar search URL but without an API call
###########

###########
### Solution
###########

### We have all the information we need in the `interactions` list

### Let's create a helper function that, for a given "reaction" returns TRUE/FALSE 
### for a given element id being in its reactants/products/modifiers
overlay_reaction_match <- 
  sapply(interactions[["reactants"]], 
         function(x) any(x[["aliasId"]] %in% overlay_ifn_HGNCs$id)) |
  sapply(interactions[["products"]], 
         function(x) any(x[["aliasId"]] %in% overlay_ifn_HGNCs$id)) |
  sapply(interactions[["modifiers"]], 
         function(x) any(x[["aliasId"]] %in% overlay_ifn_HGNCs$id))

### From this, we can get the reaction ids and use as above
interactions[["id"]][overlay_reaction_match]

### And we can see that the results overlap
all(fromJSON(minervar::ask_GET(get_my_interactions_api_call))$id %in% interactions[["id"]][overlay_reaction_match])

