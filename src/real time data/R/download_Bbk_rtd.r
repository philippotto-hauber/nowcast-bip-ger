# args <- commandArgs(trailingOnly = TRUE)
# dir_main <- args[length(args)]
# for debugging
dir_main <- "C:/Users/Hauber-P/Documents/Echtzeitdatensatz/raw data"
# create store_dir if it does not already exist
storedir <- paste0(dir_main, "/BuBa RTD/")
if (!dir.exists(storedir)) dir.create(storedir, recursive = TRUE)

# load function
source(here::here("src", "real time data", "R", "get_var_codes_bbk_rtd.R"))
source(here::here("src", "real time data", "R", "bbk_get_series.R"))

# write function that exports data to csv
exportseries2csv <- function( x , dirname , varname ){
  filename = paste( dirname , "/" , varname , '.csv' , sep = "" , collapse = NULL)
  write.csv(x,filename, na = "", row.names = FALSE )  
}

# set categories
categories <- c("production", "orders", "turnover", "prices", "labor market", "national accounts")
# loop over categories
for ( j in 1 : length(categories) ){
  
	dirname <- paste(storedir, categories[j] , sep = "" , collapse = NULL)
  if (!dir.exists(dirname)) dir.create(dirname)

		# get var codes
	var_codes <- get_var_codes_bbk_rtd( categories[j] )
	  
	# loop over variables
	for( i in 1 : length(var_codes) ){
		
		# get series from Bundesbank website
		# x <- bundesbank::getSeries(var_codes[ i ],
		# 			   start = "1991-01",
		# 			   end = format(Sys.Date(), "%Y-%m"),
		# 			   return.class = "data.frame",
		# 			   verbose = FALSE, dest.dir = NULL)
		x <- bbk_get_series(
			var_codes[i], 
			start_period = ifelse(categories[j] == "national accounts", "1991-Q1", "1991-01"), 
			format = "wide"
		)
		
		# export to csv
		exportseries2csv(x, dirname, var_codes[i])
	}
	print(paste0("Done downloading ", categories[j], " series and writing to ", dirname, "!"))
}




