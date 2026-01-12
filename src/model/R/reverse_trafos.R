reverse_trafo <- function(start_value, trafo, values){
  out <- vector(mode = "numeric", length = length(values))
  for (t in seq(1, length(values))){
    if (t == 1){
      out[t] <- switch(
        trafo,
        values[t],
        start_value + values[t],
        exp(log(start_value) + values[t] / 100)
      )
    } else {
      out[t] <- switch(
        trafo,
        values[t],
        out[t-1] + values[t],
        exp(log(out[t-1]) + values[t] / 100)
      )
    }
  }
  return(out)
}