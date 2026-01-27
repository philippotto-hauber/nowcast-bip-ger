library(collapse)

vintages <- read.csv("C:/Users/Hauber-P/Documents/Echtzeitdatensatz/vintages/vintages.csv")

# function to calculate revisions between two vintages
calc_revisions <- function(data, v1, v2) {
  df_1 <- data |> 
    fsubset(!is.na(raw) & !is.na(value) & vintage == v1) |> 
    fselect(period, group, variable, raw_v1 = raw)
  
  df_2 <- data |> 
    fsubset(!is.na(raw) & !is.na(value) & vintage == v2) |> 
    fselect(period, group, variable, raw_v2 = raw)
  
  res <- collapse::join(
    df_1, df_2,
    on = c("group", "variable", "period"),
    how = "inner"
  ) |>
    fsubset(raw_v1 != raw_v2) |> 
    fmutate(
      revision = (raw_v2 / raw_v1 - 1) * 100,
      abs_rev = abs(revision)
    ) |> 
    roworder(-abs_rev) |> 
    fselect(-abs_rev) 
  return(res)
}
# calculate revisions 
test <- calc_revisions(data = vintages, v1 = "2025-12-30", v2 = "2026-01-15")

head(test, 10)
