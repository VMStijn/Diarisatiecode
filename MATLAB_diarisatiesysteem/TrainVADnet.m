%% Train VAD net (FHVAE features)
clear
%set precision (0.1,0.01 or 0.04)
precision = 0.04;
%when changing precision you need to change filenames as well
extractionlength = 0.2;
%choose either 'Thuis' or 'VRT'
dataset = 'Thuis'
if strcmp(dataset,'Thuis')
z1_path = [pwd '\2702_1210091206390806321\z1_by_seq.npy'];
unclustered_z1 = double(readNPY(z1_path));
anno_path = [pwd '\2702_1210091206390806321\2702_1210091206390806321_Annotations.txt'];
[labels_GT,VAD_GT,begin_seq,end_seq] = read_anno(anno_path,precision,0.2);
begin_idx = round(begin_seq/precision);
end_idx = round((end_seq-extractionlength)/precision);
unclustered_z1 = unclustered_z1(begin_idx:end_idx,:);
seq_length = size(unclustered_z1,1);
anno_length = size(labels_GT,2);
if seq_length ~= anno_length
            diff = seq_length-anno_length;
            if diff < 0
                Add_z1 = repmat(unclustered_z1(end,:),abs(diff),1);
                unclustered_z1 = [unclustered_z1; Add_z1];
            elseif diff > 0
                unclustered_z1 = unclustered_z1(1:end-diff,:);
            end
end
temp = [VAD_GT.' unclustered_z1];

z1_path = [pwd '\2703_1210091205378844921\z1_by_seq.npy'];
unclustered_z1 = double(readNPY(z1_path));
anno_path = [pwd '\2703_1210091205378844921\2703_1210091205378844921_Annotations.txt'];
[labels_GT,VAD_GT,begin_seq,end_seq] = read_anno(anno_path,precision,0.2);
begin_idx = round(begin_seq/precision);
end_idx = round((end_seq-extractionlength)/precision);
unclustered_z1 = unclustered_z1(begin_idx:end_idx,:);
seq_length = size(unclustered_z1,1);
anno_length = size(labels_GT,2);
if seq_length ~= anno_length
            diff = seq_length-anno_length;
            if diff < 0
                Add_z1 = repmat(unclustered_z1(end,:),abs(diff),1);
                unclustered_z1 = [unclustered_z1; Add_z1];
            elseif diff > 0
                unclustered_z1 = unclustered_z1(1:end-diff,:);
            end
end
sampledata = [temp; VAD_GT.' unclustered_z1];
elseif strcmp(dataset,'VRT')
z1_path = [pwd '\20090914\z1_by_seq.npy'];
unclustered_z1 = double(readNPY(z1_path));
anno_path = [pwd '\20090914\20090914_Annotations.txt'];
[labels_GT,VAD_GT,begin_seq,end_seq] = read_anno(anno_path,precision,0.2);

seq_length = size(unclustered_z1,1);
anno_length = size(labels_GT,2);
if seq_length ~= anno_length
            diff = seq_length-anno_length;
            if diff < 0
                Add_z1 = repmat(unclustered_z1(end,:),abs(diff),1);
                unclustered_z1 = [unclustered_z1; Add_z1];
            elseif diff > 0
                unclustered_z1 = unclustered_z1(1:end-diff,:);
            end
end
temp = [VAD_GT.' unclustered_z1];

z1_path = [pwd '\20091111\z1_by_seq.npy'];
unclustered_z1 = double(readNPY(z1_path));
anno_path = [pwd '\20091111\20091111_Annotations.txt'];
[labels_GT,VAD_GT,begin_seq,end_seq] = read_anno(anno_path,precision,0.2);
seq_length = size(unclustered_z1,1);
anno_length = size(labels_GT,2);
if seq_length ~= anno_length
            diff = seq_length-anno_length;
            if diff < 0
                Add_z1 = repmat(unclustered_z1(end,:),abs(diff),1);
                unclustered_z1 = [unclustered_z1; Add_z1];
            elseif diff > 0
                unclustered_z1 = unclustered_z1(1:end-diff,:);
            end
end
sampledata = [temp; VAD_GT.' unclustered_z1];    
else
    error('NO valid dataset');
end
traindata = sampledata(:,2:end).';
trainlabels = sampledata(:,1).';
VADnet = perceptron;
VADnet = train(VADnet,traindata,trainlabels);
save('VADnet.mat', 'VADnet');