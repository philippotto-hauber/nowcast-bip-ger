function params = f_startingvalues(data_mx,data_mz,data_q_flow,options)

% ----------------------------------- % 
% - balanced subsample
% ----------------------------------- %

[data_bal, balstart, balend] = f_findbalancedsubsample(data_mx(options.flag_usestartvals(1:options.Nmx)==1,:));

data_bal(isnan(data_bal)) = 0; % overwrite missing obs in middle of sample with 0!

% ----------------------------------- % 
% - initial PCA estimate of factors
% ----------------------------------- %

[factors, ~] = f_PCA(data_bal,options.Nr); % use balanced dataset to obtain PCA estimates of factors
if options.restrOmeg == 1
    % standardize factors 
    for r = 1 : options.Nr 
        factors(r,:) = factors(r,:)./std(factors(r,:)) ; 
    end
end

% ----------------------------------- % 
% - phi and Omeg
% ----------------------------------- %

y = factors(:,options.Np+1:end)';
X = [];
for l=1:options.Np
    X = [X factors(:,options.Np+1-l:end-l)'];
end
A = (inv(X'*X)*X'*y)';
eps = y - X * A'  ; 
Omeg = eps'*eps/size(eps,1) ; 

if options.restrOmeg == 1
    Omeg = eye(options.Nr) ;
end

% ----------------------------------- % 
% - lambdaMx, rhoMx and SigMx
% ----------------------------------- %

lambdaMx = NaN(size(data_mx,1),options.Nr) ; 
rhoMx = NaN(size(data_mx,1),options.Nj) ; 
SigMx = NaN(size(data_mx,1),1) ; 
for i=1:size(data_mx,1)
    % lambda_m
    Y = data_mx(i,balstart:balend)'; 
    X = factors'; %(:,balstart:balend)';  
    % make sure no missings left in Y
    Yestim = Y(~isnan(Y(:,1)),1) ; 
    Xestim = X(~isnan(Y(:,1)),:);
    lambdaMx(i,:) = ((Xestim'*Xestim)\Xestim'*Yestim)';
    idios = Yestim - Xestim*lambdaMx(i,:)';
    if options.Nj > 0
        y = idios(options.Nj+1:end,:);
        X = [];
        for j = 1 : options.Nj
            X = [X idios(options.Nj+1-j:end-j,:)];
        end
        rhoMx( i , : ) = inv(X'*X)*X'*y;
        resids = y - X * rhoMx( i , :)';
        SigMx(i,1) = var(resids);
    else
        SigMx(i,1) = idios'*idios/length(idios);
    end
end

% ----------------------------------- % 
% - lambdaMz, rhoMz and SigMz
% ----------------------------------- %

lambdaMz = NaN(size(data_mz,1),options.Nr) ; 
rhoMz = NaN(size(data_mz,1),options.Nj) ; 
SigMz = NaN(size(data_mz,1),1) ; 
for i=1:size(data_mz,1)
    
    Y = data_mz(i,balstart:balend)'; 
    X = factors'; %(:,balstart:balend)';  
    % make sure no missings left in Y
    Yestim = Y(~isnan(Y(:,1)),1) ; 
    Xestim = X(~isnan(Y(:,1)),:);
    lambdaMz(i,:) = ((Xestim'*Xestim)\Xestim'*Yestim)';
    idios = Yestim - Xestim*lambdaMz(i,:)';
    if options.Nj > 0
        y = idios(options.Nj+1:end,:);
        X = [];
        for j = 1 : options.Nj
            X = [X idios(options.Nj+1-j:end-j,:)];
        end
        rhoMz( i , : ) = inv(X'*X)*X'*y;
        resids = y - X * rhoMz( i , :)';
        SigMz(i,1) = var(resids);
    else
        SigMz(i,1) = idios'*idios/length(idios);
    end
end

% ------------------------------------------- % 
% - lambdaQ_flow, rhoQ_flow and SigQ_flow
% ------------------------------------------- %
if options.Nq_flow>0
    lambdaQ_flow = NaN(size(data_q_flow,1),options.Nr) ; 
    rhoQ_flow = NaN(size(data_q_flow,1),options.Nj) ; 
    SigQ_flow = NaN(size(data_q_flow,1),1) ; 
    data_q_flow_bal = data_q_flow(:, balstart:balend);
    X = [NaN(size(factors, 1), 2) (factors(:, 1:end-2) + factors(:, 2:end-1) + factors(:, 3:end)) /3];
    for i=1:size(data_q_flow,1)        
        Yestim = data_q_flow_bal(i, ~isnan(data_q_flow_bal(i, :)) & ~any(isnan(X), 1))';
        Xestim = X(:, ~isnan(data_q_flow_bal(i, :))& ~any(isnan(X), 1))';
        lambdaQ_flow(i,:) = ((Xestim'*Xestim)\Xestim'*Yestim)';
        idios = Yestim - Xestim*lambdaQ_flow(i,:)';
        if options.Nj > 0
            y = idios(options.Nj+1:end,:);
            X_idios = [];
            for j = 1 : options.Nj
                X_idios = [X_idios idios(options.Nj+1-j:end-j,:)];
            end
            rhoQ_flow( i , : ) = inv(X_idios'*X_idios)*X_idios'*y;
            resids = y - X_idios * rhoQ_flow( i , :)';
            SigQ_flow(i,1) = var(resids);
        else
            SigQ_flow(i,1) = (3/sqrt(19))^2 * idios'*idios/length(idios);
        end
    end
else
    lambdaQ_flow = [] ; 
    rhoQ_flow = [] ; 
    SigQ_flow = [] ; 
end
% ------------------------------------------- % 
% - collect params in structure
% ------------------------------------------- %

params.A = A ; 
params.Omeg = Omeg ; 
params.lambdaMx = lambdaMx; 
params.rhoMx = rhoMx; 
params.SigMx = SigMx; 
params.lambdaMz = lambdaMz; 
params.rhoMz = rhoMz; 
params.SigMz = SigMz; 
params.lambdaQ_flow = lambdaQ_flow; 
params.rhoQ_flow = rhoQ_flow; 
params.SigQ_flow = SigQ_flow; 
params.lambdaQ_stock = []; 
params.rhoQ_stock = []; 
params.SigQ_stock = []; 



 


function [Y_bal, index_balanced_start, index_balanced_end] = f_findbalancedsubsample(Y)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
[~,T] = size(Y);

% start of balanced subsample
for t=1:T;
    if any(isnan(Y(:,t)));
        
    else
        break
    end
end
index_balanced_start=t;

% end of balanced subsample
for t=T:-1:1;
     if any(isnan(Y(:,t)));
       
    else
        break
    end
end
index_balanced_end=t;


Y_bal = Y(:,index_balanced_start:index_balanced_end);

function [F_hat, V] = f_PCA(Y,R)
% covariance matrix of observables
SIGMA = Y*Y'/size(Y,2);

% eigenvalue and -vector decomposition
[V,D] = eig(SIGMA);

% extract eigenvalues and change order
eigenvalues_D = diag(D);
eigenvalues_D = flipud(eigenvalues_D);
D = diag(eigenvalues_D);
% change order of eigenvectors
V = f_reversecolumns(V);
F_hat = V'*Y;
F_hat = F_hat(1:R,:);
V = V';

function [ A_reverse ] = f_reversecolumns( A )
%Reverses the columns of a matrix. 
aux = zeros(size(A));
[R,C] = size(A);
for c=0:(C-1);
    aux(:,c+1) = A(:,C-c);
end
A_reverse = aux;