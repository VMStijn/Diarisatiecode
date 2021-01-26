function [labeled_GroundTruth,VAD,begin_seq,end_seq] = read_Annotation(filename_annotations,precision,sequence_Length)
%% Reads out the annotation and assigns labels accordingly
labeled_GroundTruth = [];

fID = fopen(filename_annotations);
[readout] = textscan(fID,'%f %f %s');
temp = readout{1};
begin_Sequence = temp(1)
min_Boundaries = [0; precision*round((temp(3:end)-0.200)./precision)];

temp = readout{2};
end_Sequence = temp(1) ;
max_Boundaries = precision*round((temp(2:end)-0.200)./precision);

temp = readout{3};
labels = temp(2:end);

annotation_Length = round(((end_Sequence - begin_Sequence)- 0.200)/precision) + 1;
if (annotation_Length - sequence_Length) > 10e-10
    error('Annotation is Wrong');
end


segment_Lengths = [1; round((max_Boundaries - min_Boundaries)./precision)];
segment_Lengths = segment_Lengths(segment_Lengths ~= 0);
if any(segment_Lengths(segment_Lengths<0))
    error('negative segment length');
end
if (sum(segment_Lengths) - sequence_Length) > 10e-10
    error('too much/not enough segments in sequence annotation');
end
for i = 1: length(labels)
    
    pad = str2double(labels{i}).*ones(segment_Lengths(i),1);
    labeled_GroundTruth = [labeled_GroundTruth ;pad];
end
 VAD = labeled_GroundTruth ~= 0;  
 begin_seq = precision*round(begin_Sequence/precision);
 end_seq = precision*round(end_Sequence/precision);
end

