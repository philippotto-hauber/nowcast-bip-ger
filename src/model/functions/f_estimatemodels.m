function f_estimatemodels(samplestart,vintage,Nrs,Nps,Njs,list_removevars,dirname, dir_data)

% load first vintage
[dataM_stand, dataQ_stand, ~, ~, flag_usestartvals, ~, ~, ~] = f_constructdataset(dir_data, samplestart,vintage,list_removevars,[],[]) ; 

options.flag_usestartvals = flag_usestartvals ;
options.restrOmeg = 0 ; 

for Nr = Nrs 
    for Np = Nps
        for Nj = Njs
            options.Nr = Nr ; 
            options.Np = Np ; 
            options.Nj = Nj ; 

            params = f_EMalgorithm(dataM_stand,dataQ_stand,options) ;
            
            % save params as mat-file
            save([dirname '\params\params_Nr' num2str(Nr) '_Np' num2str(Np) '_Nj' num2str(Nj) '.mat'],'params') ;
        end
    end
end
