# This code loads the vintages for truck toll mileage that were manually downloaded
# from Destatis' website. It merges these with vintages for the period 2019M12020M8 that 
# were made available through Destatis directly. The results are exported to a csv file 
# with the vintage date as columns!

args <- commandArgs(trailingOnly = TRUE)
dir_main <- args[length(args)]

# keep this comment for future debugging sessions
# dir_main <- "G:/Geteilte Ablagen/02_Konjunktur/04_Prognose/9_Prognosemodelle/03_DFM/Echtzeitdatensatz/raw data"

dirname <- paste0(dir_main, "/lkw_maut_index/")

vintages <- read.csv(file = paste0(dirname, "release_dates_lkw_maut.csv"))
vintages <- list.files(path = paste0(dirname, "releases/"), pattern = "lkw_maut_index_", full.names = TRUE)
filename <- "lkw_maut_index_"

extract_date_from_filename <- function(f){
  len_f <- nchar(f)
  d <- as.Date(substr(f, len_f - 13, len_f - 4))
  stopifnot(class(d) == "Date")
  return(d)
}

#----- READ IN CSV VINTAGES

dat <- data.frame()
for (v in vintages)
{
  tmp <- read.csv2(v)
  
  col_date <- grep("Monat", names(tmp))
  
  # hard-code because column name changes over time! 
  col_val <- 2
  
  # "dates" in format YYYY-MM
  if (nchar(tmp[1, col_date]) > 7)
    tmp[, col_date] <- substr(tmp[, col_date], 1, 7)
  
  dat <- rbind(dat, data.frame(date = lubridate::make_date(year = substr(tmp[, col_date], 1, 4), 
                                                           month = substr(tmp[, col_date], 6, 7)), 
                               vintage = extract_date_from_filename(v),
                               value = tmp[, col_val])
               )               
}

#----- MERGE WITH EARLIER VINTAGES
load(paste0(dirname, "vintages_destatis_2019M12020M8.Rda"))

df <- rbind(df, dat)

#----- CONVERT TO WIDE FORMAT
df_wide <- tidyr::pivot_wider(df, names_from = "vintage", values_from = "value")

df_wide <- dplyr::arrange(df_wide, date)

df_wide <- dplyr::filter(df_wide, date >= "2015-01-01")

# convert date to format YYYY-MM
df_wide$date <- ifelse(lubridate::month(df_wide$date)>=10,
                       paste0(lubridate::year(df_wide$date), "-", lubridate::month(df_wide$date)),
                       paste0(lubridate::year(df_wide$date), "-0", lubridate::month(df_wide$date))
                      )

#----- EXPORT AS CSV
write.csv(df_wide, 
          file = paste0(dirname, "vintages_lkwmautindex.csv"), 
          row.names = F,
          quote = T,
          na = "")

print("Done compiling real-time truck toll mileage data!")



