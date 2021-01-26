clear
%% Set filepaths/names
Parameters.filenames = {'20090914'};
Parameters.VADname = 'VADnet';
%Set General/Experiment parameters
%sets the precision of the features (set as extraction_length - overlap_length)
precision = 0.04
Parameters.precision = precision; 

%Length of selected fragment from ground truth to assign meaningful speaker ID's (only when using spkID, not when using minperm)
%Default: 60s
Parameters.assign_length = round(60/precision); 
% choose either 'ivector' or 'FHVAE'
Parameters.feat_type = 'FHVAE'; 
%governs how speaker labels are assigned, helps choose which ones are active
Parameters.assign_mode ={'spkID_vector_noreuse','spkID_vector_allowreuse','minperm'}; 
%choose either 'Diagonal' or 'Full'
Parameters.covmode = 'Diagonal'; 
%set to 1 if you want the system to calculate the condition numbers
Parameters.getCondNr = 1;
%Set dataset, choose either 'VRT' or 'Thuis'
%This option is necessary to cut away the intro and outro of the 'Thuis' data
DataSet = 'VRT'

%%Set Design Parameters (will iterate over these);
%frame length (Fl in text) default: 2s
f_length = [round(2/precision)];
%BIC parameter Default range: [0:0.1:4]
lambda_B = [0:0.1:4];
%BIC parameter Default range: [0:0.1:4]
lambda_C = [0:0.1:4];
%specify how many speakers you want or 0 if it's unknown
desired_spk = [0]; 
%sets a minimum segment length during the first pass (BIC_boundariesGEN)
%default: 1s
smoothing = [round(1/precision)]; 
smoothing = smoothing*2;
%extraction length of feature vectors
%FHVAE features: .2 (200ms)
%i-vectors: 1 (1s)
windowLength = .2;
P_500 = [];
R_500 = [];
P_1000 = [];
R_1000 = [];

nr_files = length(Parameters.filenames); 
nr_f_length = length(f_length);
nr_lambdaB = length(lambda_B);
nr_lambdaC = length(lambda_C);

extractionlength = windowLength;

nr_simulations = length(desired_spk)*nr_files*nr_f_length*nr_lambdaB*nr_lambdaC*length(smoothing);
msg = sprintf('Will run %i simulations',nr_simulations);
disp(msg);
nr_run = 1;

%Construct Results Header
Header = Construct_Header(Parameters);
results = cell(nr_simulations + 1,length(Header));
results(1,:) = Header;

for ii = 1:nr_files
    
    %Load Required Parameters from the structur
    filenames = Parameters.filenames;
    feat_type = Parameters.feat_type;
    precision = Parameters.precision;
    assign_mode = Parameters.assign_mode;
    if strcmp(feat_type,'ivector')
        % Load in file and annotations
        %uncomment line below if you want to work with a different overlap
        %length
        %feature_path = [pwd '\' filenames{ii} '\ivectors_50ms.mat'];
        feature_path = [pwd '\' filenames{ii} '\ivectors.mat'];
        tmp = load(feature_path);
        unclustered_z2 = tmp.ivector';
        annotation_path = [pwd '\' filenames{ii} '\' filenames{ii} '_Annotations.txt' ];
        [labels_GT,VAD_GT,begin_seq,end_seq] = read_anno_ivector_Alt(annotation_path,precision,1);
        anno_length = size(labels_GT,2);
        if strcmp(DataSet,'Thuis')
            begin_idx = round(begin_seq/precision);
            end_idx = round((end_seq-extractionlength)/precision);
            unclustered_z2 = unclustered_z2(begin_idx:end_idx,:);
            %begin_idx = round((begin_seq-1)/precision)+6; %necessary when working with partial annotation
            %end_idx = round((end_seq - 1)/precision)+1; %necessary when working with partial annotation
            %unclustered_z1 = unclustered_z1(begin_idx:end_idx,:);
            %unclustered_z2 = unclustered_z2(begin_idx:end_idx,:);
            %unclustered_z2 = unclustered_z2(449:3588,:);
            %unclustered_z2 = unclustered_z2(1795:14350,:);
        end
        
        seq_length = size(unclustered_z2,1);
        labels_computed = zeros(1,seq_length);
        Temp = load(Parameters.VADname);
        VADnet = Temp.(Parameters.VADname);
        VAD = VADnet(unclustered_z2.');
         if seq_length ~= anno_length
            diff = seq_length-anno_length;
            if diff < 0
                Add_VAD = zeros(abs(diff),1);
                Add_z2 = repmat(unclustered_z2(end,:),abs(diff),1);
                VAD = [VAD,Add_VAD];
                unclustered_z2 = [unclustered_z2; Add_z2];
            elseif diff > 0
                unclustered_z2 = unclustered_z2(1:end-diff,:);
                VAD = VAD(1:end-diff);
            end
        end
        
        ER = sum(VAD ~= VAD_GT)/length(VAD); %error of voice activity detector
         
        %smooth out VAD output
        for ss = 1:length(VAD)
            if ss ~= 1 && ss ~= length(VAD)
                if VAD(ss) == 0 && VAD(ss-1) ~= 0 && VAD(ss + 1) ~= 0
                    VAD(ss) = 1;
                end
            end
        end
        ER = sum(VAD ~= VAD_GT)/length(VAD);
        %VAD = VAD_GT;
        REF = constructREF(annotation_path,0.040);
    elseif strcmp(feat_type,'FHVAE')
        %Load FHVAE features and annotation
        %uncomment lines below if you want to use different overlap lengths
        %feature_path_z2 = [pwd '\' filenames{ii}  ' -10ms\z2_by_seq.npy'];
        %feature_path_z1 = [pwd '\' filenames{ii}   ' -10ms\z1_by_seq.npy'];
        %feature_path_z2 = [pwd '\' filenames{ii}  ' -100ms\z2_by_seq.npy'];
        %feature_path_z1 = [pwd '\' filenames{ii}   ' -100ms\z1_by_seq.npy']; 
        
        feature_path_z2 = [pwd '\' filenames{ii}  '\z2_by_seq.npy'];
        feature_path_z1 = [pwd '\' filenames{ii}   '\z1_by_seq.npy'];
        unclustered_z2 = double(readNPY(feature_path_z2));
        unclustered_z1 = double(readNPY(feature_path_z1));
        windowlength = 0.200;
        annotation_path = [pwd '\' filenames{ii} '\' filenames{ii} '_Annotations.txt' ];
        [labels_GT,VAD_GT,begin_seq,end_seq] = read_anno(annotation_path,precision,windowlength);
        REF = constructREF(annotation_path,0.040);
        anno_length = size(labels_GT,2);
        %remove intro and outro when working on Thuis data
        if strcmp(DataSet,'Thuis')
            begin_idx = round(begin_seq/precision);
            end_idx = round((end_seq-extractionlength)/precision);
            unclustered_z1 = unclustered_z1(begin_idx:end_idx,:);
            unclustered_z2 = unclustered_z2(begin_idx:end_idx,:);
            %unclustered_z1 = unclustered_z1(8969:71824,:);
            %unclustered_z2 = unclustered_z2(8969:71824,:);
            %unclustered_z1 = unclustered_z1(898:7183,:);
            %unclustered_z2 = unclustered_z2(898:7183,:);
        end
        seq_length = size(unclustered_z2,1);
        labels_computed = zeros(1,seq_length);
    
        Temp = load(Parameters.VADname);
        VADnet = Temp.(Parameters.VADname);
        VAD = VADnet(unclustered_z1.');
        %Pad vectors or cut away so sizes match up (sometimes theres a
        %small difference
        if seq_length ~= anno_length
            diff = seq_length-anno_length;
            if diff < 0
                Add_VAD = zeros(abs(diff),1);
                Add_z1 = repmat(unclustered_z1(end,:),abs(diff),1);
                Add_z2 = repmat(unclustered_z2(end,:),abs(diff),1);
                VAD = [VAD,Add_VAD];
                unclustered_z1 = [unclustered_z1; Add_z1];
                unclustered_z2 = [unclustered_z2; Add_z2];
            elseif diff > 0
                VAD = VAD(1:end-diff);
                unclustered_z1 = unclustered_z1(1:end-diff,:);
                unclustered_z2 = unclustered_z2(1:end-diff,:);
            end
        end
        %ER = sum(VAD ~= VAD_GT)/length(VAD);
        
        %smooth out VAD output
        for ss = 1:length(VAD)
            if ss ~= 1 && ss ~= length(VAD)
                if VAD(ss) == 0 && VAD(ss-1) ~= 0 && VAD(ss + 1) ~= 0
                    VAD(ss) = 1;
                end
            end
        end
        %ER = sum(VAD ~= VAD_GT)/length(VAD);
    else
        error('NO valid feature type, use either i vectors or FHVAE feature vectors');
    end
    %uncomment line below to switch VAD with manual annotation
    %VAD = VAD_GT;
    
    %calculate general speaker covariance matrix and add it to Parameters
    %to make it available for use everywhere
    spkcov = genspkcov(unclustered_z2,labels_GT);
    Parameters.spkcov = spkcov;
    for mm = 1:length(desired_spk)
    for jj = 1:nr_f_length
        for nn = 1:length(smoothing)
        for kk = 1:nr_lambdaB
            
            p_temp_500 = [];
            r_temp_500 = [];
            p_temp_1000 = [];
            r_temp_1000 = [];
            %generate initial segment boundaries
            labels = BIC_boundariesGEN(unclustered_z2,f_length(jj),lambda_B(kk),VAD,smoothing(nn),Parameters);
            for ll = 1:nr_lambdaC
                    %cluster the found segments
                    labels_spk = BIC_clusters(unclustered_z2,labels,lambda_C(ll),desired_spk(mm),Parameters);
                    
                    %Reinsert the non-speech segments if a VAD is given
                    if length(VAD) > 1
                        labels_computed(VAD == 1) = labels_spk(:,2);
                    else
                        labels_computed = labels_spk(:,2);
                    end
                    Temp = {filenames{ii},desired_spk(mm),f_length(jj),smoothing(nn),lambda_B(kk),lambda_C(ll),length(unique(labels(:,2))),length(unique(labels_spk(:,2)))}; 
                    
                    nr_Assign = length(assign_mode);
                    
                    %Perform relabeling and calculate the DER for all chosen relabel methods
                    for ss = 1:nr_Assign
                        
                        Labels_Final.(assign_mode{ss}) = assign_spkID(labels_GT,labels_computed,unclustered_z2,assign_mode{ss},lambda_C(ll),Parameters);
                        
                        HYP = constructHYP(Labels_Final.(assign_mode{ss})',precision,extractionlength);
                        HYP(:,2:3) = HYP(:,2:3)+begin_seq;
                        DER.(assign_mode{ss}) = calculateDER_Alt(REF,HYP);
                        Temp = [Temp, {DER.(assign_mode{ss}), length(unique(Labels_Final.(assign_mode{ss})))}];
                    end
                    
                    %precision recall calculation
                    %HYP_PR = constructHYP(labels_computed',precision,extractionlength);
                    %HYP_PR(:,2:3) = HYP_PR(:,2:3) + begin_seq;
                    %[p,r] = calcPR(REF,HYP_PR,0.500);
                    p=0;
                    r=0;
                    p_temp_500 = [p_temp_500, p];
                    r_temp_500 = [r_temp_500, r];
                    %[p,r] = calcPR(REF,HYP,1);
                    
                    
                    p_temp_1000 = [p_temp_1000, p];
                    r_temp_1000 = [r_temp_1000, r];
                    results(nr_run +1,:) = Temp;
                   
                    nr_run = nr_run + 1
            end
            P_500 = [P_500; p_temp_500];
            R_500 = [R_500; r_temp_500];
            P_1000 = [P_1000; p_temp_1000];
            R_1000 = [R_1000; r_temp_1000];
        end
        end
    end
    end
end
%Save some information about the run at the end to make it easier to
%evaluate later.
ResultInfo.filenames = filenames;
ResultInfo.VADname = Parameters.VADname;
ResultInfo.VAD_err = ER
ResultInfo.feat_type = feat_type;
ResultInfo.assign_mode = assign_mode;
ResultInfo.assign_length = Parameters.assign_length;
ResultInfo.covmode = Parameters.covmode;
ResultInfo.precision = precision;

ResultInfo.f_length = f_length;
ResultInfo.lambda_B = lambda_B;
ResultInfo.lambda_C = lambda_C;
ResultInfo.desired_spk = desired_spk;
ResultInfo.min_seglentgh = smoothing./2;

Resultname = ['DR_', feat_type,'_', Parameters.covmode];
if desired_spk ~= 0
    Resultname = [Resultname, '_NrSPKknown'];
else
    Resultname = [Resultname, '_NrSPKunknown'];
end
if not(isfolder([pwd '\results']))
    mkdir([pwd '\results']);
end
Result_path = [pwd '/results/' Resultname];
NameCheck = exist([Result_path,'.mat'],'file');
if NameCheck ~=0
    if NameCheck == 2
        Valid = 0;
        AltCounter = 1;
        while ~Valid
            Resultname_Alt = sprintf('%s_%i',Resultname,AltCounter);
            Result_path_Alt = [pwd '/results/' Resultname_Alt];
            NameCheck_Alt = exist([Result_path_Alt,'.mat'],'file');
            Valid = (NameCheck_Alt == 0);
            AltCounter = AltCounter + 1;
        end
        warning('Resultname already exists, saving as %s.mat instead',Resultname_Alt);
    else
        error('Resultname already exists, but uses other filetype');
    end
    Result_path = Result_path_Alt;
end
ResultInfo.results = results;
save(Result_path,'ResultInfo');


%Visualizing the result: example
% Labels_Final contains labels found with all chosen relabel methods
% Construct reference: REF = REF = constructREF(annotation_path,0.040);
% Construct hypothesis: HYP = constructHYP(Labels_Final.(assign_mode{ss})',precision,extractionlength);
%                                                    -> set ss to the preferred relabel method (1,2 or 3)
% Construct secondary hypothesis (not recquired): HYP2 = constructHYP(Labels_Final.(assign_mode{ss})',precision,extractionlength);
% Generate figure: visualize_diarization_New(REF,HYP,HYP2);

