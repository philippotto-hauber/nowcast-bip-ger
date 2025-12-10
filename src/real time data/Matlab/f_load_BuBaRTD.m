function data_BuBaRTD = f_load_BuBaRTD(vintage, dir_rawdata)

% -------------------------------------------- %
% - add paths for functions and data files
% -------------------------------------------- %
addpath([ dir_rawdata '/BuBa RTD']) 
addpath([ dir_rawdata '/BuBa RTD/production']) 
addpath([ dir_rawdata '/BuBa RTD/orders'])
addpath([ dir_rawdata '/BuBa RTD/turnover'])
addpath([ dir_rawdata '/BuBa RTD/prices'])
addpath([ dir_rawdata '/BuBa RTD/labor market'])
addpath([ dir_rawdata '/BuBa RTD/national accounts'])

% -------------------------------------------- %
% - load options like names, groups, trafos and so on
% -------------------------------------------- %
data_BuBaRTD = f_loadoptions_BuBaRTD ;

% -------------------------------------------- %
% - loop over vars
% -------------------------------------------- %
firstdate_master = 1991 + 1/12 ; 
data_BuBaRTD.rawdata = [] ; 
flag_novintage = zeros( 1 , length(data_BuBaRTD.names) ) ; 
for n = 1 : length(data_BuBaRTD.names) 
    
    % load data, dates and vintages
    dir_tmp = [ dir_rawdata '\BuBa RTD\' data_BuBaRTD.groups{n} '\' data_BuBaRTD.seriesnames{n}];
    num = readtable([ dir_tmp '_num.csv']);
    dates = readmatrix([ dir_tmp '_dates.csv'], 'OutputType','string');
    firstdate = year(dates(1)) + month(dates(1)) / 12 ;  
    tempvintages =  readmatrix([ dir_tmp '_vintages.csv'], 'OutputType','string');
    datavintages_num = datenum(tempvintages) ; 

    clearvars dates tempvintages
 
    % get column index corresponding to latest available vintage
    index_col = sum(datavintages_num <= datenum(vintage)) ; 
     
    % store data
    if index_col>0
        if strcmp(data_BuBaRTD.type{n},'m')
            data{:,n} = num(:,index_col) ;
            dates{:,n} = firstdate + [0:size(num,1)-1]'/12 ;
            enddates(n) = firstdate + (size(num,1)-1)/12 ;
        elseif strcmp(data_BuBaRTD.type{n},'q:E')
            data{:,n} = kron(num(:,index_col),[NaN; NaN; 1]) ; 
            dates{:,n} = firstdate + [0:(size(num,1)*3-1)]'/12 ;
            enddates(n) = firstdate + (size(num,1)*3-1)/12 ;
        end
    else
        flag_novintage(1,n) = 1 ; 
    end
end



% for n = 1 : length(data_BuBaRTD.names)
%     temp = dates{1,n}; 
%     if ~isempty(temp)
%         enddates(n) = temp(length(temp)) ;
%     end
% end

lastenddate = max(enddates) ; 

for n = 1 : length(data_BuBaRTD.names)    
    tempdata = data{1,n} ; 
    tempdates = dates{1,n} ; 
    missingsstart = [] ; 
    index_start = 1 ; 
    if ~isempty(tempdates)
        if tempdates(1)<firstdate_master % series start before master date, 1991-01
            index_start = find(abs(tempdates-firstdate_master)<1e-05) ; 

        elseif tempdates(1)>firstdate_master % insert missing until series actually starts
            missingsstart = NaN(round((tempdates(1)-firstdate_master)*12),1) ; 
        end

        missingsend = [] ; 
        if tempdates(end)<lastenddate
            missingsend =  NaN(round((lastenddate-tempdates(end))*12),1) ; 
        end

        %size([missingsstart; tempdata(index_start:end) ; missingsend])
        rawdata(:,n) = [missingsstart; tempdata(index_start:end) ; missingsend] ; 
    end
end

 
% ----------------------------------------------------------- %
% - adjust names, groups, trafos etc. for missing vintages
% ----------------------------------------------------------- %
data_BuBaRTD.rawdata = rawdata(:,~flag_novintage) ; 
data_BuBaRTD.names_novintage = data_BuBaRTD.names(flag_novintage == 1) ; 
data_BuBaRTD.names = data_BuBaRTD.names(~flag_novintage) ; 
data_BuBaRTD.groups = data_BuBaRTD.groups(~flag_novintage) ; 
data_BuBaRTD.trafo = data_BuBaRTD.trafo(~flag_novintage) ; 
data_BuBaRTD.type = data_BuBaRTD.type(~flag_novintage) ; 
data_BuBaRTD.flag_sa = data_BuBaRTD.flag_sa(~flag_novintage) ; 
data_BuBaRTD.flag_usestartvals = data_BuBaRTD.flag_usestartvals(~flag_novintage) ; 

% -------------------------------------------- %
% - remove all NaN rows
% -------------------------------------------- %

data_BuBaRTD.rawdata = data_BuBaRTD.rawdata(~all(isnan(data_BuBaRTD.rawdata),2),:) ; 
data_BuBaRTD.dates = firstdate_master + [0:size(data_BuBaRTD.rawdata,1)-1]'/12 ;

% -----------------------------------------------------
% - transform (and seasonally adjusted if needed)
% -----------------------------------------------------

data_trafo = NaN(size(data_BuBaRTD.rawdata)) ; 
flag_dontuse = zeros(1,size(data_BuBaRTD.rawdata,2)) ; 

for n = 1 : size(data_BuBaRTD.rawdata,2) 
    temp = data_BuBaRTD.rawdata(:,n) ;
    if strcmp(data_BuBaRTD.type{n},'m')        
        switch data_BuBaRTD.trafo(n)
            case 1
                data_trafo(:,n) = temp(:,1);            
            case 2
                data_trafo(:,n) = [NaN(1,1); diff(temp(:,1))]; 
            case 3
                data_trafo(:,n) = [NaN(1,1); 100*diff(log(temp(:,1)))];
        end 
    else
        % quarterly vars
        switch data_BuBaRTD.trafo(n)
            case 1
                data_trafo(:,n) = temp(:,1);            
            case 2
                data_trafo(:,n) = [NaN(3,1) ; temp(4:end,1) - temp(1:end-3,1)]; 
            case 3
                data_trafo(:,n) = [NaN(3,1) ; 100*(log(temp(4:end,1)) - log(temp(1:end-3,1)))]; 
                %data_trafo(:,n) = [NaN(3,1) ; 100*(temp(4:end,1) ./ temp(1:end-3,1))-100]; 
        end 
    end
end

data_BuBaRTD.data = data_trafo ; 

