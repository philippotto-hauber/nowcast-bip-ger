function f_graphnowcastevolve(nowcasts,groupcontribs,nowcastrevision,titlename,vintagedates,groupnames)

% ------------------ % 
% - open figure ---- %
fig = figure;
fig.PaperOrientation = 'landscape';

% first subplot => nowcast evolution
subplot(2,1,1)
%plot(squeeze(store_nowcast(1,:,modcounter))*stdgdp + meangdp,'k-','LineWidth',1.5)
plot(nowcasts,'k-','LineWidth',1.5)
%title(['nowcasts ' num2str(floor(dates(index_nowcast))) 'Q' num2str((dates(index_nowcast) - floor(dates(index_nowcast)))*12/3) ' (Nr = ' num2str(Nr) ', Np = ' num2str(Np) ', Nj = ' num2str(Nj) ')'])
title(titlename)
lgd = legend(['nowcast on ' vintagedates{end} ': ' num2str(round(nowcasts(end),2))]) ;
lgd.Location = 'best' ; 
lgd.FontSize = 8 ; 
ylabel('percent')
xtickangle(60)
ax = gca ;
ax.XLim = [0 size(nowcasts,2)+1] ; 
ax.XTick = 1:size(nowcasts,2) ;
ax.XTickLabels = vintagedates ;
box off

% second subplot => news decomposition
subplot(2,1,2)

% aggregate survey groups into ESI and ifo
ind_temp = 1;
index_group = strcmp(groupnames,'ESI') | strcmp(groupnames,'ifo');
temp(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'surveys';
ind_temp = ind_temp + 1;
index_group = strcmp(groupnames,'production') ; 
temp(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'production' ; 
ind_temp = ind_temp + 1;
index_group = strcmp(groupnames,'orders') ; 
temp(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'orders';
ind_temp = ind_temp + 1;
index_group = strcmp(groupnames,'turnover') ; 
temp(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'turnover' ;
ind_temp = ind_temp + 1;
index_group = strcmp(groupnames,'financial') ; 
temp(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'financial' ; 
ind_temp = ind_temp + 1;
index_group = strcmp(groupnames,'labor market') ; 
temp(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'labor market' ; 
ind_temp = ind_temp + 1;
index_group = strcmp(groupnames,'prices') ; 
temp(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'prices';
ind_temp = ind_temp + 1;
index_group = strcmp(groupnames,'national accounts') ; 
temp(ind_temp,:) = sum(groupcontribs(index_group,:),1) ; 
tempnames{ind_temp} = 'national accounts' ; 
ind_temp = ind_temp + 1;
temp(ind_temp,:) = nowcastrevision(1,:) ;
tempnames{ind_temp} = 'data revisions' ;          

%b=bar(temp','stacked') ;

temp_neg = zeros(size(temp)) ; 
temp_neg(temp<0) = temp(temp<0) ; 
temp_pos = zeros(size(temp)) ; 
temp_pos(temp>0) = temp(temp>0) ;
temp2 = [];  
temp2(:,:,1) = temp_pos' ; 
temp2(:,:,2) = temp_neg' ; 


b(1,:) = bar(temp_pos','stacked') ;
hold on;
b(2,:) = bar(temp_neg','stacked') ;



c = [0.85 0.3250 0.0980; % default dark orange
     0 0.4470 0.7410; % default blue
     0.9290 0.6940 0.1250; % default light orange 
     %1 0 0; % red
     0.6350 0.0780 0.1840; % dark red
     0.3010 0.7450 0.9330; % light blue
     0.75 0 0.75; % violet
     0 0.5 0 ; % dark green
     0.466 0.674 0.188; % light green
     0 0 0] ; % black
if size(c, 1) ~= length(tempnames)
   error('Number of groups and specified colors do not match. Abort!')
end
for n = 1 : size(c,1)
    b(1,n).FaceColor = c(n,:) ; 
    b(2,n).FaceColor = c(n,:) ; 
    %b(1,n).BarWidth = 1 ; 
    %b(2,n).BarWidth = 1 ; 
    %b(1,n+size(temp,1)).FaceColor = c(n,:) ; 
    %b(n).FaceAlpha = 0.8 ; 
end

title('news decomposition')
ylabel('percent')
lgd = legend(tempnames) ;
lgd.Location = 'NorthWest' ; 
lgd.FontSize = 6.5 ; 
xtickangle(60)
ax = gca ;
ax.XTick = 1:size(nowcasts,2) ;
ax.XTickLabels = vintagedates;
box off
