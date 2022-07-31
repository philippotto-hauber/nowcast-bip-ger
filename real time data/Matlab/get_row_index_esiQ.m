function index_row = get_row_index_esiQ(dates, releasedates, vintage)

is_released = false;
t = size(dates, 1) + 1; % start with latest observations (+ 1, then reduce in loop)
while ~is_released
    t = t-1;
    ind_ym_release = find(releasedates.('year') == str2double(dates{t}(1:4)) & ...
                            releasedates.('month') == str2double(dates{t}(end))*3-2);
    is_released = datenum(releasedates.('release_date'){ind_ym_release}) < ...
                                                                        datenum(vintage);    
end
index_row = t;