function [spkcov] = genspkcov(unclustered_z2,labels_GT)
%calculates average sample covariance matrix
labels_GT = [1:length(labels_GT); labels_GT];
labels_GT_speech = labels_GT(:,labels_GT(2,:) ~= 0);
nr_speakers = length(unique(labels_GT_speech(2,:)));
spk_means = zeros(nr_speakers,size(unclustered_z2,2)+1);
spkIDs = unique(labels_GT_speech(2,:));
unclustered_speech_GT = unclustered_z2(labels_GT(2,:) ~= 0,:);
for ii =1:nr_speakers
    spkID = spkIDs(ii);
    spk_means(ii,:) = [spkID,mean(unclustered_z2(labels_GT_speech(2,:) == spkID,:),1)];
end
MeanVec = zeros(size(unclustered_z2,2),size(labels_GT_speech,2));
for jj = 1:size(labels_GT_speech,2)
    MeanVec(:,jj) = spk_means(spk_means(:,1) == labels_GT_speech(2,jj),2:end);
end
spkcov = 1/(size(labels_GT_speech,2)-1)*(unclustered_speech_GT' - MeanVec)*(unclustered_speech_GT' - MeanVec)';

end

