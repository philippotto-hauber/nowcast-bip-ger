function flag_missing = checkvintages(vintages, dir_data)
dirname = [dir_data '\vintages\'] ;
flag_missing = zeros( length( vintages ) , 1 ) ; 
for v = 1 : length( vintages )
    vintyear = year( vintages{ v } ) ; 
    vintmonth = month( vintages{ v } ) ; 
    vintday = day( vintages{ v } ) ; 
    if exist([dirname 'dataset_' num2str( vintyear ) '_' num2str( vintmonth ) '_' num2str( vintday ) '.mat'  ], 'file') == 2
    else
    disp([dirname 'dataset_' num2str( vintyear ) '_' num2str( vintmonth ) '_' num2str( vintday ) '.mat'  ])
    flag_missing( v ) = 1 ; 
    end
end
