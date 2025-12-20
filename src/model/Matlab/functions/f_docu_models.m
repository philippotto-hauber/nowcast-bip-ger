function  f_docu_models(results,options,modcounter,savename)

fid=fopen([pwd '\docu\' savename '.txt'],'w');
temp = '#################################################################';
fprintf(fid,'%s \r\n',temp);
fprintf(fid,'%s \r\n',temp);
temp = '####### MODEL SPECIFICATION #####################################';
fprintf(fid,'%s \r\n',temp);
fprintf(fid,'####### Nr = %d ##################################################\r\n',options.Nr);
fprintf(fid,'####### Np = %d ##################################################\r\n',options.Np);
fprintf(fid,'####### Nj = %d ##################################################\r\n',options.Nj);
temp = '#################################################################';
fprintf(fid,'%s \r\n',temp);
for v = 2 : size(results.nowcast.new,2) 
    temp = '#################################################################';
    fprintf(fid,'%s \r\n',temp);
    temp = '#---------------------------------------------------------------#';
    fprintf(fid,'%s \r\n',temp);
    temp = '#-';
    fprintf(fid,'%s \r\n',temp);
    fprintf(fid, ['#- Nowcast on ' results.vintages{v} ' was %4.2f percent. \n'], round(results.nowcast.new(1,v,modcounter),2));
    temp = '#-';
    fprintf(fid,'%s \r\n',temp);
    fprintf(fid, '#- Previous nowcast was %4.2f percent. \n', round(results.nowcast.new(1,v-1,modcounter),2));
    temp = '#-';
    fprintf(fid,'%s \r\n',temp);
    temp = '#- Variables with an absolute impact larger than 0.01 were...' ;
    fprintf(fid,'%s \r\n',temp);
    temp = '#-';
    fprintf(fid,'%s \r\n',temp);

    % top movers
    [~,index_sort] = sort(abs(results.nowcast.details(v,modcounter).impacts),'descend') ;
    impacts_sorted = results.nowcast.details(v,modcounter).impacts(index_sort) ; 
    names_sorted = results.nowcast.details(v,modcounter).varnames(index_sort) ;  
    actuals_sorted = results.nowcast.details(v,modcounter).actuals(index_sort) ; 
    forecasts_sorted = results.nowcast.details(v,modcounter).forecasts(index_sort) ;
    weights_sorted = results.nowcast.details(v,modcounter).weights(index_sort) ;
    if sum(abs(impacts_sorted)>0.01) == 0 
        temp = '# ...none!';
        fprintf(fid,'%s \r\n',temp);
    else
        for i = 1 : sum(abs(impacts_sorted)>0.01)
            fprintf(fid,'#-    %s \r\n',names_sorted{i});
            fprintf(fid,'#     forecast: %4.2f actual: %4.2f weight: %4.2f impact: %4.2f \r\n',forecasts_sorted(i),actuals_sorted(i),weights_sorted(i),impacts_sorted(i));
            temp = '#-';
            fprintf(fid,'%s \r\n',temp);
        end
    end
end
temp = '#################################################################';
fprintf(fid,'%s \r\n',temp);
fclose(fid);

