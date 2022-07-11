function data_ESIBCI = f_load_ESIBCI(vintage, dir_rawdata)

% add path data files
dirname = [dir_rawdata '/ESI BCI/'] ;

% load options like names, groups, trafos and so on 
data_ESIBCI = f_loadoptions_ESIBCI ;

% load release dates and 
%releasedates = importdata( [ dirname 'releasedates_ESIBCI.xlsx'] ) ;
releasedates_tmp = readtable([ dirname 'releasedates_ESIBCI.xlsx'] );
releases_yymm = table2array(releasedates_tmp(:, 1:2));
releases_date = table2cell(releasedates_tmp(:, 3));
index_release = find((releases_yymm(:,1) == year(vintage) & releases_yymm(:,2) == month(vintage)) == 1) ;  
%index_release = sum(datetime(vintage) >= datetime(releases_date));

% loop over different categories (industry, retail, services, etc. )
filenames = {'industry','retail','building','services','consumer'} ;
sheetnames = {'INDUSTRY','RETAIL TRADE','BUILDING','SERVICES','CONSUMER'} ;
data_ESIBCI.rawdata = [] ; 

for f = 1 : length(filenames)    
 
    % ---------------- % 
    % - monthly data - %
    
    % load xlsx  
    %[num, txt, raw] = xlsread([ dirname filenames{f} '_total_nsa_nace2.xlsx'],[sheetnames{f} ' MONTHLY']) ;
    [num, txt, ~] = xlsread([ dirname filenames{f} '_total_sa_nace2.xlsx'],[sheetnames{f} ' MONTHLY']) ;
    if strcmp( filenames{f} , 'services' )
        if size(num,1) + 1 < size(txt,1)
            num = [NaN(size(txt,1) - (size(num,1) + 1), size(num, 2)); num]; 
        end        
    end

    % get dates
    firstdatestr = txt{2,1} ; 
    dates = year(firstdatestr,'dd.mm.yyyy') + month(firstdatestr,'dd.mm.yyyy')/12 + [0:(size(num,1) - 1)]'/12; 
    dates_str = txt(2:end, 1);
    
    % get column indices of variables
    diffNcols = size(txt,2) - size(num,2) ;
    index_monthly = strcmp(data_ESIBCI.groups,['ESI: ' filenames{f}]) & strcmp(data_ESIBCI.type,'m') ;
    [~,index_cols,~] = intersect( txt(1,:),data_ESIBCI.seriesnames(index_monthly),'stable') ;

    % find end of available observations according to vintage     
    %index_row = find( abs(dates - (year(vintage) + month(vintage)/12)) <1e-05 ) ; 
	index_row = sum(datetime(dates_str) <= datetime(vintage));
    
    if datenum(releases_date{index_release,1}) < datenum(vintage) % vintage date includes this month's release!
        index_row = index_row + 1; 
    end
%     if isempty(index_row) 
%         index_row = size(num,1) ; 
%     elseif datenum(releases_date{index_release,1}) > datenum(vintage) % vintage date is before this month's publication of the ESI
%         if datenum(releases_date{index_release-1,1}) > datenum(vintage) % check that previous vintage has been released => delayed publication of December values!!!!!
%            index_row = index_row ;  
%         else
%             index_row = index_row + 1; 
%         end
%     end
    if f == 1
    disp(['vintage is : ' vintage])
    disp(['Corresponding release of the ESI: ' releases_date{index_release}])
    disp(['Data go until month ' month(datetime(txt{index_row+(size(txt,1)-size(num,1)), 1}),'name')])
    disp('--------------')
    end

    % get data
    data_ESIBCI.rawdata = [data_ESIBCI.rawdata num(1:index_row,index_cols - diffNcols)] ; 
    
    % ------------------ % 
    % - quarterly data - %    
    if strcmp(filenames{f},'industry') || strcmp(filenames{f},'services') 
        %txt = data.textdata.([sheetnames{f} 'QUARTERLY']) ; 
        %num = data.data.([sheetnames{f} 'QUARTERLY']) ; 

        [num, txt, ~] = xlsread([ dirname filenames{f} '_total_sa_nace2.xlsx'],[sheetnames{f} ' QUARTERLY']) ;

        % get column indices of variables
        diffNcols = size(txt,2) - size(num,2) ;
        index_quarterly = strcmp(data_ESIBCI.groups,['ESI: ' filenames{f}]) & not(strcmp(data_ESIBCI.type,'m')) ;
        [~,index_cols,~] = intersect( txt(1,:),data_ESIBCI.seriesnames(index_quarterly),'stable') ;

        % find end of available observations according to vintage 
        diffNrows = size(txt,1) - size(num,1) ;
        index_row = find(strcmp(txt(:,1),[num2str(year(vintage)) '-Q' num2str(ceil(month(vintage)/3))])==1) - diffNrows; 
        
        if isempty(index_row) 
            index_row = size(num,1) ; 
        elseif month(vintage)==1 && datenum(releases_date{index_release,1}) < datenum(vintage) % vintage date is before this month's publication of the ESI
            index_row = index_row - 1 ; 
        end

        % get data
        datatemp = kron(num(1:index_row,index_cols - diffNcols),[1; NaN; NaN]) ;
        
        % adjust number of rows to match monthly data
        if size(datatemp,1)>size(data_ESIBCI.rawdata,1)
            datatemp = datatemp(1:size(data_ESIBCI.rawdata,1),:) ; 
        elseif size(datatemp,1)<size(data_ESIBCI.rawdata,1) 
            datatemp = [datatemp; NaN(size(data_ESIBCI.rawdata,1)-size(datatemp,1),size(datatemp,2))] ; 
        end

        data_ESIBCI.rawdata = [data_ESIBCI.rawdata datatemp] ; 
    end
end

data_ESIBCI.dates = dates(1:size(data_ESIBCI.rawdata,1),:) ; 
% ----------------------------------------------------- 
% manually adjust data which are repeated quarterly values before Feb 2001
% ----------------------------------------------------- 

index_Jan2001 = find(abs(dates - (2001 + 1/12))<1e-05 == 1) ;
index_series = strcmp(data_ESIBCI.groups,'ESI: services') & ( strcmp(data_ESIBCI.names,'Confidence Indicator') | strcmp(data_ESIBCI.names,'Business situation development over the past 3 months') | strcmp(data_ESIBCI.names,'Evolution of the demand over the past 3 months') | strcmp(data_ESIBCI.names,'Expectation of the demand over the next 3 months') | strcmp(data_ESIBCI.names,'Evolution of the employment over the past 3 months') ) ;
data_ESIBCI.rawdata(1:index_Jan2001,index_series) = NaN ; 

index_Aug1997 = find(abs(dates - (1997 + 8/12))<1e-05 == 1) ;
index_series = strcmp(data_ESIBCI.groups,'ESI: industry') & strcmp(data_ESIBCI.names,'Employment expectations for the months ahead') ;
data_ESIBCI.rawdata(1:index_Aug1997,index_series) = NaN ; 


% -----------------------------------------------------
% - transform (and seasonally adjusted if needed)
% -----------------------------------------------------

data_trafo = NaN(size(data_ESIBCI.rawdata)) ; 
flag_dontuse = zeros(1,size(data_ESIBCI.rawdata,2)) ; 

for n = 1 : size(data_ESIBCI.rawdata,2) 
    % ------------------------ % 
    % - seasonal adjustment? - %
    % ------------------------ %
    
    %overwrite sa flag!
    data_ESIBCI.flag_sa(n) = 0 ; 
    if data_ESIBCI.flag_sa(n) == 1
        % check if we have enough observations (> 5 years)
        if sum(~isnan(data_ESIBCI.rawdata(:,n))) > 60 
            data_ESIBCI.rawdata(1,n)
            temp = f_sa(data_ESIBCI.rawdata(:,n)) ; 
        else
            % exclude from the analysis
            flag_dontuse(n) = 1 ; 
        end
    else
        temp = data_ESIBCI.rawdata(:,n) ; 
    end
    
    if strcmp(data_ESIBCI.type{n},'m')        
        switch data_ESIBCI.trafo(n)
            case 1
                data_trafo(:,n) = temp(:,1);            
            case 2
                data_trafo(:,n) = [NaN(1,1); diff(temp(:,1))]; 
            case 3
                data_trafo(:,n) = [NaN(1,1); 100*diff(log(temp(:,1)))];
        end 
    else
        % quarterly vars
        switch data_ESIBCI.trafo(n)
            case 1
                data_trafo(:,n) = temp(:,1);            
            case 2
                data_trafo(:,n) = [NaN(3,1) ; temp(4:end,1) - temp(1:end-3,1)]; 
            case 3
                data_trafo(:,n) = [NaN(3,1) ; 100*(log(temp(4:end,1)) - log(temp(1:end-3,1)))]; 
        end 
    end
end

data_ESIBCI.data = data_trafo ; 

% -----------------------------------------------------
% - remove series that could not be seasonally adjusted
% ----------------------------------------------------- 

% also remove quarterly series
%flag_dontuse(~strcmp(data_ESIBCI.type, 'm')) = 1; 

if ~all(flag_dontuse==0)
    data_ESIBCI.namesremoved = data_ESIBCI.names(flag_dontuse==1) ; 
    data_ESIBCI.data = data_ESIBCI.data(:,~flag_dontuse) ;   
    data_ESIBCI.rawdata = data_ESIBCI.rawdata(:,~flag_dontuse) ; 
    data_ESIBCI.trafo = data_ESIBCI.trafo(:,~flag_dontuse) ;  
    data_ESIBCI.names = data_ESIBCI.names(:,~flag_dontuse) ;  
    data_ESIBCI.groups = data_ESIBCI.groups(:,~flag_dontuse) ;  
    data_ESIBCI.type = data_ESIBCI.type(:,~flag_dontuse) ;
    data_ESIBCI.flag_usestartvals = data_ESIBCI.flag_usestartvals(:,~flag_dontuse) ; 
    data_ESIBCI.flag_sa = data_ESIBCI.flag_sa(:,~flag_dontuse) ; 
end

                             





