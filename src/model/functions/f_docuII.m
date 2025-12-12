function  f_docuII(nowcast_new,vintages,details,Nr,Np,Nj,savenamemaster,flag_ewpool,dirname)


for v = 2 : size(nowcast_new,2) 
    savename = [savenamemaster '_' vintages{v}] ; 
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
        fprintf(fid,'####### Nr = %d ##################################################\r\n',Nr);
        fprintf(fid,'####### Np = %d ##################################################\r\n',Np);
        fprintf(fid,'####### Nj = %d ##################################################\r\n',Nj);
    end
    temp = '#################################################################';
    fprintf(fid,'%s \r\n',temp);
    temp = '#################################################################';
    fprintf(fid,'%s \r\n',temp);
    temp = '#---------------------------------------------------------------#';
    fprintf(fid,'%s \r\n',temp);
    temp = '#-';
    fprintf(fid,'%s \r\n',temp);
    fprintf(fid, ['#- On ' vintages{v} ', the nowcast for ' savenamemaster(10:15) ' was %4.2f percent... \r\n'], round(nowcast_new(1,v),2));
    temp = '#-';
    fprintf(fid,'%s \r\n',temp);
    fprintf(fid, '#- ... a revision of %4.2f percentage points... \r\n',round(nowcast_new(1,v),2)-round(nowcast_new(1,v-1),2));
    temp = '#-';
    fprintf(fid,'%s \r\n',temp);
    fprintf(fid,'#- ... compared to the previous nowcast, made on %s. \r\n',vintages{v-1});
    temp = '#-';
    fprintf(fid,'%s \r\n',temp);
    fprintf(fid,'%s \r\n','#- Impact by newly released variables (in descending absolute order):');
    temp = '#-';
    fprintf(fid,'%s \r\n',temp);

    % top movers
    [~,index_sort] = sort(abs(details(v).impacts),'descend') ;
    impacts_sorted = round(details(v).impacts(index_sort),4) ; 
    names_sorted = details(v).varnames(index_sort) ;  
    actuals_sorted = round(details(v).actuals(index_sort),1) ; 
    forecasts_sorted = round(details(v).forecasts(index_sort),1) ;
    weights_sorted = round(details(v).weights(index_sort),4) ;

    for i = 1 : length(impacts_sorted)
        fprintf(fid,'#-    %s \r\n',names_sorted{i});
        fprintf(fid,'#     forecast: %4.1f,  actual: %4.1f,  weight: %4.4f,  impact: %4.4f \r\n',forecasts_sorted(i),actuals_sorted(i),weights_sorted(i),impacts_sorted(i));
        temp = '#-';
        fprintf(fid,'%s \r\n',temp);
    end
    
    temp = '#################################################################';
    fprintf(fid,'%s \r\n',temp);
    fclose(fid);
end


