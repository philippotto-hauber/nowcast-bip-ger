function [dataM_stand, dataQ_stand, means, stds, flag_usestartvals, names, groups, dates, vintagedate] = f_constructdataset(dir_data, samplestart,vintage,list_removevars,means,stds) 

% ------------------------- % 
% - load datasets  -------- %  

load( [dir_data '\vintages\dataset_' num2str(year(vintage)) '_' num2str(month(vintage)) '_' num2str(day(vintage)) '.mat'] , 'dataset' ) 

% -------------------------- % 
% - get vintage date ------- %

vintagedate = vintage ; 

% ---------------------- % 
% - sample start ------- %

if min(dataset.data_ifo.dates > samplestart)
    index_ifo = 1;
    dataset.data_ifo.data = [NaN((dataset.data_ifo.dates(1) - samplestart) * 12, size(dataset.data_ifo.data, 2)); dataset.data_ifo.data];
else
    index_ifo = find(abs(dataset.data_ifo.dates - samplestart)<1e-05) ;
end
index_ESIBCI = find(abs(dataset.data_ESIBCI.dates - samplestart)<1e-05) ;
index_BuBaRTD = find(abs(dataset.data_BuBaRTD.dates - samplestart)<1e-05) ;
index_financial = find(abs(dataset.data_financial.dates - samplestart)<1e-05) ;

% --------------------------- % 
% - maximum length of data -- %
maxobs = max( [ size(dataset.data_BuBaRTD.data(index_BuBaRTD:end,:),1) , ...
                size(dataset.data_ifo.data(index_ifo:end,:),1) , ...
                size(dataset.data_ESIBCI.data(index_ESIBCI:end,:),1) , ...
                size(dataset.data_financial.data(index_financial:end,:),1) , ...
                ] ) ; 
            
% ----------------------------------------------------- % 
% - extract names, groups & flag_usestartvals  -------- %  

namesM = [dataset.data_BuBaRTD.names(strcmp(dataset.data_BuBaRTD.type,'m')), ...
            dataset.data_ifo.names(strcmp(dataset.data_ifo.type,'m')| strcmp(dataset.data_ifo.type,'q:A')), ...
            dataset.data_ESIBCI.names(strcmp(dataset.data_ESIBCI.type,'m')| strcmp(dataset.data_ESIBCI.type,'q:A')), ...
            dataset.data_financial.names(strcmp(dataset.data_financial.type,'m')) ] ;

groupsM = [dataset.data_BuBaRTD.groups(strcmp(dataset.data_BuBaRTD.type,'m')), ...
        dataset.data_ifo.groups(strcmp(dataset.data_ifo.type,'m')| strcmp(dataset.data_ifo.type,'q:A')), ...
        dataset.data_ESIBCI.groups(strcmp(dataset.data_ESIBCI.type,'m')| strcmp(dataset.data_ESIBCI.type,'q:A')), ...
        dataset.data_financial.groups(strcmp(dataset.data_financial.type,'m')) ] ;

flag_usestartvalsM = [dataset.data_BuBaRTD.flag_usestartvals(strcmp(dataset.data_BuBaRTD.type,'m')), ...
            dataset.data_ifo.flag_usestartvals(strcmp(dataset.data_ifo.type,'m')| strcmp(dataset.data_ifo.type,'q:A')), ...
            dataset.data_ESIBCI.flag_usestartvals(strcmp(dataset.data_ESIBCI.type,'m')| strcmp(dataset.data_ESIBCI.type,'q:A')), ...
            dataset.data_financial.flag_usestartvals(strcmp(dataset.data_financial.type,'m')) ] ;

namesQ = dataset.data_BuBaRTD.names(~strcmp(dataset.data_BuBaRTD.type,'m')) ;
groupsQ = dataset.data_BuBaRTD.groups(~strcmp(dataset.data_BuBaRTD.type,'m')) ;
flag_usestartvalsQ = dataset.data_BuBaRTD.flag_usestartvals(~strcmp(dataset.data_BuBaRTD.type,'m')) ;

% ------------------------------- % 
% - merge names & groups -------- %
names = [namesM namesQ] ; 
groups = [groupsM groupsQ] ; 


% -------------------------- % 
% -  data ------------------ %       

dataM = [ [ dataset.data_BuBaRTD.data(index_BuBaRTD:end,strcmp(dataset.data_BuBaRTD.type,'m')); NaN(maxobs - size(dataset.data_BuBaRTD.data(index_BuBaRTD:end,strcmp(dataset.data_BuBaRTD.type,'m')),1),size(dataset.data_BuBaRTD.data(index_BuBaRTD:end,strcmp(dataset.data_BuBaRTD.type,'m')),2))] , ...
          [ dataset.data_ifo.data(index_ifo:end,strcmp(dataset.data_ifo.type,'m')| strcmp(dataset.data_ifo.type,'q:A')); NaN(maxobs - size(dataset.data_ifo.data(index_ifo:end,strcmp(dataset.data_ifo.type,'m')| strcmp(dataset.data_ifo.type,'q:A')),1),size(dataset.data_ifo.data(index_ifo:end,strcmp(dataset.data_ifo.type,'m')| strcmp(dataset.data_ifo.type,'q:A')),2))] , ... 
          [ dataset.data_ESIBCI.data(index_ESIBCI:end,strcmp(dataset.data_ESIBCI.type,'m')| strcmp(dataset.data_ESIBCI.type,'q:A')); NaN(maxobs - size(dataset.data_ESIBCI.data(index_ESIBCI:end,strcmp(dataset.data_ESIBCI.type,'m')| strcmp(dataset.data_ESIBCI.type,'q:A')),1),size(dataset.data_ESIBCI.data(index_ESIBCI:end,strcmp(dataset.data_ESIBCI.type,'m')| strcmp(dataset.data_ESIBCI.type,'q:A')),2))] , ...   
          [ dataset.data_financial.data(index_financial:end,strcmp(dataset.data_financial.type,'m')); NaN(maxobs - size(dataset.data_financial.data(index_financial:end,strcmp(dataset.data_financial.type,'m')),1),size(dataset.data_financial.data(index_financial:end,strcmp(dataset.data_financial.type,'m')),2))] , ...
          ]' ; 
      
dataQ =   [ dataset.data_BuBaRTD.data(index_BuBaRTD:end,~strcmp(dataset.data_BuBaRTD.type,'m')); NaN(maxobs - size(dataset.data_BuBaRTD.data(index_BuBaRTD:end,~strcmp(dataset.data_BuBaRTD.type,'m')),1),size(dataset.data_BuBaRTD.data(index_BuBaRTD:end,~strcmp(dataset.data_BuBaRTD.type,'m')),2))]' ;
 
% -------------------------- % 
% - dates ------------------ % 

dates = samplestart + [0:size(dataM,2)-1]/12 ; 

% ----------------------------------------------------------------------- % 
% - merge flag_usestartvals after adjusting for partially missing obs --- % 

sumNaNs = sum(isnan(dataM),2) ;
flag_usestartvalsM(flag_usestartvalsM==1 & sumNaNs' > 0.2 * size(dataM,2)) = 0 ; 

flag_usestartvals = [flag_usestartvalsM flag_usestartvalsQ] ; 

% ------------------------------------------ % 
% - remove specified vars ------------------ %
if ~isempty(list_removevars)
    for n = 1 : length(names)
        index_remove(n) =  any(strcmp(list_removevars.names,names{n})) & any(strcmp(list_removevars.groups,groups{n})) ;
        index_keep(n) =  ~any(strcmp(list_removevars.names,names{n})) & ~any(strcmp(list_removevars.groups,groups{n}))  ;
    end
    dataM = dataM(index_keep(1:size(dataM,1)),:) ; 
    flag_usestartvals = flag_usestartvals(index_keep) ; 
    names = names(index_keep) ; 
    groups = groups(index_keep) ; 
end
% -------------------------------- % 
% - standardize ------------------ % 

if isempty(means) && isempty(stds)
    dataM_stand = NaN(size(dataM)) ; 
    for n = 1 : size(dataM,1) 
        meansM(n) = mean(dataM(n,:), 'omitnan') ; 
        stdsM(n) = std(dataM(n,:), 'omitnan') ; 

        dataM_stand(n,:) = ( dataM(n,:) - meansM(n) ) / stdsM(n) ; 
    end

    dataQ_stand = NaN(size(dataQ)) ; 
    for n = 1 : size(dataQ,1) 
        meansQ(n) = mean(dataQ(n,:), 'omitnan') ; 
        stdsQ(n) = std(dataQ(n,:), 'omitnan') ; 

        dataQ_stand(n,:) = ( dataQ(n,:) - meansQ(n) ) / stdsQ(n) ; 
    end

    means = [meansM meansQ] ; 
    stds = [stdsM stdsQ] ; 
else
    % use given means and stds to standardize variables
    dataM_stand = NaN(size(dataM)) ; 
    for n = 1 : size(dataM,1) 
        dataM_stand(n,:) = ( dataM(n,:) - means(n) ) / stds(n) ; 
    end
    
   for n = 1 : size(dataQ,1) 
        dataQ_stand(n,:) = ( dataQ(n,:) - means(size(dataM,1)+n) ) / stds(size(dataM,1)+n) ; 
   end    
end






