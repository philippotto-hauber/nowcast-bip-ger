function data_ifo = f_load_ifo(vintage, dir_rawdata, dir_repo)

% add path data files
dirname = [dir_rawdata '/ifo/'] ;

%% ifo options
data_ifo.names = {'ifo: Lage', 'ifo:  Erwartungen'};
data_ifo.groups = {'ifo', 'ifo'};
data_ifo.trafo = [2, 2];
data_ifo.type = {'m', 'm'} ; 
data_ifo.flag_usestartvals =[1, 1] ; 
data_ifo.flag_sa = [0, 0];

%% read in data and select vars
[num, txt, ~] = xlsread([ dirname 'ifo_current.xlsx'], 'ifo Geschäftsklima Deutschland');
row_offset = size(txt, 1) - size(num, 1);
col_offset = size(txt, 2) - size(num, 2);
dates_str = txt(row_offset+1:end, 1);
dates = year(dates_str{1},'mm/yyyy') + month(dates_str{1},'mm/yyyy')/12 + [0:(size(num,1) - 1)]'/12;
ind_vars = [3, 4] - col_offset;

%% determine available observations according to vintage
releasedates = readtable([ dir_repo '/aux_real_time_data/releasedates_ifo_csv.csv'], Delimiter=';' );

index_row = get_row_index_vintage(dates_str, releasedates, vintage, 'm', 'mm/yyyy');

data_ifo.rawdata = num(1:index_row, ind_vars);
data_ifo.dates = dates(1:index_row);

%% transform
data_trafo = NaN(size(data_ifo.rawdata)) ; 
flag_dontuse = zeros(1,size(data_ifo.rawdata,2)) ; 

for n = 1 : size(data_ifo.rawdata,2) 
    switch data_ifo.trafo(n)
            case 1
                data_trafo(:,n) = data_ifo.rawdata(:,n);            
            case 2
                data_trafo(:,n) = [NaN(1,1); diff(data_ifo.rawdata(:,n))]; 
            case 3
                data_trafo(:,n) = [NaN(1,1); 100*diff(log(data_ifo.rawdata(:,n)))];
    end 
end    
data_ifo.data = data_trafo ; 

%% last checks
if ~all(flag_dontuse==0)
    data_ifo.namesremoved = data_ifo.names(flag_dontuse==1) ; 
    data_ifo.data = data_ifo.data(:,~flag_dontuse) ;   
    data_ifo.rawdata = data_ifo.rawdata(:,~flag_dontuse) ; 
    data_ifo.trafo = data_ifo.trafo(:,~flag_dontuse) ;  
    data_ifo.names = data_ifo.names(:,~flag_dontuse) ;  
    data_ifo.groups = data_ifo.groups(:,~flag_dontuse) ;  
    data_ifo.type = data_ifo.type(:,~flag_dontuse) ;
    data_ifo.flag_usestartvals = data_ifo.flag_usestartvals(:,~flag_dontuse) ; 
    data_ifo.flag_sa = data_ifo.flag_sa(:,~flag_dontuse) ; 
end


