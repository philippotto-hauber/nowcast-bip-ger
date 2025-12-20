function [i, m, std] = get_index_mean_std(options, name)
    i = strcmp(options.names, name) ; 
    m = options.means(i) ; 
    std = options.stds(i) ; 
end