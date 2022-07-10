function data_financial = f_load_financial(vintage, dir_rawdata)

% -----------------------------------------------------
% - add path for functions and data files
% -----------------------------------------------------
dirname = [dir_rawdata '/Finanzmarktdaten/'] ;
% -----------------------------------------------------
% - load options like names, groups, trafos and so on 
% -----------------------------------------------------
data_financial = f_loadoptions_financialdataBuBa ;

% -----------------------------------------------------
% - manually set first date
% -----------------------------------------------------
firstdatenum_master = 1991 + 1/12 ; % January 1991

% -----------------------------------------------------
% - monthly data
% -----------------------------------------------------  

data_financial.rawdata = [] ; 
nheader = 1; % number of lines to skip before reading in numeric values
for n = 1 : length(data_financial.seriesnames)     
    temp = importdata([ dirname data_financial.seriesnames{n} '.csv'],',',nheader) ; 
    temp_firstdate = temp.textdata{ 2 , 2 } ; 
    %numnans = floor( ( (year(temp_firstdate) + month(temp_firstdate)/12 ) - firstdatenum_master ) * 12 ) ; 
    numnans = size(data_financial.rawdata, 1) - size(temp.data, 1); 
    data_financial.rawdata = [ data_financial.rawdata [ NaN( numnans , 1 ) ; temp.data ] ] ; 
end

% adjust dates
data_financial.dates = firstdatenum_master + [0 : size( data_financial.rawdata , 1 ) - 1] /12 ; 

% -----------------------------------------------------
% - pseudo real-time adjustment
% -----------------------------------------------------
month_v = month(vintage) ;
year_v = year(vintage) ;
if isempty(find( abs((year_v + month_v / 12 - data_financial.dates )) < 1e-10 ))
    ind_end = size(data_financial.rawdata,1) ; 
else
    ind_end = find( abs((year_v + month_v / 12 - data_financial.dates )) < 1e-10 ) - 1 ; 
end

data_financial.rawdata = data_financial.rawdata(1 : ind_end, : ) ; 
data_financial.dates = data_financial.dates(1 : ind_end ) ; 

% -----------------------------------------------------
% - transform (and seasonally adjusted if needed)
% -----------------------------------------------------

data_trafo = NaN(size(data_financial.rawdata)) ; 
flag_dontuse = zeros(1,size(data_financial.rawdata,2)) ; 

for n = 1 : size(data_financial.rawdata,2) 
    % ------------------------ % 
    % - seasonal adjustment? - %
    % ------------------------ %
    
    if data_financial.flag_sa(n) == 1
        % check if we have enough observations (> 5 years)
        if sum(~isnan(data_financial.rawdata(:,n))) > 60 
            temp = f_sa(data_financial.rawdata(:,n)) ; 
        else
            % exclude from the analysis
            flag_dontuse(n) = 1 ; 
        end
    else
        temp = data_financial.rawdata(:,n) ; 
    end
    
    if strcmp(data_financial.type{n},'m')        
        switch data_financial.trafo(n)
            case 1
                data_trafo(:,n) = temp(:,1);            
            case 2
                data_trafo(:,n) = [NaN(1,1); diff(temp(:,1))]; 
            case 3
                data_trafo(:,n) = [NaN(1,1); 100*diff(log(temp(:,1)))];
        end 
    else
        % quarterly vars
        switch data_financial.trafo(n)
            case 1
                data_trafo(:,n) = temp(:,1);            
            case 2
                data_trafo(:,n) = [NaN(3,1) ; temp(4:end,1) - temp(1:end-3,1)]; 
            case 3
                data_trafo(:,n) = [NaN(3,1) ; 100*(log(temp(4:end,1)) - log(temp(1:end-3,1)))]; 
        end 
    end
end

data_financial.data = data_trafo ; 

% -----------------------------------------------------
% - remove series that could not be seasonally adjusted
% ----------------------------------------------------- 

if ~all(flag_dontuse==0)
    data_financial.namesremoved = data_financial.names(flag_dontuse==1) ; 
    data_financial.data = data_financial.data(:,~flag_dontuse) ;   
    data_financial.rawdata = data_financial.rawdata(:,~flag_dontuse) ; 
    data_financial.trafo = data_financial.trafo(:,~flag_dontuse) ;  
    data_financial.names = data_financial.names(:,~flag_dontuse) ;  
    data_financial.groups = data_financial.groups(:,~flag_dontuse) ;  
    data_financial.type = data_financial.type(:,~flag_dontuse) ;
    data_financial.flag_usestartvals = data_financial.flag_usestartvals(:,~flag_dontuse) ; 
    data_financial.flag_sa = data_financial.flag_sa(:,~flag_dontuse) ; 
end


