args <- commandArgs(trailingOnly = TRUE)
dir_main <- args[length(args)]

# create store_dir if it does not already exist
storedir <- paste0(dir_main, "/BuBa RTD/")
if (!dir.exists(storedir)) dir.create(storedir, recursive = TRUE)

# load function
source("get_var_codes_bbk_rtd.R")

# write function that exports data to csv
exportseries2csv <- function( x , dirname , varname ){
  filename = paste( dirname , "/" , varname , '.csv' , sep = "" , collapse = NULL)
  write.csv(x,filename, na = "" )  
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
		x <- bundesbank::getSeries(var_codes[ i ],
					   start = "1991-01",
					   end = format(Sys.Date(), "%Y-%m"),
					   return.class = "data.frame",
					   verbose = FALSE, dest.dir = NULL)
		
		# export to csv
		exportseries2csv(x, dirname, var_codes[i])
	}
	print(paste0("Done downloading ", categories[j], " series and writing to ", dirname, "!"))
}




