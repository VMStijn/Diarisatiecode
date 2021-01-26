function [] = Plot_res(best_mat,precision)
Best_result = load(best_mat);
Best_result = Best_result.best;
filename = Best_result{1};
z1_path = [pwd '\' filename '\z1_by_seq.npy'];
unclustered_z1 = double(readNPY(z1_path));
z2_path = [pwd '\' filename '\z2_by_seq.npy'];
unclustered_z2 = double(readNPY(z2_path));
load('VADnet');
VAD = VADnet(unclustered_z1.');
f_length = Best_result{2};
lambda_B = Best_result{3};
lambda_C = Best_result{4};

seq_length = size(unclustered_z2,1);
annotation_path = [pwd '\' filename '\' filename '_Annotations.txt' ];
labels_GT = read_anno(annotation_path,precision,seq_length);
labels_computed = zeros(seq_length,1);
labels = BIC_boundaries(unclustered_z2,f_length,lambda_B,VAD);
labels_spk = BIC_clusters(unclustered_z2,labels,lambda_C,0);
if length(VAD) > 1
    labels_computed(VAD == 1) = labels_spk(:,2);
else
    labels_computed = labels_spk(:,2);
end

%% Result Plot compared to GT
max_col_GT = max(unique(labels_GT));
max_col_computed = max(unique(labels_computed));
nr_colors = max(max_col_GT,max_col_computed);
colors = num2cell(distinguishable_colors(nr_colors+2),2);
figure;
subplot(2,1,1);
visualize_labels(labels_computed2,precision,colors,'computed diarization');
subplot(2,1,2);
visualize_labels(labels_GT,precision,colors,'Ground Truth');

end

