clear;
%Open list with all features
fid = fopen('calc_features.txt', 'rt');
filenames = textscan(fid, '%s');
fclose(fid);
datalist = filenames{1};

%Load UBM
ubm = 'Results/UBM_MEL.mat';

%Calculate all Baum-Welch statistics
nfeats = length(datalist);
for i = 1:nfeats
    [~, feat_fname,~] = fileparts(datalist{i});
    BWstat_fname = [pwd, '/BWstats/' ,feat_fname, '_BWstats.mat'];
    feat_fname = [pwd, '/MELfeatures/',datalist{i}];
    [N,F] = compute_bw_stats(feat_fname,ubm,BWstat_fname);
end

