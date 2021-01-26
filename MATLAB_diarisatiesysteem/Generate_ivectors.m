%This script generates i-vectors based on an already trained UBM and
%T-matrix


clear;
%specify filenames and models used
filenames = {'20091111','20090218','20090914'};
UBM = 'UBM_MEL.mat';
tvFilename = 'TV_MEL_DIM_30.mat';

for i = 1:length(filenames)
    filepath = [pwd,'/', filenames{i}, '/' filenames{i}, '.wav'];
    [y,fs] = audioread(filepath);
    %account for stereo signals
    if size(y,2) > 1
        y = sum(y,2)./2;
    end
    %set number of MFCC's (will be one less as log energy is included)
    numCoeffs = 20;
    deltaWindowLength = 5;

    windowDuration = 0.025;
    hopDuration = 0.01;

    windowSamples = round(windowDuration*fs);
    hopSamples = round(hopDuration*fs);
    overlapSamples = windowSamples - hopSamples;
    
    [coeffs] = mfcc(y,fs,'WindowLength',windowSamples,'OverlapLength',overlapSamples,'NumCoeffs',20,'LogEnergy','Replace');
    feat = coeffs';
    totalduration = size(feat,2);
    %extraction length: Default = 100 or 1 second
    segmentduration = 100;
    %sets overlap length (L_ov,ivec in text)
    overlap = 0.95;
    ivector = [];
    test =[];
    %for j = 1:(1-overlap)*segmentduration:totalduration
    start = 1;
    fin = segmentduration;
    test = [test, [start;fin]];
        subfeat = feat(:,start:min(fin,totalduration));
        [N,F] = compute_bw_stats(subfeat, UBM );
        stats = [N;F];
        subvec = extract_ivector(stats, UBM, tvFilename);
        ivector = [ivector, subvec];
    while fin < totalduration
        %start = round(j);
        start = round(start + (1-overlap)*segmentduration);
        fin = round(min(fin + (1-overlap)*segmentduration,totalduration));
        %fin = round(min(j + segmentduration-1,totalduration));
        test = [test, [start;fin]];
        subfeat = feat(:,start:fin);
        [N,F] = compute_bw_stats(subfeat, UBM );
        stats = [N;F];
        subvec = extract_ivector(stats, UBM, tvFilename);
        ivector = [ivector, subvec];
        
    end
    ivecpath = [pwd, '/', filenames{i},'/', 'ivectors_50ms.mat'];
    save(ivecpath,'ivector');
end
