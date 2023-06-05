function list_removevars = determine_vars_remove(dir_data, vintages, samplestart, dates)
list_removevars.names = {};
list_removevars.groups = {};
for v = 2:length(vintages)
    [dataM, dataQ, ~, ~, ~, names_old, groups_old, ~, ~] = f_constructdataset(dir_data, samplestart,vintages{ v-1 },[],[],[]) ; 
    data_old = [[dataM; dataQ] NaN(size(dataM,1) + size(dataQ,1) , length(dates) - size(dataM,2))] ;
    
    [dataM, dataQ, ~, ~, ~, names_new, groups_new, ~, ~] = f_constructdataset(dir_data, samplestart,vintages{ v },[],[],[]) ; 
    data_new = [[dataM; dataQ] NaN(size(dataM,1) + size(dataQ,1) , length(dates) - size(dataM,2))] ;
    
    % check names
    if all(strcmp(names_new, names_old)) && all(strcmp(groups_new, groups_old))
        newobs = ~isnan(data_new) & isnan(data_old);
        n_newobs = sum(newobs, 2);
        if any(n_newobs>1)
            list_removevars.names = [list_removevars.names,names_new(n_newobs>1)];
            list_removevars.groups = [list_removevars.groups,groups_new(n_newobs>1)];
        end
    else
        error('Not the same variables in two adjacent vintages! Abort and manually check vintage construction!')
    end
    list_removevars.namegroup = strcat(list_removevars.names(:), '_', list_removevars.groups(:));
    if ~all(strcmp(unique(list_removevars.namegroup, 'stable'), list_removevars.namegroup))
        error('duplicates in series to be removed. check manually')
    end
end