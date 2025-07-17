function  f_docu(nowcast_new,vintages,details,options,savename,flag_ewpool,threshold,dirname)

fid=fopen([dirname '\docu\' savename '.txt'],'w');
temp = '#################################################################';
fprintf(fid,'%s \r\n',temp);
fprintf(fid,'%s \r\n',temp);
temp = '####### MODEL SPECIFICATION #####################################';
fprintf(fid,'%s \r\n',temp);
if flag_ewpool == 1 
    temp = '####### equal-weight pool #######################################' ;
    fprintf(fid,'%s \r\n',temp);
else
    fprintf(fid,'####### Nr = %d ##################################################\r\n',options.Nr);
    fprintf(fid,'####### Np = %d ##################################################\r\n',options.Np);
    fprintf(fid,'####### Nj = %d ##################################################\r\n',options.Nj);
end
temp = '#################################################################';
fprintf(fid,'%s \r\n',temp);
for v = 2 : size(nowcast_new,2) 
    temp = '#################################################################';
    fprintf(fid,'%s \r\n',temp);
    temp = '#---------------------------------------------------------------#';
    fprintf(fid,'%s \r\n',temp);
    temp = '#-';
    fprintf(fid,'%s \r\n',temp);
    fprintf(fid, ['#- On ' vintages{v} ', the nowcast for ' savename(10:15) ' was %4.2f percent. \r\n'], round(nowcast_new(1,v),2));
    temp = '#-';
    fprintf(fid,'%s \r\n',temp);
    fprintf(fid, '#- Previous nowcast was %4.2f percent. \r\n', round(nowcast_new(1,v-1),2));
    temp = '#-';
    fprintf(fid,'%s \r\n',temp);
    fprintf(fid,'#- Variables with an absolute impact larger than %4.2f were...\r\n',threshold);
    temp = '#-';
    fprintf(fid,'%s \r\n',temp);

    % top movers
    [~,index_sort] = sort(abs(details(v).impacts),'descend') ;
    impacts_sorted = round(details(v).impacts(index_sort),2) ; 
    names_sorted = details(v).varnames(index_sort) ;  
    actuals_sorted = round(details(v).actuals(index_sort),1) ; 
    forecasts_sorted = round(details(v).forecasts(index_sort),1) ;
    weights_sorted = round(details(v).weights(index_sort),4) ;
    if sum(abs(impacts_sorted)>threshold) == 0 
        temp = '# ...none!';
        fprintf(fid,'%s \r\n',temp);
    else
        for i = 1 : sum(abs(impacts_sorted)>threshold)
            fprintf(fid,'#-    %s \r\n',names_sorted{i});
            fprintf(fid,'#     forecast: %4.1f actual: %4.1f weight: %4.4f impact: %4.2f \r\n',forecasts_sorted(i),actuals_sorted(i),weights_sorted(i),impacts_sorted(i));
            temp = '#-';
            fprintf(fid,'%s \r\n',temp);
        end
    end
end
temp = '#################################################################';
fprintf(fid,'%s \r\n',temp);
fclose(fid);

