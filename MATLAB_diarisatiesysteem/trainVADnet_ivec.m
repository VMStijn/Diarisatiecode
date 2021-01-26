%% Train VAD net (i-vectors)
clear
%set precision (0.2 or 0.05)
precision = 0.2;
%when changing precision you need to change filenames as well
extractionlength = 1;
%choose either 'Thuis' or 'VRT'
dataset = 'Thuis'
if strcmp(dataset,'Thuis')
z1_path = [pwd '\2702_1210091206390806321\ivectors.mat'];
load(z1_path);
ivector = ivector';
anno_path = [pwd '\2702_1210091206390806321\2702_1210091206390806321_Annotations.txt'];
[labels_GT,VAD_GT,begin_seq,end_seq] = read_anno_ivector_Alt(anno_path,precision,1);
begin_idx = round(begin_seq/precision);
end_idx = round((end_seq-extractionlength)/precision);
ivector = ivector(begin_idx:end_idx,:);
seq_length = size(ivector,1);
anno_length = size(labels_GT,2);
if seq_length ~= anno_length
            diff = seq_length-anno_length;
            if diff < 0
                Add_ivec = repmat(ivector(end,:),abs(diff),1);
                ivector = [ivector; Add_ivec];
            elseif diff > 0
                ivector = ivector(1:end-diff,:);
            end
end
temp = [VAD_GT.' ivector];

z1_path = [pwd '\2703_1210091205378844921\ivectors.mat'];
load(z1_path);
ivector = ivector';
anno_path = [pwd '\2703_1210091205378844921\2703_1210091205378844921_Annotations.txt'];
[labels_GT,VAD_GT,begin_seq,end_seq] = read_anno_ivector_Alt(anno_path,precision,1);
begin_idx = round(begin_seq/precision);
end_idx = round((end_seq-extractionlength)/precision);
ivector = ivector(begin_idx:end_idx,:);
seq_length = size(ivector,1);
anno_length = size(labels_GT,2);
if seq_length ~= anno_length
            diff = seq_length-anno_length;
            if diff < 0
                Add_ivec = repmat(ivector(end,:),abs(diff),1);
                ivector = [ivector; Add_ivec];
            elseif diff > 0
                ivector = ivector(1:end-diff,:);
            end
end
sampledata = [temp; VAD_GT.' ivector];
elseif strcmp(dataset,'VRT')
z1_path = [pwd '\20090914\ivectors.mat'];
load(z1_path);
ivector = ivector';
anno_path = [pwd '\20090914\20090914_Annotations.txt'];
[labels_GT,VAD_GT,begin_seq,end_seq] = read_anno_ivector_Alt(anno_path,precision,1);

seq_length = size(ivector,1);
anno_length = size(labels_GT,2);
if seq_length ~= anno_length
            diff = seq_length-anno_length;
            if diff < 0
                Add_ivec = repmat(ivector(end,:),abs(diff),1);
                ivector = [ivector; Add_ivec];
            elseif diff > 0
                ivector = ivector(1:end-diff,:);
            end
end
temp = [VAD_GT.' ivector];

z1_path = [pwd '\20091111\ivectors.mat'];
load(z1_path);
ivector = ivector';
anno_path = [pwd '\20091111\20091111_Annotations.txt'];
[labels_GT,VAD_GT,begin_seq,end_seq] = read_anno_ivector_Alt(anno_path,precision,0.2);
seq_length = size(ivector,1);
anno_length = size(labels_GT,2);
if seq_length ~= anno_length
            diff = seq_length-anno_length;
            if diff < 0
                Add_ivec = repmat(ivector(end,:),abs(diff),1);
                ivector = [ivector; Add_ivec];
            elseif diff > 0
                ivector = ivector(1:end-diff,:);
            end
end
sampledata = [temp; VAD_GT.' ivector];    
else
    error('NO valid dataset');
end
traindata = sampledata(:,2:end).';
trainlabels = sampledata(:,1).';
VADnet = perceptron;
VADnet = train(VADnet,traindata,trainlabels);
save('VADnet.mat', 'VADnet');