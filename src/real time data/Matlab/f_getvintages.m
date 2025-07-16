function [ vintages_dd_mstr_yyyy , Nvintages ] = f_getvintages( year_start , month_start , year_end , month_end )

Nvintages = year_end * 12 + month_end - year_start * 12 - month_start + 1 ;
month_current = month_start ; 
year_current = year_start ; 
for v = 1 : Nvintages   
    
    % vintages in format Jan2000, Feb2000 , etc.
    [ ~ , month_string ] = month( [ num2str( year_current ) '-' num2str( month_current ) '-01' ] ) ;
    vintages_dd_mstr_yyyy{ v } = [ '28-' month_string '-' num2str( year_current ) ] ; 
    
    if month_current == 12 
        month_current = 1 ; 
        year_current = year_current + 1 ; 
    else
        month_current = month_current + 1 ; 
    end
end

