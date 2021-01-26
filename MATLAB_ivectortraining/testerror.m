    featname = [];
    [y,fs] = audioread(datalist{i});
    windowSamples = round(windowDuration*fs);
    hopSamples = round(hopDuration*fs);
    overlapSamples = windowSamples - hopSamples;
    [~,featname,~] = fileparts(datalist{i});
    if size(y,2) > 1
        y = sum(y,2)./2;
    end
    [coeffs] = mfcc(y,fs,'WindowLength',windowSamples,'OverlapLength',overlapSamples,'NumCoeffs',20,'DeltaWindowLength',5,'LogEnergy','Replace');
    feat = [coeffs]';
    featname = [pwd '/MELfeatures/' featname '.mat'];
    save(featname,'feat');