function index_row = get_row_index_vintage(dates, releasedates, vintage, freq, dateformat)

is_released = false;
t = size(dates, 1) + 1; % start with latest observations (+ 1, then reduce in loop)
while ~is_released
    t = t-1;
    if strcmp(freq, 'm')
        ind_ym_release = find(releasedates.('year') == year(dates{t}, dateformat) & ...
                                releasedates.('month') == month(dates{t}, dateformat));
        if isempty(ind_ym_release)
            error('Could not find date. Check that the ifo/ESI release dates files is up to date!!!')
        end
    elseif strcmp(freq, 'q')
        % assumes that quarterly values are published in the first month of
        % the quarter!
        ind_ym_release = find(releasedates.('year') == str2double(dates{t}(1:4)) & ...
                                releasedates.('month') == str2double(dates{t}(end))*3-2);
    else
        error('freq has to either be m or q')
    end
    is_released = datenum(releasedates.('release_date')(ind_ym_release)) <= ...
                                                                        datenum(vintage);    
end
index_row = t;