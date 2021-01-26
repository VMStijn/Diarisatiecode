function [hyp] = constructREF(filename,precision)
fID = fopen(filename);
[readout] = textscan(fID,'%f %f %s');
temp = readout{1};
min_Boundaries = precision*round(temp(2:end)./precision);
temp = readout{2};
max_Boundaries = precision*round(temp(2:end)./precision);
temp = readout{3};
labels_ID = temp(2:end);
labels_ID = cellfun(@str2double,labels_ID);
hyp = [labels_ID,min_Boundaries,max_Boundaries];
end

