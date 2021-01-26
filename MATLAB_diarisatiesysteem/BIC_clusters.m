function [labels] = BIC_clusters(unclustered,labels,lambda,nr_accepted,Parameters)
% Performs the clustering
%% INPUTS
%   unclustered=        matrix containing observed feature vectors
%                       of dimension d                     
%   lambda=             design parameter for the BIC
%   nr_accepted=        amount of desired speakers
%   Parameters=         block containing various other parameter values and
%                       system configurations
%% OUTPUTS
%   labels=             vector containing the computed labels in this
%                       step

%% FUNCTION BODY
if nr_accepted ~= 0
    % If you know how much speakers occur, merging will stop once this has
    % been achieved (or before that if no negative BIC's could be found)
    spk_bound = nr_accepted;
else
    % Set to 2 so it stops if only 1 speaker remains.
    spk_bound = 2;
end

unclustered = unclustered(labels(:,1),:);
nr_speakers = length(unique(labels(:,2)));
if nr_speakers >= spk_bound
nr_combinations = nchoosek(nr_speakers,2);
delta_BIC = zeros(nr_combinations,3);
speakers = unique(labels(:,2));
store_cnt = 1;
mode1 = 'Diagonal';
mode2 = 'Full';
covmode = Parameters.covmode;
for ii = 1:nr_speakers - 1
    for jj = ii+1:nr_speakers
        left_ID = speakers(ii);
        right_ID = speakers(jj);
        left_spk = unclustered(labels(:,2) == left_ID,:).';
        right_spk = unclustered(labels(:,2) == right_ID,:).';
        
        if strcmp(covmode,mode1)
            BIC = segmental_BIC(left_spk,right_spk,lambda,Parameters);
        elseif strcmp(covmode,mode2)
            BIC = segmental_BIC_fullcov(left_spk,right_spk,lambda,Parameters);
        else
            error('no valide covmode given');
        end
        delta_BIC(store_cnt,:) = [left_ID,right_ID, BIC];
        store_cnt = store_cnt + 1;
    end
end
   
cond = any(delta_BIC(:,3) < 0) & nr_speakers >= spk_bound;
while cond
    % find lowest BIC
    [~,idx] = min(delta_BIC(:,3));
    left_ID = delta_BIC(idx,1);
    right_ID = delta_BIC(idx,2);
    % merge speakers with lowest BIC
    labels(labels(:,2) == right_ID,2) = left_ID;
    labels(labels(:,2) > right_ID,2) = labels(labels(:,2) > right_ID,2) - 1;
    %nr of speakers has decreased, BIC needs to be updated
    %updates everything --> very slow
    %{
    nr_speakers = length(unique(labels(:,2)));
    nr_combinations = nchoosek(nr_speakers,2);
    delta_BIC = zeros(nr_combinations,3);
    speakers = unique(labels(:,2));
    store_cnt = 1;
    for ii = 1:nr_speakers - 1
        for jj = ii+1:nr_speakers
            left_ID = speakers(ii);
            right_ID = speakers(jj);
            left_spk = unclustered(labels(:,2) == left_ID,:).';
            right_spk = unclustered(labels(:,2) == right_ID,:).';
            BIC = segmental_BIC(left_spk,right_spk,lambda);
            delta_BIC(store_cnt,:) = [left_ID,right_ID, BIC];
            store_cnt = store_cnt + 1;
        end
    end
    %}
    % only updates necessary entries
    delta_BIC = update_BICcluster(unclustered,labels,delta_BIC,left_ID,right_ID,lambda,Parameters);
    nr_speakers = length(unique(labels(:,2)));
    cond = any(delta_BIC(:,3) < 0)  & nr_speakers >=spk_bound;
end  
end
end

