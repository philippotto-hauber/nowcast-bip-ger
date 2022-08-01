function dates_str = f_convertdates( dates_num ) 

dates_str = cell( length( dates_num ) , 1 ) ; 
for t = 1 : length( dates_num ) 
    date_year = floor( dates_num( t ) ) ;
    date_month = ( dates_num( t ) - floor( dates_num( t ) ) ) * 12 ; 
    if date_month == 0
        temp = [num2str(date_year - 1) '-' num2str(12)]  ;  
    else
        temp = [num2str(date_year) '-' num2str(date_month)] ; 
    end
    dates_str{ t , 1 } = temp ; 
end
