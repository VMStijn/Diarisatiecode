function [delta_BIC,condL,condR,condLR] = segmental_BIC_fullcov(Fvec_Left,Fvec_Right,lambda,Parameters)
%Calculates segmental BIC criterion
%% INPUTS
%   Fvec_Left =     d x NL matrix with feature vectors as its columns
%   Fvec_Right =    d x NR matrix with feature vectors as its columns
%   lambda =        controls amount of eliminated boundaries (DESIGN PARAMETER)

%% OUTPUTS
%   delta_BIC =     Bayesian information criterion (value)

%% FUNCTION BODY

% Amount of frames
NL = size(Fvec_Left,2);
NR = size(Fvec_Right,2);
%  Feature vector dimension (default d = 32);
d = size(Fvec_Left,1);

P = 1/2*(d+1/2*d*(d+1))*log10(NL*NR/(NL+NR));

% Covariances
% columns are random variables, rows are observations
epsilonL = cov(Fvec_Left.');
epsilonR = cov(Fvec_Right.');
Fvec_LR = [Fvec_Left, Fvec_Right];
L_mean = mean(Fvec_Left,2);
R_mean = mean(Fvec_Right,2);
%LR_mean = mean(Fvec_LR,2);
LR_mean = (NL*L_mean + NR*R_mean)/(NL + NR);
epsilonLR = NL/(NL+NR)*epsilonL + NR/(NL+NR)*epsilonR + NL/(NL+NR)*(L_mean-LR_mean)*(L_mean-LR_mean)' + NR/(NL+NR)*(R_mean-LR_mean)*(R_mean-LR_mean)';
epsilonLR = cov(Fvec_LR.');
%testCrit1 = rank(epsilonLR);
%testCrit2 = rank(epsilonL);
%testCrit3 = rank(epsilonR);
spkcov = Parameters.spkcov;
%if testCrit2 < d
    %L_mean = mean(Fvec_Left,2);
    epsilonL = epsilonL + 0.1*(spkcov);
    %epsilonL = epsilonL + 0.1*std(Fvec_Left.').^2*eye(d);
%end
%if testCrit3 < d
    %R_mean = mean(Fvec_Right,2);
    epsilonR = epsilonR + 0.1*(spkcov);
    %epsilonR = epsilonR + 0.1*std(Fvec_Right.').^2*eye(d);
%end
%if testCrit1 < d
    %LR_mean = mean(Fvec_LR,2);
    epsilonLR = epsilonLR + 0.1*(spkcov);
    %epsilonLR = epsilonLR + 0.1*std(Fvec_LR.').^2*eye(d);
%end
if Parameters.getCondNr
    temp = eig(epsilonL);
    condL =  abs(max(temp))/abs(min(temp));
    temp = eig(epsilonR);
    condR = abs(max(temp))/abs(min(temp));
    temp = eig(epsilonLR);
    condLR = abs(max(temp))/abs(min(temp));
else    

    condL = 0;
    condR = 0;
    condLR = 0;
end
%{
epsilonL = std(Fvec_Left.'); % nakijken of juiste vorm van input
%epsilonR = std(Fvec_Right.'); % nakijken of juiste vorm van input
epsilonR = cov(Fvec_Right.');
Fvec_LR = [Fvec_Left, Fvec_Right];
epsilonLR = std(Fvec_LR.');

% BIC as specified in Desplanques et. al 
testCrit1 = prod(epsilonLR.^2);
testCrit2 = prod(epsilonL.^2);
testCrit3 = prod(std(Fvec_Right.').^2);
if ~isreal(testCrit1) || ~isreal(testCrit2) || ~isreal(testCrit3)
    error('determinant is not real');
end
if testCrit1 == 0 || testCrit2 == 0 || testCrit3 == 0
    error('determinant is zero');
end
%}

delta_BIC = (NL + NR)*log10(det(epsilonLR)) - NL*log10(det(epsilonL)) - NR*log10(det(epsilonR)) - lambda*P;
if ~isreal(delta_BIC)
    error('BIC is not real');
end

