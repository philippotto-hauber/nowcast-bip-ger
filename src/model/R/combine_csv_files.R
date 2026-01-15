args <- commandArgs(trailingOnly = TRUE)
dir_root <- args[1]
nowcast_year <- args[2]
nowcast_quarter <- args[3]
# for debugging
# dir_root <- "C:/Users/Hauber-P/Documents/dev"
# nowcast_year <- 2025
# nowcast_quarter <- 4

dir_nowcast <- paste0(dir_root, "/Nowcasts/", nowcast_year, "Q", nowcast_quarter, "/output_csv")
patterns <- c("forecasts", "news")

for (p in patterns){
    files <- list.files(path = dir_nowcast, pattern = paste0("_", p, "_"), full.names = TRUE)
    dat_out <- do.call(
        rbind,
        lapply(files, read.csv)
    )
    
    dat_out$vintage <- readr::parse_date(dat_out$vintage, format = "%d-%b-%Y", locale = readr::locale("en"))
    if (p == "forecasts"){
      dat_out$period <- readr::parse_date(dat_out$period, format = "%d-%b-%Y", locale = readr::locale("en"))
    }
    
    write.csv(dat_out, paste0(dir_nowcast, "/", p, ".csv"), row.names = FALSE)
    file.remove(files)
}

print("Done combining output files into one csv and deleting the old files")