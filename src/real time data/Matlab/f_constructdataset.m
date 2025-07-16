function [dataM_stand, dataQ_stand, means, stds, flag_usestartvals, names, groups, dates] = f_constructdataset(samplestart,name_datasets,v) 

% ------------------------- % 
% - load datasets  -------- %  

load([name_datasets '.mat']) 

% ------------------------- % 
% - start of sample ------- %

index_ifo = find(abs(datasets.vintage(v).data_ifo.dates - samplestart)<1e-05) ;
index_ESIBCI = find(abs(datasets.vintage(v).data_ESIBCI.dates - samplestart)<1e-05) ;
index_BuBaRTD = find(abs(datasets.vintage(v).data_BuBaRTD.dates - samplestart)<1e-05) ;
index_financial = find(abs(datasets.vintage(v).data_financial.dates - samplestart)<1e-05) ;

% --------------------------- % 
% - maximum length of data -- %
maxobs = max( [ size(datasets.vintage(v).data_BuBaRTD.data(index_BuBaRTD:end,:),2) , ...
                size(datasets.vintage(v).data_ifo.data(index_ifo:end,:),2) , ...
                size(datasets.vintage(v).data_ESIBCI.data(index_ESIBCI:end,:),2) , ...
                size(datasets.vintage(v).data_financial.data(index_financial:end,:),2) , ...
                ] ) ; 
            
% ----------------------------------------------------- % 
% - extract names, groups & flag_usestartvals  -------- %  

namesM = [datasets.vintage(v).data_BuBaRTD.names(strcmp(datasets.vintage(v).data_BuBaRTD.type,'m')), ...
            datasets.vintage(v).data_ifo.names(strcmp(datasets.vintage(v).data_ifo.type,'m')| strcmp(datasets.vintage(v).data_ifo.type,'q:A')), ...
            datasets.vintage(v).data_ESIBCI.names(strcmp(datasets.vintage(v).data_ESIBCI.type,'m')| strcmp(datasets.vintage(v).data_ESIBCI.type,'q:A')), ...
            datasets.vintage(v).data_financial.names(strcmp(datasets.vintage(v).data_financial.type,'m')) ] ;

groupsM = [datasets.vintage(v).data_BuBaRTD.groups(strcmp(datasets.vintage(v).data_BuBaRTD.type,'m')), ...
        datasets.vintage(v).data_ifo.groups(strcmp(datasets.vintage(v).data_ifo.type,'m')| strcmp(datasets.vintage(v).data_ifo.type,'q:A')), ...
        datasets.vintage(v).data_ESIBCI.groups(strcmp(datasets.vintage(v).data_ESIBCI.type,'m')| strcmp(datasets.vintage(v).data_ESIBCI.type,'q:A')), ...
        datasets.vintage(v).data_financial.groups(strcmp(datasets.vintage(v).data_financial.type,'m')) ] ;

flag_usestartvalsM = [datasets.vintage(v).data_BuBaRTD.flag_usestartvals(strcmp(datasets.vintage(v).data_BuBaRTD.type,'m')), ...
            datasets.vintage(v).data_ifo.flag_usestartvals(strcmp(datasets.vintage(v).data_ifo.type,'m')| strcmp(datasets.vintage(v).data_ifo.type,'q:A')), ...
            datasets.vintage(v).data_ESIBCI.flag_usestartvals(strcmp(datasets.vintage(v).data_ESIBCI.type,'m')| strcmp(datasets.vintage(v).data_ESIBCI.type,'q:A')), ...
            datasets.vintage(v).data_financial.flag_usestartvals(strcmp(datasets.vintage(v).data_financial.type,'m')) ] ;

namesQ = datasets.vintage(v).data_BuBaRTD.names(~strcmp(datasets.vintage(v).data_BuBaRTD.type,'m')) ;
groupsQ = datasets.vintage(v).data_BuBaRTD.groups(~strcmp(datasets.vintage(v).data_BuBaRTD.type,'m')) ;
flag_usestartvalsQ = datasets.vintage(v).data_BuBaRTD.flag_usestartvals(~strcmp(datasets.vintage(v).data_BuBaRTD.type,'m')) ;

% ------------------------------- % 
% - merge names & groups -------- %
names = [namesM namesQ] ; 
groups = [groupsM groupsQ] ; 


% -------------------------- % 
% -  data ------------------ %       

dataM = [ [ datasets.vintage(v).data_BuBaRTD.data(index_BuBaRTD:end,strcmp(datasets.vintage(v).data_BuBaRTD.type,'m')); NaN(maxobs - size(datasets.vintage(v).data_BuBaRTD.data(index_BuBaRTD:end,strcmp(datasets.vintage(v).data_BuBaRTD.type,'m')),1),size(datasets.vintage(v).data_BuBaRTD.data(index_BuBaRTD:end,strcmp(datasets.vintage(v).data_BuBaRTD.type,'m')),2))] , ...
          [ datasets.vintage(v).data_ifo.data(index_ifo:end,strcmp(datasets.vintage(v).data_ifo.type,'m')| strcmp(datasets.vintage(v).data_ifo.type,'q:A')); NaN(maxobs - size(datasets.vintage(v).data_ifo.data(index_ifo:end,strcmp(datasets.vintage(v).data_ifo.type,'m')| strcmp(datasets.vintage(v).data_ifo.type,'q:A')),1),size(datasets.vintage(v).data_ifo.data(index_ifo:end,strcmp(datasets.vintage(v).data_ifo.type,'m')| strcmp(datasets.vintage(v).data_ifo.type,'q:A')),2))] , ... 
          [ datasets.vintage(v).data_ESIBCI.data(index_ESIBCI:end,strcmp(datasets.vintage(v).data_ESIBCI.type,'m')| strcmp(datasets.vintage(v).data_ESIBCI.type,'q:A')); NaN(maxobs - size(datasets.vintage(v).data_ESIBCI.data(index_ESIBCI:end,strcmp(datasets.vintage(v).data_ESIBCI.type,'m')| strcmp(datasets.vintage(v).data_ESIBCI.type,'q:A')),1),size(datasets.vintage(v).data_ESIBCI.data(index_ESIBCI:end,strcmp(datasets.vintage(v).data_ESIBCI.type,'m')| strcmp(datasets.vintage(v).data_ESIBCI.type,'q:A')),2))] , ...   
          [ datasets.vintage(v).data_financial.data(index_financial:end,strcmp(datasets.vintage(v).data_financial.type,'m')); NaN(maxobs - size(datasets.vintage(v).data_financial.data(index_financial:end,strcmp(datasets.vintage(v).data_financial.type,'m')),1),size(datasets.vintage(v).data_financial.data(index_financial:end,strcmp(datasets.vintage(v).data_financial.type,'m')),2))] , ...
          ]' ; 
      
dataQ =   [ datasets.vintage(v).data_BuBaRTD.data(index_BuBaRTD:end,~strcmp(datasets.vintage(v).data_BuBaRTD.type,'m')); NaN(maxobs - size(datasets.vintage(v).data_BuBaRTD.data(index_BuBaRTD:end,~strcmp(datasets.vintage(v).data_BuBaRTD.type,'m')),1),size(datasets.vintage(v).data_BuBaRTD.data(index_BuBaRTD:end,~strcmp(datasets.vintage(v).data_BuBaRTD.type,'m')),2))]' ;
            

% -------------------------- % 
% - dates ------------------ % 

dates = samplestart + [0:size(dataM,2)-1]/12 ; 

% ----------------------------------------------------------------------- % 
% - merge flag_usestartvals after adjusting for partially missing obs --- % 

sumNaNs = sum(isnan(dataM),2) ;
flag_usestartvalsM(flag_usestartvalsM==1 & sumNaNs' > 0.2 * size(dataM,2)) = 0 ; 

flag_usestartvals = [flag_usestartvalsM flag_usestartvalsQ] ; 

% -------------------------------- % 
% - standardize ------------------ % 

dataM_stand = NaN(size(dataM)) ; 
for n = 1 : size(dataM,1) 
    meansM(n) = nanmean(dataM(n,:)) ; 
    stdsM(n) = nanstd(dataM(n,:)) ; 
    
    dataM_stand(n,:) = ( dataM(n,:) - meansM(n) ) / stdsM(n) ; 
end

dataQ_stand = NaN(size(dataQ)) ; 
for n = 1 : size(dataQ,1) 
    meansQ(n) = nanmean(dataQ(n,:)) ; 
    stdsQ(n) = nanstd(dataQ(n,:)) ; 
    
    dataQ_stand(n,:) = ( dataQ(n,:) - meansQ(n) ) / stdsQ(n) ; 
end

means = [meansM meansQ] ; 
stds = [stdsM stdsQ] ; 


