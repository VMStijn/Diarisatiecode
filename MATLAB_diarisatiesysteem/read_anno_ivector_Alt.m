function [labels_spk,VAD,begin_seq,end_seq] = read_anno_ivector_Alt(filename,precision,windowlength)
% Reads out the annotation and assigns labels accordingly
%% INPUTS
%   filename =     txt file with
%   precision =    the precision of the 

%% OUTPUTS
%   delta_BIC =     Bayesian information criterion (value)

%% FUNCTION BODY
labeled_GroundTruth = [];

fID = fopen(filename);
[readout] = textscan(fID,'%f %f %s');
temp = readout{1};
min_Boundaries = precision*round(temp(2:end)./precision);
%min_Boundaries = [0; precision*round((temp(3:end)-0.200)./precision)];
begin_Sequence = temp(1);
temp = readout{2};
end_Sequence = temp(1) ;
max_Boundaries = precision*round(temp(2:end)./precision);
temp = readout{3};
labels_ID = temp(2:end);
begin_seq = precision*round(begin_Sequence/precision);
end_seq = precision*round(end_Sequence/precision);
seg_lengths = round((max_Boundaries - min_Boundaries)./precision);
for i = 1: length(labels_ID)   
    pad = str2double(labels_ID{i}).*ones(seg_lengths(i),1);
    labeled_GroundTruth = [labeled_GroundTruth ;pad];
end

i = 1;
windowL = round(windowlength/precision);
startL = 1;
finL = windowL;
Seq = labeled_GroundTruth(startL:finL);
labels_spk(i) = mode(Seq);
hopL = round(precision/precision);
while finL < size(labeled_GroundTruth,1)
    finL = min(finL + hopL,size(labeled_GroundTruth,1));
    startL = startL + hopL;
    i = i + 1;
    Seq = labeled_GroundTruth(startL:finL);
    labels_spk(i) = mode(Seq);
end
VAD = labels_spk ~= 0;
end
