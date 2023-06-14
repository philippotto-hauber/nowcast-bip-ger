rm(list = ls())
# This code loads the vintages for truck toll mileage that were manually downloaded
# from Destatis' website. It merges these with vintages for the period 2019M12020M8 that 
# were made available through Destatis directly. The results are exported to a csv file 
# with the vintage date as columns!

library(lubridate)
library(dplyr)
library(tidyr)

dirname <- "C:/Users/Philipp/Documents/Echtzeitdatensatz/raw data/lkw_maut_index/"

vintages <- read.csv(file = paste0(dirname, "release_dates_lw_maut.csv"))

filename <- "lkw_maut_index_"

#----- READ IN CSV VINTAGES

dat <- data.frame()
for (i in seq(1, nrow(vintages)))
{
  tmp <- read.csv2(paste0(dirname, filename, vintages[i, 1], ".csv"))
  
  # "dates" in format YYYY-MM
  if (nchar(tmp[1, 1]) > 7)
    tmp[, 1] <- substr(tmp[, 1], 1, 7)
  
  dat <- rbind(dat, data.frame(date = make_date(year = substr(tmp[,1], 1, 4), 
                                                 month = substr(tmp[, 1], 6, 7)), 
                               value = tmp[, 2],
                               vintage = vintages[i, 1])
               )
}

#----- MERGE WITH EARLIER VINTAGES
load(paste0(dirname, "vintages_2019M12020M8.Rda"))

df <- rbind(df, dat)

#----- CONVERT TO WIDE FORMAT
df_wide <- tidyr::pivot_wider(df, names_from = "vintage", values_from = "value")

# convert date to format YYYY-MM
df_wide$date <- ifelse(month(df_wide$date)>=10,
                       paste0(year(df_wide$date), "-", month(df_wide$date)),
                       paste0(year(df_wide$date), "-0", month(df_wide$date))
                      )

#----- EXPORT AS CSV
write.csv(df_wide, 
          file = paste0(dirname, "vintages_lkwmautindex.csv"), 
          row.names = F,
          quote = T,
          na = "")



