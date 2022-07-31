function index_row = get_row_index_esiM(dates, releasedates, vintage, dateformat)

is_released = false;
t = size(dates, 1) + 1; % start with latest observations (+ 1, then reduce in loop)
while ~is_released
    t = t-1;
    ind_ym_release = find(releasedates.('year') == year(dates{t}, dateformat) & ...
                            releasedates.('month') == month(dates{t}, dateformat));
    is_released = datenum(releasedates.('release_date'){ind_ym_release}) < ...
                                                                        datenum(vintage);    
end
index_row = t;