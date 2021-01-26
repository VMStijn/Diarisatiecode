function [DER] = calculate_DER(labeled_GroundTruth,labeled_Computed)
%Old DER calculation
if length(labeled_GroundTruth) ~= length(labeled_Computed)
    error('Annotation and cluster result have different lengths');
end
%% Calculates Diarization Error Rate
ref_Length = length(labeled_GroundTruth);
false_Alarm = 0;
miss = 0;
confusion = 0;
for ii = 1:length(labeled_GroundTruth)
    found_Label = labeled_Computed(ii);
    ref_Label = labeled_GroundTruth(ii);
    if found_Label ~= ref_Label
        if ref_Label == 0
            false_Alarm = false_Alarm + 1;
        elseif found_Label == 0
            miss = miss + 1;
        else
            confusion = confusion + 1;
        end
    end
end
DER = (false_Alarm + miss + confusion)/ref_Length;
                
    
end

