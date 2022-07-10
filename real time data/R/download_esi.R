args <- commandArgs(trailingOnly = TRUE)
dir_main <- args[length(args)]

# create store_dir if it does not already exist
dir_dest <- paste0(dir_main, "/ESI BCI/")
if (!dir.exists(dir_dest)) dir.create(dir_dest)

url_data <- "https://ec.europa.eu/economy_finance/db_indicators/surveys/documents/series/nace2_ecfin_2206/all_surveys_total_sa_nace2.zip"
file_dest <- paste0(dir_dest, "tmp.zip")
download.file(url_data, destfile = file_dest, quiet = TRUE)
unzip(file_dest, exdir = dir_dest)
unlink(file_dest)
print("Done downloading ESI series!")