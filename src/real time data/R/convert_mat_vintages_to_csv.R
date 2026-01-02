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
  
  raw_dat$period = dates_conv
  dat$period = dates_conv
  
  df_dat <- collapse::join(
    collapse::pivot(
      raw_dat, 
      ids = "period",
      names = list("variable", "raw"), 
      how = "longer"
    ),
   collapse::pivot(
      dat, 
      ids = "period",
      names = list("variable", "value"), 
      how = "longer"
    ),
   on = c("period", "variable"),
   how = "left",
   verbose = 0
  ) |> collapse::join(
    df_aux, 
    on = c("variable"),
    how = "left",
    verbose = 0
  )
  
  df_dat$vintage <- vintage
  
  return(df_dat)
  
}

# loop over vintages ----
vintages <- list.files(
  path = dir_main,
  pattern = "dataset_",
  full.names = TRUE
)

df_out <- data.frame()
for (v in vintages){
  dat <- R.matlab::readMat(v, fixNames = FALSE)
  lst_ifo <- dat$dataset[[get_index(dat$dataset, "data_ifo")]]
  df_out <- rbind(
      df_out,
      wrangle_raw_and_transformed_data(
        lst_ifo,
        get_name_group_trafo(lst_ifo),
        as.character(dat$dataset[[get_index(dat$dataset, "vintagedate")]])
      )
  )
  
  lst_esi <- dat$dataset[[get_index(dat$dataset, "data_ESIBCI")]]
  df_out <- rbind(
    df_out,
    wrangle_raw_and_transformed_data(
      lst_esi,
      get_name_group_trafo(lst_esi),
      as.character(dat$dataset[[get_index(dat$dataset, "vintagedate")]])
    )
  )
  
  lst_bbk <- dat$dataset[[get_index(dat$dataset, "data_BuBaRTD")]]
  df_out <- rbind(
    df_out,
    wrangle_raw_and_transformed_data(
      lst_bbk,
      get_name_group_trafo(lst_bbk),
      as.character(dat$dataset[[get_index(dat$dataset, "vintagedate")]])
    )
  )
  
  lst_financial <- dat$dataset[[get_index(dat$dataset, "data_financial")]]
  df_out <- rbind(
    df_out,
    wrangle_raw_and_transformed_data(
      lst_financial,
      get_name_group_trafo(lst_financial),
      as.character(dat$dataset[[get_index(dat$dataset, "vintagedate")]])
    )
  )
}

write.csv(
  df_out,
  file = paste0(dir_main, "/vintages.csv"),
  row.names = FALSE
)

