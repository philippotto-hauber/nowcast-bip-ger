function [t, k_news] = write_news_to_table(t, k_news, chunk, ...
    tmp_weights, tmp_actuals, tmp_forecasts, tmp_impacts, tmp_varnames, tmp_groupnames, ...
    tmp_period, tmp_vintage, tmp_model, tmp_target)

    cap = height(t);

    % number of rows to write (assumes all tmp_* vectors have same length)
    n_news = length(tmp_weights);

    need = k_news + n_news;
    if need > cap
        disp('making t_news bigger')
        newcap = cap + ceil(chunk / 2);

        % Extend ALL columns of the table used here
        t.vintage(newcap,1)  = NaT;
        t.target(newcap,1)   = "";
        t.period(newcap,1)   = "";
        t.model(newcap,1)    = "";
        t.variable(newcap,1)  = "";
        t.group(newcap,1) = "";
        t.weights(newcap,1)  = NaN;
        t.actual(newcap,1)  = NaN;
        t.forecast(newcap,1)= NaN;
        t.impacts(newcap,1)  = NaN;

        cap = newcap;
    end

    idx = (k_news+1):need;

    % Fill table columns with the temporary variables
    t.weight(idx)   = tmp_weights;
    t.actual(idx)   = tmp_actuals;
    t.forecast(idx) = tmp_forecasts;
    t.impact(idx)   = tmp_impacts;
    t.variable(idx)  = tmp_varnames;
    t.group(idx)   = tmp_groupnames;
    t.period(idx)    = repmat(tmp_period, n_news, 1);
    t.vintage(idx)   = repmat(datetime(tmp_vintage), n_news, 1);
    t.model(idx)     = repmat(tmp_model, n_news, 1);
    t.target(idx)    = repmat(tmp_target, n_news, 1);
    k_news = need;

end
