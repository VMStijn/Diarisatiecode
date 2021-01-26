clear;
fid = fopen('BWstats_list.txt','rt');
filenames = textscan(fid, '%s');
fclose(fid);
dataList = filenames{1};
ubmFilename = 'Results/UBM_MEL.mat';
tv_dim = [30 60 100] % diarization paper uses 20 for low comp time but other papers suggest 100 of higher
niter = 10;
nworkers = 1;
for i = 1:length(tv_dim)
    
    tvFilename = sprintf('Results/TV_MEL_DIM_%i.mat',tv_dim(i));

    T = train_tv_space(dataList, ubmFilename, tv_dim(i), niter, nworkers, tvFilename);
end