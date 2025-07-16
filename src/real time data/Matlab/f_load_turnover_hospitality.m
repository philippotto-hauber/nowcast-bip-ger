function data_BuBaRTD = f_load_turnover_hospitality(data_BuBaRTD, vintage, dir_rawdata)

% load vintages
dir = [dir_rawdata '/umsatz_gastgewerbe/'];
tmp = importdata([dir, 'vintages_gastgewerbe.csv'], ',');

% extract dates
tmpdates = tmp.textdata(2:end,1);
firstdate = year(tmpdates{1}) + month(tmpdates{1}) / 12 ;  
dates = firstdate + [0:size(tmp.data,1)-1]'/12;

% load date of vintages and find column corresponding to current vintage
tmpvintages = tmp.textdata(1, 2:end);
datavintages_num = datenum(tmpvintages) ; 
index_col = sum(datavintages_num <= datenum(vintage)) ; 

% removing missings from data!
tmpdata = tmp.data(:, index_col);
dates = dates(~isnan(tmpdata),1);
tmpdata = tmpdata(~isnan(tmpdata),1);

% extract data, matching size (i.e. dates) of data_BuBaRTD.rawdata and data_BuBaRTD.data
rawdata = NaN(size(data_BuBaRTD.rawdata, 1), 1);
data = NaN(size(rawdata));

% [~, i_start] = min(abs(data_BuBaRTD.dates-dates(1)));
% [~, i_end] = min(abs(data_BuBaRTD.dates-dates(end)));
i_start = find(abs(data_BuBaRTD.dates-dates(1))<1e-10);
i_end= find(abs(data_BuBaRTD.dates-dates(end))<1e-10);
rawdata(i_start:i_end, 1) = tmpdata; 
data(i_start:i_end, 1) = [NaN; 100*diff(log(tmpdata))]; 

% merge with BuBa structure
ind_turnover = find(strcmp(data_BuBaRTD.groups, 'turnover'), 1, 'last');

data_BuBaRTD.rawdata = [data_BuBaRTD.rawdata(:, 1:ind_turnover), ...
                                rawdata, ...
                                data_BuBaRTD.rawdata(:, ind_turnover+1:end)];

data_BuBaRTD.data = [data_BuBaRTD.data(:, 1:ind_turnover), ...
                                data, ...
                                data_BuBaRTD.data(:, ind_turnover+1:end)];
data_BuBaRTD.groups = [data_BuBaRTD.groups(:, 1:ind_turnover),...
                               {'turnover'},...
                               data_BuBaRTD.groups(:, ind_turnover+1:end)];

data_BuBaRTD.names = [data_BuBaRTD.names(:, 1:ind_turnover),...
                               {'hospitality'},...
                               data_BuBaRTD.names(:, ind_turnover+1:end)];

data_BuBaRTD.flag_usestartvals = [data_BuBaRTD.flag_usestartvals(:, 1:ind_turnover), ...
                                1, ...
                                data_BuBaRTD.flag_usestartvals(:, ind_turnover+1:end)];

data_BuBaRTD.seriesnames = [data_BuBaRTD.seriesnames(:, 1:ind_turnover),...
                               {''},...
                               data_BuBaRTD.seriesnames(:, ind_turnover+1:end)];
data_BuBaRTD.type = [data_BuBaRTD.type(:, 1:ind_turnover),...
                               {'m'},...
                               data_BuBaRTD.type(:, ind_turnover+1:end)];

data_BuBaRTD.trafo = [data_BuBaRTD.trafo(:, 1:ind_turnover), ...
                                3, ...
                                data_BuBaRTD.trafo(:, ind_turnover+1:end)];

data_BuBaRTD.flag_sa = [data_BuBaRTD.flag_sa(:, 1:ind_turnover), ...
                                0, ...
                                data_BuBaRTD.flag_sa(:, ind_turnover+1:end)];



