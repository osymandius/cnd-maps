library(jsonlite)
library(tidyverse)

inputs <- list.files(path="inputs")
lengthFiles <- length(inputs)
conceptNames <- substr(inputs, 1, nchar(inputs)-4)
blankCountries <- read.csv("blankCountries.csv", header=TRUE, stringsAsFactors=FALSE)
blankCountries$id <- paste(blankCountries$id,"-4") ## In this line, replace the 3 at the end with the number that matches up to the country id in this year's map that you've uploaded to cndblog.org
blankCountries$id <- gsub(" ", "", blankCountries$id)

conceptList <- lapply(inputs, function(x) {
  read.csv(paste0("inputs/", x), header=TRUE, stringsAsFactors=FALSE)
})

names(conceptList)[1:lengthFiles] <- conceptNames

## If you add new categories, you will have to add them into good or bad. Remember the names in good or bad must /exactly/ match the file name (without the extension)
bad <- c("deathpenalty", "drugfreeworld")
good <- c("decrim", "accesscontrolledmedicines", "gender", "harmreduction", "humanrights", "legalregulation", "Proportionality", "SDGs", "treatyreform")


mapply(x=conceptList, n=conceptNames, function(x, n) {
  x %>%
    left_join(blankCountries, by="title") %>%
    mutate(fill = if(n %in% bad) {
      ifelse(.[2] == "against", "#81d742", "#dd3333")
    } else {
      ifelse(.[2] == "against", "#dd3333", "#81d742")
    }) %>%
    write_json(path=paste0("outputs/", n, "-out"))
})