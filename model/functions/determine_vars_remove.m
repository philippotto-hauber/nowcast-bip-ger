function list_removevars = determine_vars_remove(dir_data, vintages, samplestart, dates)
list_removevars = {};
for v = 2:length(vintages)
    [dataM, dataQ, ~, ~, ~, names_old, groups_old, ~, ~] = f_constructdataset(dir_data, samplestart,vintages{ v-1 },[],[],[]) ; 
    data_old = [[dataM; dataQ] NaN(size(dataM,1) + size(dataQ,1) , length(dates) - size(dataM,2))] ;
    
    [dataM, dataQ, ~, ~, ~, names_new, groups_new, ~, ~] = f_constructdataset(dir_data, samplestart,vintages{ v },[],[],[]) ; 
    data_new = [[dataM; dataQ] NaN(size(dataM,1) + size(dataQ,1) , length(dates) - size(dataM,2))] ;
    
    % check names
    if isempty(setdiff(names_new, names_old)) && isempty(setdiff(names_old, names_new))
        newobs = ~isnan(data_new) & isnan(data_old);
        n_newobs = sum(newobs, 2);
        if any(n_newobs>1)
            list_removevars = [list_removevars,names_new(n_newobs>1)];
        end
    else
        error('Not the same variables in two adjacent vintages! Abort and manually check vintage construction!')
    end
    list_removevars = unique(list_removevars);
end