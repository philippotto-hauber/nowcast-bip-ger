function f_table(nowcast,revision,groupcontrib,vintages,savename,groupnames,dirname)


T = table(nowcast', ...
    groupcontrib(1,:)', ...
    groupcontrib(2,:)', ...
    groupcontrib(3,:)', ...
    groupcontrib(4,:)', ...
    groupcontrib(5,:)', ...
    groupcontrib(6,:)', ...
    groupcontrib(7,:)', ...
    groupcontrib(8,:)', ...
    groupcontrib(9,:)', ...
    groupcontrib(10,:)', ...
    groupcontrib(11,:)', ...
    groupcontrib(12,:)', ...
    groupcontrib(13,:)', ...
    groupcontrib(14,:)', ...
    groupcontrib(15,:)', ...
    groupcontrib(16,:)', ...
    groupcontrib(17,:)', ...
    revision',...
    'VariableNames',groupnames,...
    'RowNames',vintages);                     

writetable(T,[dirname '\tables\' savename '.xlsx'],'WriteRowNames',true) 

