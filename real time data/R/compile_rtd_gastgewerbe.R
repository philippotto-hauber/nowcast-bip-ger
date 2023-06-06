args <- commandArgs(trailingOnly = TRUE)
dir_main <- args[length(args)]
#dir_main <- "C:/Users/Philipp/Desktop/Echtzeitdatensatz/raw data"

dirname <- paste0(dir_main, "/umsatz_gastgewerbe/")

vintages <- read.csv(file = paste0(dirname, "release_dates.csv"))

filename <- "umsatz-gastgewerbe-"

dat <- data.frame()
for (i in seq(1, nrow(vintages)))
{
  tmp <- read.csv2(paste0(dirname, "/releases/", filename, vintages[i, 1], ".csv"))
  
  col_date = grep("Monat", names(tmp))
  col_val_orig = grep("Original", names(tmp))
  col_val_sa = grep("saisonbereinigt", names(tmp))
  
  # "dates" in format YYYY-MM
  if (nchar(tmp[1, col_date]) > 7)
    tmp[, col_date] <- substr(tmp[, col_date], 1, 7)
  
  dat <- rbind(dat, data.frame(dates = tmp[, col_date], 
                               values = tmp[, col_val_sa],
                               vintage = vintages[i, 1])
               )
}

dat_wide <- tidyr::pivot_wider(dat, names_from = "vintage", values_from = "values")

write.csv(dat_wide, 
          file = paste0(dirname, "vintages_gastgewerbe.csv"), 
          row.names = F,
          quote = T,
          na = "")

print("Done compiling real-time hospitality turnover data!")

