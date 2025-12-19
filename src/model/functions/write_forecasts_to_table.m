function [t, k_fore] = write_forecasts_to_table(t, k_fore, chunk, data_new, Z, ks_output_new, dates, vint, model, names, groups, means, stds)
    cap = height(t);
    for i = 1:size(data_new, 1)

        ind_forecasthorizon = find_forecast_horizon(data_new(i, :));
        tmp_fore = stds(i)* (Z(i,:) * ks_output_new.stT(:, ind_forecasthorizon)) + means(i);
        n_fore = length(tmp_fore);
        tmp_dates = datetime(dates(ind_forecasthorizon), 'InputFormat','yyyy-MM');
        tmp_model = repmat(model, n_fore, 1);
        tmp_vintage = datetime(repmat(vint, n_fore, 1));
        tmp_variable = repmat(names{i}, n_fore, 1);
        tmp_group = repmat(groups{i}, n_fore, 1);

        need = k_fore + n_fore;
        if need > cap
            disp('making t_fore bigger')
            newcap = cap + ceil(chunk / 2);
                t.vintage(newcap,1)  = NaT;
                t.period(newcap,1)   = NaT;
                t.model(newcap,1)    = "";
                t.variable(newcap,1) = "";
                t.group(newcap,1)    = "";
                t.value(newcap,1) = NaN;
            cap = newcap;
        end

        idx = (k_fore+1):need;
        t.value(idx) = tmp_fore;
        t.period(idx) = tmp_dates;
        t.vintage(idx) = tmp_vintage; 
        t.model(idx) = tmp_model; 
        t.variable(idx) = tmp_variable;
        t.group(idx) = tmp_group;

        k_fore = need;
    end
    
end