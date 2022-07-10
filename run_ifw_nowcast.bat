@echo off

set DIR_ROOT=C:/Users/Philipp/Desktop/Echtzeitdatensatz
ECHO Downloading data...
cd "real time data\R\"
Rscript --vanilla download_bbk_rtd.R "%DIR_ROOT%/raw data"
Rscript --vanilla download_bbk_financial_data.R "%DIR_ROOT%/raw data"
Rscript --vanilla download_esi.R "%DIR_ROOT%/raw data"
Rscript --vanilla compile_rtd_gastgewerbe.R "%DIR_ROOT%/raw data"
Rscript --vanilla compile_rtd_lkw_maut_index.R "%DIR_ROOT%/raw data"

ECHO Constructing real-time vintages...
cd ..\Matlab
matlab -noFigureWindows -batch "construct_realtime_vintages('%DIR_ROOT%').m"

cd ..\..
cmd /k