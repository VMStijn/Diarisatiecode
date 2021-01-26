function [delta_BIC] = update_BICcluster(unclustered,labels,delta_BIC,left_ID,right_ID,lambda,Parameters)
% Get rid of entries with right_ID
delta_BIC(delta_BIC(:,1) == right_ID | delta_BIC(:,2) == right_ID,:) = [];
% Decrease ID's larger than right_ID
delta_BIC(delta_BIC(:,1) > right_ID,1) = delta_BIC(delta_BIC(:,1) > right_ID,1) - 1;
delta_BIC(delta_BIC(:,2) > right_ID,2) = delta_BIC(delta_BIC(:,2) > right_ID,2) - 1;

% Find subset that needs to be updated
upd_flag = delta_BIC(:,1) == left_ID | delta_BIC(:,2) == left_ID;
mode1 = 'Diagonal';
mode2 = 'Full';
covmode = Parameters.covmode;
for ii = 1:length(upd_flag)
    if upd_flag(ii)
        left_ID = delta_BIC(ii,1);
        right_ID = delta_BIC(ii,2);
        left_seg = unclustered(labels(:,2) == left_ID,:).';
        right_seg = unclustered(labels(:,2) == right_ID,:).';
        if strcmp(covmode,mode1)
            BIC = segmental_BIC(left_seg,right_seg,lambda,Parameters);
        elseif strcmp(covmode,mode2)
            BIC = segmental_BIC_fullcov(left_seg,right_seg,lambda,Parameters);
        else
            error('no valid covmode given');
        end
        delta_BIC(ii,:) = [left_ID right_ID BIC];
    end
end
        
end

