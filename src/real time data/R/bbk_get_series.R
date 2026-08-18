# bundesbank_vintages.R
#
# Download time series (including real-time "vintages"/revisions) from the
# Deutsche Bundesbank SDMX Web Service.
#
# API docs: https://www.bundesbank.de/en/statistics/time-series-databases/help-for-sdmx-web-service
#
# A Bundesbank series code such as
#   BBKRT.Q.DE.Y.A.AG1.CA010.V.A
# is "<flowRef>.<dot-separated dimension key>". For real-time-database
# flows (flowRef "BBKRT"), the CSV endpoint returns a matrix with one column
# per publication ("vintage") date and one row per observation period, i.e.
# exactly the revision history of the series. For ordinary (non-real-time)
# flows the same endpoint returns a single-column series, and the function
# below handles both cases.

library(httr)

#' Download a Bundesbank series (optionally with all real-time vintages)
#'
#' @param key          Full series code, e.g. "BBKRT.Q.DE.Y.A.AG1.CA010.V.A".
#'                      The part before the first dot is used as the SDMX
#'                      flowRef, the rest as the dimension key.
#' @param start_period  Optional start period in the series' native frequency
#'                      notation (e.g. "2000-Q1", "2000-01", "2000").
#' @param end_period    Optional end period, same notation as start_period.
#' @param format        "long" (default, tidy: one row per period x vintage)
#'                      or "wide" (one row per period, one column per vintage).
#' @param drop_na       In "long" format, drop rows with no value (i.e. the
#'                      observation had not yet been published as of that
#'                      vintage). Default TRUE.
#' @param timeout_sec   Request timeout in seconds.
#'
#' @return A data.frame. In "long" format: series_key, period, period_date,
#'         vintage, value. In "wide" format: period plus one column per
#'         vintage date.
bbk_get_series <- function(key,
                            start_period = NULL,
                            end_period   = NULL,
                            format       = c("long", "wide"),
                            drop_na      = TRUE,
                            timeout_sec  = 60) {

  format <- match.arg(format)

  parts <- strsplit(key, ".", fixed = TRUE)[[1]]
  if (length(parts) < 2) {
    stop("`key` must be a dot-separated series code of the form ",
         "'<FLOWREF>.<dim1>.<dim2>....', e.g. ",
         "'BBKRT.Q.DE.Y.A.AG1.CA010.V.A'", call. = FALSE)
  }
  flow_ref   <- parts[1]
  series_key <- paste(parts[-1], collapse = ".")

  url <- sprintf("https://api.statistiken.bundesbank.de/rest/data/%s/%s",
                  flow_ref, series_key)

  query <- list(format = "csv", lang = "en")
  if (!is.null(start_period)) query$startPeriod <- start_period
  if (!is.null(end_period))   query$endPeriod   <- end_period

  resp <- httr::GET(url, query = query, httr::timeout(timeout_sec))

  if (httr::status_code(resp) >= 400) {
    info <- tryCatch(
      httr::content(resp, as = "parsed", type = "application/json"),
      error = function(e) NULL
    )
    msg <- if (!is.null(info$title)) info$title else httr::content(resp, as = "text", encoding = "UTF-8")
    stop(sprintf("Bundesbank API request failed (HTTP %s) for key '%s':\n%s\nURL: %s",
                  httr::status_code(resp), key, msg, url), call. = FALSE)
  }

  raw_text <- httr::content(resp, as = "text", encoding = "UTF-8")
  bom <- intToUtf8(0xFEFF)
  if (substr(raw_text, 1, 1) == bom) raw_text <- substring(raw_text, 2)  # strip UTF-8 BOM

  tbl <- utils::read.csv(text = raw_text, header = FALSE, sep = ",",
                          quote = "\"", colClasses = "character",
                          stringsAsFactors = FALSE, check.names = FALSE)

  # Row 1 (minus the empty first cell) holds the vintage/publication dates.
  vintage_raw  <- as.character(unlist(tbl[1, -1]))
  vintage_date <- as.Date(vintage_raw, format = "%d.%m.%Y")
  if (anyNA(vintage_date)) {
    warning("Some vintage dates could not be parsed (left as NA): ",
             paste(vintage_raw[is.na(vintage_date)], collapse = ", "),
             call. = FALSE)
  }

  # Data rows are the ones whose first column is an observation period
  # (starts with a digit); everything above is metadata (frequency, unit,
  # source, decimals, ...).
  is_data_row <- grepl("^[0-9]", trimws(tbl[[1]]))
  if (!any(is_data_row)) {
    stop("No data rows found in the response for key '", key, "'.", call. = FALSE)
  }

  period  <- trimws(tbl[[1]][is_data_row])
  val_mat <- as.matrix(tbl[is_data_row, -1, drop = FALSE])
  storage.mode(val_mat) <- "double"  # empty strings become NA

  if (format == "wide") {
    wide <- as.data.frame(val_mat, stringsAsFactors = FALSE)
    names(wide) <- as.character(vintage_date)
    wide <- cbind(period = period, wide)
    rownames(wide) <- NULL
    return(wide)
  }

  n_period <- length(period)
  n_vint   <- length(vintage_date)

  out <- data.frame(
    series_key  = key,
    period      = rep(period, times = n_vint),
    period_date = rep(.bbk_period_to_date(period), times = n_vint),
    vintage     = rep(vintage_date, each = n_period),
    value       = as.vector(val_mat),
    stringsAsFactors = FALSE
  )

  if (drop_na) out <- out[!is.na(out$value), ]

  out <- out[order(out$period_date, out$vintage), ]
  rownames(out) <- NULL
  out
}

# Convert a Bundesbank observation-period label ("1991-Q1", "2020-05",
# "2020-05-01" or "2020") to a Date.
.bbk_period_to_date <- function(period) {
  out <- as.Date(rep(NA_character_, length(period)))

  is_q <- grepl("^[0-9]{4}-Q[1-4]$", period)
  if (any(is_q)) {
    yr <- as.integer(substr(period[is_q], 1, 4))
    q  <- as.integer(substr(period[is_q], 7, 7))
    out[is_q] <- as.Date(sprintf("%d-%02d-01", yr, (q - 1) * 3 + 1))
  }

  is_m <- grepl("^[0-9]{4}-[0-9]{2}$", period)
  if (any(is_m)) out[is_m] <- as.Date(paste0(period[is_m], "-01"))

  is_d <- grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", period)
  if (any(is_d)) out[is_d] <- as.Date(period[is_d])

  is_y <- grepl("^[0-9]{4}$", period)
  if (any(is_y)) out[is_y] <- as.Date(paste0(period[is_y], "-01-01"))

  out
}

# ---------------------------------------------------------------------------
# Example usage
# ---------------------------------------------------------------------------
if (sys.nframe() == 0 && interactive()) {
  gdp_vintages <- bbk_get_series("BBKRT.Q.DE.Y.A.AG1.CA010.V.A")
  head(gdp_vintages)

  # e.g. the latest available vintage as of today, per period:
  latest <- do.call(rbind, lapply(split(gdp_vintages, gdp_vintages$period_date), function(d) {
    d[which.max(d$vintage), ]
  }))

  # e.g. plot the full revision history for a single quarter:
  # one_quarter <- subset(gdp_vintages, period == "2019-Q4")
  # plot(one_quarter$vintage, one_quarter$value, type = "s")
}
