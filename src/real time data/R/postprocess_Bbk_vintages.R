args <- commandArgs(trailingOnly = TRUE)
dir_main <- args[length(args)]
# for debugging
# dir_main <- "C:/Users/Hauber-P/Documents/dev/Echtzeitdatensatz/raw data"
subdirs <- c("labor market", "national accounts", "orders", "prices", "production", "turnover")

for (s in subdirs){
  # clean up
  for (suffix in c("_num", "_dates", "_vintages")){
    files_to_delete <- list.files(
      path = paste0(dir_main, "/Buba RTD/", s), 
      pattern = paste0(suffix, ".csv"), 
      full.names = TRUE
    )
    
    file.remove(files_to_delete)
  }
  
  # now loop over original Bbk vintages
  files <- list.files(path = paste0(dir_main, "/Buba RTD/", s), pattern = ".csv", full.names = TRUE)

  for (f in files){
    dat <- read.csv(
      file = f,
      check.names = FALSE
    )

    dates <- dat[, 1]
    num <- dat[, 2:ncol(dat)]
    vintages <-colnames(dat)[2:ncol(dat)]

    write.table(t(dates), paste0(substr(f, 1, nchar(f)- 4), "_dates.csv"), row.names = FALSE, col.names = FALSE, sep = ",")
    write.table(num, paste0(substr(f, 1, nchar(f)- 4), "_num.csv"), row.names = FALSE, col.names = FALSE, na = "NaN")
    write.table(t(vintages), paste0(substr(f, 1, nchar(f)- 4), "_vintages.csv"), row.names = FALSE, col.names = FALSE, sep = ",")

    
  }
  print(paste0("Done post-processing files!"))
}


