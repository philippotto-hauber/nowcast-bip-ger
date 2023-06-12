# nowcast-bip-ger

Codes for nowcasting model of German GDP

## Running the model

Steps **before** running the model

### Manual data download


manually download latest ifo, LKW-Maut-Index, Gastgewerbeumsatz  vintages and update the respective release dates files (details to follow)

#### ifo-index

1. download latest release from the [ifo's website](https://www.ifo.de/umfrage/ifo-geschaeftsklima-deutschland). The file currently has the name format `gsk-d-YYYYMM.xlsx` where YYYY and MM are the year and month of the release

2. rename the file to `ifo_current.xlsx`and place in `*\Echtzeitdatensatz\raw data\ifo` 

3. update the release dates of the index in the file `release_dates_ifo.csv`

#### Lkw-Maut-Index

All vintages that have been released since the last time the model was run have to be downloaded

1. go to the [press portal of Destatis](https://www.destatis.de/DE/Presse/_inhalt.html) and select **Industrie und Verarbeitendes Gewerbe** and **Güterverkehr** as filters or type **Lkw Mautindex** into the search bar to get the press releases

2. to get the data corresponding to the release, open it and in the interactive figure click on the burger icon and select **CSV-Datei herunterladen**. The file currently has the name `lkw_maut_index_monatlich.csv`

3. rename the file as `lkw_index_YYYY-MM-DD.csv` where YYYY, MM and DD are the year, month and day of the release

4. move the file to `*\Echtzeitdatensatz\raw data\lkw_maut_index\releases` 

5. update the file `release_dates.csv` by entering the date of the release and the latest data point in the format e.g. 2023M4 for April 2023 

#### Gastgewerbeumsatz

Downloading the vintages for the turnover in the hospitality sector is very similar to those for the Lkw-Maut-Index

1. go to the [press portal of Destatis](https://www.destatis.de/DE/Presse/_inhalt.html) and type **Gastgewerbeumsatz** into the search bar to get the releases

2. to get the data corresponding to the release, open it and in the interactive figure click on the burger icon and select **CSV-Datei herunterladen**. The file currently has the name `umsatz-gastgewerbe.csv`

3. rename the file as `umsatz-gastgewerbe-YYYY-MM-DD.csv` where YYYY, MM and DD are the year, month and day of the release

4. move the file to `*\Echtzeitdatensatz\raw data\umsatz_gastgewerbe\releases` 

5. update the file `release_dates.csv` by entering the date of the release and the latest data point in the format e.g. 2023M3 for March 2023 

#### ESI surveys

The download of the ESI surveys is automated. However, the release dates need to be updated manually!

1. go to the list of [ESI press releases](https://economy-finance.ec.europa.eu/economic-forecast-and-surveys/business-and-consumer-surveys/download-business-and-consumer-survey-data/press-releases_en)

2. update the file `*\Echtzeitdatensatz\raw data\ESI BCI\releasedates_ESIBCI_csv.csv` by entering the date of the release and the latest data point in the format e.g. 2023M4 for April 2023 

- set `DIR_ROOT` in `run_ifw_nowcast.bat` to the directory where the folders `Echtzeitdatensatz` and `Nowcasts` are located

- specify the dates for which nowcasts are produced. Typically this will be the end of the second to last quarter of the one being nowcast, i.e. 30 March 2022 when nowcasting 2022Q3 but fewer dates are also possible. Note that in any case, the models are being estimated with data only up until December 2019!  

- set the models specifications in the script `compute_nowcasts.m` (starting in line 69). These include the number of factors `Nrs`, the number of lags in the factor VAR `Nps` and the number of lags in the idiosyncratic components `Njs`. 

Once these steps have been completed, you only need to execute the batch script and enter the year and quarter for which you want a nowcast (automatically produces forecasts for the next quarter). This will create a subfolder in `DIR_ROOT\Nowcasts`. Note that no checks are performed whether the provided list of vintages corresponds to the manual user input. 


## Comments 

The current list of vintage dates corresponds to nowcasts for the third quarter of 2022. Running the batch script with those values should reproduce the results that are already in the `Nowcasts/2022Q3` folder!

The code can take quite a while to run (~1h) when the number of vintages is large and the factor models have to be estimated. Once the vintages have already been created, the corresponding lines in the batch script can be commented out. Similarly, if estimates of the factor models' parameters already exist, setting the flag `estimate_models` to 0 in `compute_nowcasts.m` can save a bit of time. 

Matlab currently produces the following error when running in headless mode:

``
Dot indexing is not supported for variables of this type.

ERROR: MATLAB error Exit Status: 0x00000001
``
As far as I can tell, this can be safely ignored in the sense that the code nevertheless produces the correct results! 

## Next steps

- details on output that is generated
