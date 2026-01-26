library(collapse)

# load data ----
dat <- read.csv("C:/Users/Hauber-P/Documents/dev/Echtzeitdatensatz/vintages/vintages.csv")
dat$period <- as.Date(dat$period)
library(ggplot2)

n <- "Produzierendes Gewerbe ohne Bau"
g <- "production"

df_plt <- dat |> 
  fsubset(variable == n & group == g) |>
  fsubset(period >= "2024-01-01") 

ggplot()+
  geom_line(
    mapping = aes(x = period, y = value, group = vintage, color = vintage),
    data = fsubset(df_plt, vintage != max(df_plt$vintage))
  )+
    geom_line(
    mapping = aes(x = period, y = value),
    data = fsubset(df_plt, vintage == max(df_plt$vintage)), 
    color = "black"
  )+
  scale_x_date(date_labels = "%b/%y")
