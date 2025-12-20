function i_h = find_forecast_horizon(y)
    Nt = size(y, 2);
    h = 0;
    for t = Nt:-1:1
        if isnan(y(1, t))
            h = h + 1;
        else
            break
        end
    end
    i_h = (Nt-h)+1:Nt;
end