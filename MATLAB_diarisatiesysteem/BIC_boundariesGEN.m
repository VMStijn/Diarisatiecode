function [labels] = BIC_boundariesGEN(unclustered,f_length,lambda,VAD,min_seglength,Parameters)
% Performs the initial segmentation
%% INPUTS
%   unclustered=        Nxd matrix containing N observed feature vectors
%                       of dimension d
%   f_length=           frame length of adjoined windows (Fl in text)                      
%   lambda=             design parameter for the BIC, less boundaries if
%                       higher
%   VAD=                vector containing the labels assigned by the VAD
%                       module
%   min_seglength=      minimum segment length (Lmin in text)
%   Parameters=         block containing various other parameter values and
%                       system configurations
%% OUTPUTS
%   labels=             1 x N vector containing the computed labels in this
%                       step

%% FUNCTION BODY
labels = [1:size(unclustered,1); ones(1,size(unclustered,1))].';
if length(VAD) > 1
    labels = labels(VAD > 0.5,:);
    unclustered = unclustered(VAD > 0.5,:);
end
delta_BIC = [];
left_seg = unclustered(1:f_length,:).';
right_seg = unclustered(f_length+1:2*f_length,:).';
covmode = Parameters.covmode;
mode1 = 'Diagonal';
mode2 = 'Full';
Condnr = [];
for ii = f_length:size(unclustered,1) - f_length - 1
    if strcmp(covmode,mode1)
        [BIC,condL,condR,condLR] = segmental_BIC(left_seg,right_seg,lambda,Parameters);
    elseif strcmp(covmode,mode2)
        [BIC,condL,condR,condLR] = segmental_BIC_fullcov(left_seg,right_seg,lambda,Parameters);
    else
        error('no valid covmode given');
    end
    delta_BIC = [delta_BIC; ii BIC];
    left_seg = [left_seg(:,2:end) right_seg(:,1)];
    right_seg = [right_seg(:,2:end) unclustered(ii + f_length + 1,:).'];
    Condnr = [Condnr; condL,condR,condLR];
end
cond = any(delta_BIC(:,2) > 0);
while cond
    [~,idx] = max(delta_BIC(:,2));
    test = length(unique(labels(:,2)));

    labels(f_length+idx+1:end,2) = labels(f_length + idx +1:end,2) + 1;
    if min_seglength > 1
        window = max(1,idx - floor(min_seglength/2)):min(size(unclustered,1),idx + floor(min_seglength/2));
        delta_BIC(window,2) = zeros(length(window),1);
    else
        delta_BIC(idx,:) = 0;
    end
    cond = any(delta_BIC(:,2) > 0);
end


end