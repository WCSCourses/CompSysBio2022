##################################################
## Project: Reproducible exploration and analysis of disease maps, 5th of December 2022
## Script purpose: Access programmatically the COVID-19 Disease Map on the MINERVA Platform
##                 Task 0: Install necessary packages and request for exploration and analysis of disease map
## Date: 25.11.2022
## Author: Marek Ostaszewski
##################################################

### Install all the missing R packages
required.packages <- c("devtools", "dplyr", "enrichR", "httr", "igraph", "jsonlite", "xml2")
new.packages <- required.packages[!(required.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos='http://cran.us.r-project.org')


### Load the 'minervar' package
if(!("minervar" %in% installed.packages()[,"Package"])) {
  devtools::install_git(url = "https://gitlab.lcsb.uni.lu/minerva/minervar")
}

### Get the contents of the an example disease map
test <- minervar::get_map_components("https://synapsemap.lcsb.uni.lu/minerva/api/")
