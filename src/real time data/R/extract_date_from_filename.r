extract_date_from_filename <- function(f){
  len_f <- nchar(f)
  d <- as.Date(substr(f, len_f - 13, len_f - 4))
  stopifnot(class(d) == "Date")
  return(d)
}