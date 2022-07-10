function data_BuBaRTD = f_load_lkw_maut_index(data_BuBaRTD, vintage, dir_rawdata)

% load vintages
dir = [dir_rawdata '/lkw_maut_index/'];
tmp = importdata([dir, 'vintages_lkwmautindex.csv'], ',');

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
% [~, i_end] = min(abs(data_BuBaRTD.dates-dates(end))); % these don't work
% properly because they will always return a value even if the end or
% start dates do not coincide
i_start = find(abs(data_BuBaRTD.dates-dates(1))<1e-10);
i_end= find(abs(data_BuBaRTD.dates-dates(end))<1e-10);
ind_production = find(strcmp(data_BuBaRTD.groups, 'production'), 1, 'last'); % place variables at end of production group

if isempty(i_end) % extend sample by 1 month
    rawdata = [NaN(i_start-1, 1); tmpdata]; 
    data = [NaN(i_start-1, 1); NaN; 100*diff(log(tmpdata))]; 
    
    data_BuBaRTD.rawdata = [[data_BuBaRTD.rawdata(:, 1:ind_production); ...
                             NaN(1, size(data_BuBaRTD.rawdata(:, 1:ind_production), 2))],...
                            rawdata, ...
                             [data_BuBaRTD.rawdata(:, ind_production+1:end); ...
                              NaN(1, size(data_BuBaRTD.rawdata(:, ind_production+1:end), 2))],...
                            ];

    data_BuBaRTD.data = [[data_BuBaRTD.data(:, 1:ind_production); ...
                             NaN(1, size(data_BuBaRTD.data(:, 1:ind_production), 2))],...
                            data, ...
                             [data_BuBaRTD.data(:, ind_production+1:end); ...
                              NaN(1, size(data_BuBaRTD.data(:, ind_production+1:end), 2))],...
                            ];
                            
    data_BuBaRTD.dates = [data_BuBaRTD.dates; data_BuBaRTD.dates(end) + 1/12]; 
else
    rawdata(i_start:i_end, 1) = tmpdata; 
    data(i_start:i_end, 1) = [NaN; 100*diff(log(tmpdata))]; 
    data_BuBaRTD.rawdata = [data_BuBaRTD.rawdata(:, 1:ind_production), ...
                                rawdata, ...
                                data_BuBaRTD.rawdata(:, ind_production+1:end)];

    data_BuBaRTD.data = [data_BuBaRTD.data(:, 1:ind_production), ...
                                data, ...
                                data_BuBaRTD.data(:, ind_production+1:end)];
end
                            
% merge rest with BuBa structure
data_BuBaRTD.groups = [data_BuBaRTD.groups(:, 1:ind_production),...
                               {'production'},...
                               data_BuBaRTD.groups(:, ind_production+1:end)];

data_BuBaRTD.names = [data_BuBaRTD.names(:, 1:ind_production),...
                               {'lkw_maut'},...
                               data_BuBaRTD.names(:, ind_production+1:end)];

data_BuBaRTD.flag_usestartvals = [data_BuBaRTD.flag_usestartvals(:, 1:ind_production), ...
                                1, ...
                                data_BuBaRTD.flag_usestartvals(:, ind_production+1:end)];

data_BuBaRTD.seriesnames = [data_BuBaRTD.seriesnames(:, 1:ind_production),...
                               {''},...
                               data_BuBaRTD.seriesnames(:, ind_production+1:end)];
data_BuBaRTD.type = [data_BuBaRTD.type(:, 1:ind_production),...
                               {'m'},...
                               data_BuBaRTD.type(:, ind_production+1:end)];

data_BuBaRTD.trafo = [data_BuBaRTD.trafo(:, 1:ind_production), ...
                                3, ...
                                data_BuBaRTD.trafo(:, ind_production+1:end)];

data_BuBaRTD.flag_sa = [data_BuBaRTD.flag_sa(:, 1:ind_production), ...
                                0, ...
                                data_BuBaRTD.flag_sa(:, ind_production+1:end)];



