function [labels_computed] = assign_spkID(labels_GT,labels_computed,unclustered_z2,assign_mode,lambda,Parameters)
%Takes the computed labels and reassigns them to fit the speakers in the
%ground truth

%% INPUTS
%   labels_GT =          1 x seg_length row vector containing the labels from
%                        manual annotation
%   labels_computed =    1 x seg_length row vector containing the labels
%                        from the diarization algorithm (only distinguishes
%                        different speakers, no specific ID's assigned yet)
%   unclustered_z2 =     seg_length x d matrix where the columns are the
%                        feature vectors
%   assign_mode =        controls how you assign speakers, 'minperm' will
%                        take the label that occurs the most in both labels_GT and
%                        labels_computed and then assign a speaker ID to the computed labels,
%                        'spkID_vector_noreuse' and 'spkID_vector_allowreuse' will use the labels from GT to select feature vectors
%                        and then use the Bayesian Information Criterion to assign a speaker ID
%                        to the computed labels                       
%   lambda =             design parameter for the BIC

%% OUTPUTS
%   labels_computed =    1 x seg_length row vector with the diarization
%                        labels, now with proper speaker ID's assigned

%% FUNCTION BODY

% assign modes
mode1 = 'minperm';
mode2 = 'spkID_vector_noreuse';
mode3 = 'spkID_vector_allowreuse';
%assign time index
labels_GT = [1:length(labels_GT); labels_GT];
labels_computed = [1:length(labels_computed); labels_computed];

%filter out non speech segments
labels_GT_speech = labels_GT(:,labels_GT(2,:) ~= 0);
labels_computed_speech = labels_computed(:,labels_computed(2,:) ~= 0);

%Give computed labels a new temp ID so they can all be reassigned
labels_computed_speech(2,:) = labels_computed_speech(2,:) + 1000;

if strcmp(assign_mode,mode1)
    
    %create copies that can be modified
    l_GT_speech_copy = labels_GT_speech;
    l_computed_speech_copy = labels_computed_speech;
    %amount of labels that don't have a proper speaker ID
    nr_noID = length(unique(labels_computed_speech(2,:)));
    %amount of available speaker ID's from the ground truth
    nr_availableID = length(unique(labels_GT_speech(2,:)));
    
    %maximum speaker ID in ground truth
    maxID = max(unique(labels_GT_speech(2,:)));
    ii = 1;
    %continue untill every label from the computed labels has a proper
    %speaker ID
    while nr_noID > 0
        %find speaker that occurs most
        [spk_most_computed,ID_freq_computed] = mode(l_computed_speech_copy(2,:));
        
        %check if there are valid ID's in the ground truth
        if nr_availableID > 0
            [spk_most_GT,ID_freq_GT] = mode(l_GT_speech_copy(2,:));
            labels_computed_speech(2,labels_computed_speech(2,:) == spk_most_computed) = spk_most_GT;
            l_GT_speech_copy(:,l_GT_speech_copy(2,:) == spk_most_GT) = [];
            nr_availableID = nr_availableID - 1;
        else
            labels_computed_speech(2,labels_computed_speech(2,:) == spk_most_computed) = maxID + ii;
            ii = ii + 1;
        end
        %remove from search
        l_computed_speech_copy(:,l_computed_speech_copy(2,:) == spk_most_computed) = [];
        
        %decrease amount of speakers with no valid ID
        nr_noID = nr_noID - 1;
    end
elseif strcmp(assign_mode,mode2)
    
    
    covmode1 =  'Diagonal';
    covmode2 =  'Full';
    covmode = Parameters.covmode;
    
    nr_noID = length(unique(labels_computed_speech(2,:)));
    tempIDs = unique(labels_computed_speech(2,:));
    nr_availableID = length(unique(labels_GT_speech(2,:)));
    availableIDs = unique(labels_GT_speech(2,:));
    maxID = max(unique(labels_GT_speech(2,:)));
    delta_BIC = zeros(nr_noID*nr_availableID,3);
    unclustered_z2_speech_computed = unclustered_z2(labels_computed_speech(1,:),:);
    unclustered_z2_speech_GT = unclustered_z2(labels_GT_speech(1,:),:);
    for ii = 1:nr_noID
        left_ID = tempIDs(ii);
        left_seg = unclustered_z2_speech_computed(labels_computed_speech(2,:) == left_ID,:).';
        for jj = 1:nr_availableID
            right_ID = availableIDs(jj);
            right_seg = unclustered_z2_speech_GT(labels_GT_speech(2,:) == right_ID,:).';
            if size(right_seg,2) > Parameters.assign_length 
                right_seg = right_seg(:,1:Parameters.assign_length);
            end
                if strcmp(covmode,covmode1)
                    BIC = segmental_BIC(left_seg,right_seg,lambda,Parameters);
                elseif strcmp(covmode,covmode2)
                    BIC = segmental_BIC_fullcov(left_seg,right_seg,lambda,Parameters);
                else
                    error('no valid covmode given');
                end
                
            %end
            delta_BIC((ii-1)*nr_availableID + jj,:) = [left_ID right_ID BIC];
        end
    end
    while nr_availableID > 0
        [~,BIC_idx] = min(delta_BIC(:,3));
        old_ID = delta_BIC(BIC_idx,1);
        new_ID = delta_BIC(BIC_idx,2);
        labels_computed_speech(2,labels_computed_speech(2,:) == old_ID) = new_ID;
        %remove entries corresponding to the ID's
        delta_BIC(delta_BIC(:,1) == old_ID,:) = [];
        delta_BIC(delta_BIC(:,2) == new_ID,:) = [];
        nr_availableID = nr_availableID - 1;
        nr_noID = nr_noID - 1;
    end
    if nr_noID ~= 0
        IDs = unique(labels_computed_speech(2,:));
        leftoverIDs = IDs(IDs >1000);
        for ii = 1:length(leftoverIDs)
            labels_computed_speech(2,labels_computed_speech(2,:) == leftoverIDs(ii)) = maxID + ii;
        end
    end
elseif strcmp(assign_mode,mode3)
    
    covmode1 =  'Diagonal';
    covmode2 =  'Full';
    covmode = Parameters.covmode;
    
    nr_noID = length(unique(labels_computed_speech(2,:)));
    tempIDs = unique(labels_computed_speech(2,:));
    nr_availableID = length(unique(labels_GT_speech(2,:)));
    availableIDs = unique(labels_GT_speech(2,:));
    maxID = max(unique(labels_GT_speech(2,:)));
    delta_BIC = zeros(nr_noID*nr_availableID,3);
    unclustered_z2_speech_computed = unclustered_z2(labels_computed_speech(1,:),:);
    unclustered_z2_speech_GT = unclustered_z2(labels_GT_speech(1,:),:);
    for ii = 1:nr_noID
        left_ID = tempIDs(ii);
        left_seg = unclustered_z2_speech_computed(labels_computed_speech(2,:) == left_ID,:).';
        for jj = 1:nr_availableID
            right_ID = availableIDs(jj);
            right_seg = unclustered_z2_speech_GT(labels_GT_speech(2,:) == right_ID,:).';
            if size(right_seg,2) > Parameters.assign_length 
                right_seg = right_seg(:,1:Parameters.assign_length);
            end
                if strcmp(covmode,covmode1)
                    BIC = segmental_BIC(left_seg,right_seg,lambda,Parameters);
                elseif strcmp(covmode,covmode2)
                    BIC = segmental_BIC_fullcov(left_seg,right_seg,lambda,Parameters);
                else
                    error('no valid covmode given');
                end
            %end
            delta_BIC((ii-1)*nr_availableID + jj,:) = [left_ID right_ID BIC];
        end
    end
    while nr_noID > 0
        [~,BIC_idx] = min(delta_BIC(:,3));
        old_ID = delta_BIC(BIC_idx,1);
        new_ID = delta_BIC(BIC_idx,2);
        labels_computed_speech(2,labels_computed_speech(2,:) == old_ID) = new_ID;
        %remove entries corresponding to the ID's
        delta_BIC(delta_BIC(:,1) == old_ID,:) = [];
        %delta_BIC(delta_BIC(:,2) == new_ID,:) = [];
        nr_availableID = nr_availableID - 1;
        nr_noID = nr_noID - 1;
    end
    if nr_noID ~= 0
        IDs = unique(labels_computed_speech(2,:));
        leftoverIDs = IDs(IDs >1000);
        for ii = 1:length(leftoverIDs)
            labels_computed_speech(2,labels_computed_speech(2,:) == leftoverIDs(ii)) = maxID + ii;
        end
    end    
else
    error('no valid assign mode');
end
            
labels_computed = zeros(1,size(labels_computed,2));
labels_computed(labels_computed_speech(1,:)) = labels_computed_speech(2,:);        
end

