function f_table(nowcast,revision,groupcontribs,vintages,savename,groupnames,dirname)

% prepare group contributions and names
ind_temp = 1;
index_group = strcmp(groupnames,'ESI') | strcmp(groupnames,'ifo');
temp_groupcontrib(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'surveys';
ind_temp = ind_temp + 1;
index_group = strcmp(groupnames,'production') ; 
temp_groupcontrib(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'production' ; 
ind_temp = ind_temp + 1;
index_group = strcmp(groupnames,'orders') ; 
temp_groupcontrib(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'orders';
ind_temp = ind_temp + 1;
index_group = strcmp(groupnames,'turnover') ; 
temp_groupcontrib(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'turnover' ;
ind_temp = ind_temp + 1;
index_group = strcmp(groupnames,'financial') ; 
temp_groupcontrib(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'financial' ; 
ind_temp = ind_temp + 1;
index_group = strcmp(groupnames,'labor market') ; 
temp_groupcontrib(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'labor market' ; 
ind_temp = ind_temp + 1;
index_group = strcmp(groupnames,'prices') ; 
temp_groupcontrib(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'prices';
ind_temp = ind_temp + 1;
index_group = strcmp(groupnames,'national accounts') ; 
temp_groupcontrib(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'national accounts' ; 

if length(tempnames) ~= 8
    error('Number of categories does not match number of variables in table. Abort!')
end

% create table
names_table = ['Prognose', tempnames, 'Revision'];
T = table(nowcast', ...
    temp_groupcontrib(1,:)', ...
    temp_groupcontrib(2,:)', ...
    temp_groupcontrib(3,:)', ...
    temp_groupcontrib(4,:)', ...
    temp_groupcontrib(5,:)', ...
    temp_groupcontrib(6,:)', ...
    temp_groupcontrib(7,:)', ...
    temp_groupcontrib(8,:)', ...
    revision',...
    'VariableNames',names_table,...
    'RowNames',vintages);                     

% export to xls
writetable(T,[dirname '\tables\' savename '.xlsx'],'WriteRowNames',true) 


