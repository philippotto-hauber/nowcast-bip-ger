clear; close all; clc;

% set vintage
vintage = '15-Jan-2022';

% read in file
dirname = 'C:\Users\Philipp\Desktop\Echtzeitdatensatz\raw data\ESI BCI\';
filename = 'industry';
[num, txt, ~] = xlsread([ dirname filename '_total_sa_nace2.xlsx'],[filename ' MONTHLY']) ;
dates = txt(2:end, 1);
dateformat = 'dd.mm.yyyy';
%offset_dates = size(txt, 1) - size(num, 1);

% read in release dates
releasedates_tmp = readtable([ dirname 'releasedates_ESIBCI.xlsx'] );

% start with latest observation and check if it has been released

is_released = false;
t = size(num, 1) + 1; % start with latest observations (+ 1, then reduce in loop)
while ~is_released
    t = t-1;
    ind_ym_release = find(releasedates_tmp.('year') == year(dates{t}, dateformat) & ...
                            releasedates_tmp.('month') == month(dates{t}, dateformat));
    is_released = datenum(releasedates_tmp.('release_date'){ind_ym_release}) < ...
                                                                        datenum(vintage);    
end