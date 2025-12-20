clear; close all; clc;

addpath('functions')

dir_data = 'C:\Users\Philipp\Desktop\Echtzeitdatensatz';
vintages = importdata('../dates_vintages.txt');
samplestart = 1996 + 1/12 ; 
date_forecast = 2023 + 9/12; 
options.dates = samplestart:1/12:date_forecast ; 
list_removevars = determine_vars_remove(dir_data, vintages, samplestart, options.dates);
writecell(list_removevars.namegroup, [dir_data, '\list_vars_removed.txt'])
