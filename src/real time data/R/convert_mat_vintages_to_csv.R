args <- commandArgs(trailingOnly = TRUE)
dir_main <- args[length(args)]
# for debugging
# dir_main <- "C:/Users/Hauber-P/Documents/dev/Echtzeitdatensatz/vintages"

# functions ----

get_index <- function(lst, nm, d = 1){
  out <- grep(nm, dimnames(lst)[[d]])
  if (length(out) == 0) {
    stop(paste0("nm not found in dimnames of dimension ", d))
  }
  return(out)
}

convert_dates <- function(d){
  # dates in Matlab are constructed as year + month/12, so that 2025 equals 2024M12!!!
  rem <- d - floor(d)
  if (rem == 0){
    y <- floor(d) - 1 
    m <- 12
  } else {
    y <- floor(d)
    m <- round(rem * 12)  
  }
  return(as.Date(paste0(y, "-", ifelse(m > 9, as.character(m), paste0("0", m)), "-01")))
}

get_name_group_trafo <- function(lst){
  df_aux <- data.frame(
    variable = as.vector(unlist(lst[[get_index(lst, "^names$")]])),
    group = as.vector(unlist(lst[[get_index(lst, "^groups$")]])),
    trafo = as.vector(lst[[get_index(lst, "^trafo$")]])
  )
  df_aux$col_id <- seq(1, nrow(df_aux))
  return(df_aux)
}

wrangle_raw_and_transformed_data <- function(lst, df_aux, vintage){
  raw_dat <- as.data.frame(lst[[get_index(lst, "rawdata")]])
  dat <- as.data.frame(lst[[get_index(lst, "^data$")]])

  raw_dat <- round(raw_dat, 4)
  dat <- round(dat, 4)

  colnames(raw_dat) <- df_aux$variable 
  colnames(dat) <- df_aux$variable
  
  dates_conv <- sapply(lst[[get_index(lst, "dates")]], convert_dates) 
  # not sure why sapply returns a vector of numerics but this seems to fix it
  dates_conv <- as.Date(dates_conv)   
  
  raw_dat <- collapse::add_vars(raw_dat, period = dates_conv, pos = 1)
  dat <- collapse::add_vars(dat, period = dates_conv, pos = 1)

  df_dat <- data.frame()
  for (g in unique(df_aux$group)){
    df_aux_g <- collapse::fsubset(df_aux, group == g)
  
  
    df_dat_g <- collapse::join(
      collapse::pivot(
        raw_dat[, c(1, df_aux_g$col_id + 1)], 
        ids = "period",
        names = list("variable", "raw"), 
        how = "longer"
      ),
     collapse::pivot(
        dat[, c(1, df_aux_g$col_id + 1)], 
        ids = "period",
        names = list("variable", "value"), 
        how = "longer"
      ),
     on = c("period", "variable"),
     how = "left",
     verbose = 0
    ) |> collapse::join(
      df_aux_g, 
      on = c("variable"),
      how = "left",
      verbose = 0
    ) 
    
    df_dat <- rbind(
      df_dat, df_dat_g
    )
  }
  
  df_dat$vintage <- vintage
  df_dat <- collapse::fselect(df_dat, -col_id)
  
  return(df_dat)
  
}


wrapper <- function(lst_all, data_source){
  lst <- lst_all[[get_index(lst_all, data_source)]]
  df_out <- wrangle_raw_and_transformed_data(
    lst,
    get_name_group_trafo(lst),
    as.character(lst_all[[get_index(lst_all, "vintagedate")]])
  )
  return(df_out)
}

# loop over vintages, then variable groups ----
vintages <- list.files(
  path = dir_main,
  pattern = "dataset_",
  full.names = TRUE
)

df_out <- data.frame()
sources <- c("data_ifo", "data_ESIBCI", "data_BuBaRTD", "data_financial")
for (v in vintages){
  dat <- R.matlab::readMat(v, fixNames = FALSE)

  for (s in sources){
    df_out <- rbind(
      df_out, 
      wrapper(dat$dataset, s)
    )
  }  
}

write.csv(
  df_out,
  file = paste0(dir_main, "/vintages.csv"),
  row.names = FALSE
)

print(paste0("Done converting mat vintages to csv and writing to", paste0(dir_main, "/vintages.csv")))