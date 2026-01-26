args <- commandArgs(trailingOnly = TRUE)
dir_main <- args[1]
dir_repo <- args[2]

# keeps this comment for future debugging sessions
#dir_main <- "C:/Users/Philipp/Desktop/Echtzeitdatensatz/raw data"


vintages <- list.files(path = paste0(dir_repo, "/aux_real_time_data/releases/umsatz_gastgewerbe/"), pattern = "umsatz-gastgewerbe-", full.names = TRUE)

source(here::here("src", "real time data", "R", "extract_date_from_filename.R"))

dat <- data.frame()
for (v in vintages)
{
  tmp <- read.csv2(v)
   
  col_date = grep("Monat", names(tmp))
  # hard-code column indices because after 2023 both real and nominal values are reported
  col_val_sa= ifelse(extract_date_from_filename(v) == "2022-12-19", 2, 3)
  
  # "dates" in format YYYY-MM
  if (nchar(tmp[1, col_date]) > 7)
    tmp[, col_date] <- substr(tmp[, col_date], 1, 7)
  
  dat <- rbind(dat, data.frame(dates = tmp[, col_date], 
                               values = tmp[, col_val_sa],
                               vintage = extract_date_from_filename(v))
               )
}

dat_wide <- tidyr::pivot_wider(dat, names_from = "vintage", values_from = "values")

dir_store <- paste0(dir_main, "/umsatz_gastgewerbe/")
if (!dir.exists(dir_store)) dir.create(dir_store, recursive = TRUE)
write.csv(dat_wide, 
          file = paste0(dir_store, "vintages_gastgewerbe.csv"), 
          row.names = F,
          quote = T,
          na = "")

print(paste0("Done compiling real-time hospitality turnover data and storing to ", dir_store, "!"))

