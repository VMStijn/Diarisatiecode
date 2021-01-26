function [delta_BIC,condL,condR,condLR] = segmental_BIC(Fvec_Left,Fvec_Right,lambda,Parameters)
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
%{
epsilonL = cov(Fvec_Left.');
epsilonR = cov(Fvec_Right.');
Fvec_LR = [Fvec_Left, Fvec_Right];
epsilonLR = cov(Fvec_LR.');
testCrit1 = rank(epsilonLR);
testCrit2 = rank(epsilonL);
testCrit3 = rank(epsilonR);

if testCrit1 < d | testCrit2 < d | testCrit3 <d
%}

epsilonL = std(Fvec_Left.'); 
epsilonR = std(Fvec_Right.');
Fvec_LR = [Fvec_Left, Fvec_Right];
epsilonLR = std(Fvec_LR.');

 
testCrit1 = prod(epsilonLR.^2);
testCrit2 = prod(epsilonL.^2);
testCrit3 = prod(epsilonR.^2);
if ~isreal(testCrit1) || ~isreal(testCrit2) || ~isreal(testCrit3)
    error('determinant is not real');
end
if testCrit1 == 0 || testCrit2 == 0 || testCrit3 == 0
    error('determinant is zero');
end
if Parameters.getCondNr
    condL = abs(max(epsilonL.^2))/abs(min(epsilonL.^2));
    condR = abs(max(epsilonR.^2))/abs(min(epsilonR.^2));
    condLR = abs(max(epsilonLR.^2))/abs(min(epsilonLR.^2));
else
    condL = 0;
    condR = 0;
    condLR = 0;
end
% BIC as specified in Desplanques et. al
delta_BIC = (NL + NR)*log10(prod(epsilonLR.^2)) - NL*log10(prod(epsilonL.^2)) - NR*log10(prod(epsilonR.^2)) - lambda*P;
%{
else
delta_BIC = (NL + NR)*log10(det(epsilonLR)) - NL*log10(det(epsilonL)) - NR*log10(det(epsilonR)) - lambda*P;    
end
%}
end

