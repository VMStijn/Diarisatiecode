function [P,R] = calcPR(REF,HYP,T_th)
% calculates precision and recall percentages
%% INPUTS
%   REF=        reference, constructed using manual annotation and
%               constructREF()
%   HYP=        system result, constructed using computed labels and
%               constructHYP()
%   T_th=       threshold time, determines when real and computed
%               boundaries are linked
%% OUTPUTS
%   P=          precision percentage
%   R=          recall percentage

%% FUNCTION BODY
REF = REF(REF(:,1) ~=0,:);
REF_temp = [];
i = 1;
while i <size(REF,1)
    spkID = REF(i,1);
    spkID_beg = REF(i,2);
    spkID_end = REF(i,3);
    j = i + 1;
    spkID_next = REF(j,1);
    cond = j <= size(REF,1) && spkID_next == spkID;
    while cond
        spkID_end = REF(j,3);
        j = j + 1;
        if j <= size(REF,1)
            spkID_next = REF(j,1);
        end
        cond = j <= size(REF,1) && spkID_next == spkID;
    end
    REF_temp = [REF_temp; spkID, spkID_beg, spkID_end];
    i = j;
        
end
    

REF = REF_temp;

HYP = HYP(HYP(:,1) ~=0,:);
HYP_temp = [];
i = 1;
while i <size(HYP,1)
    spkID = HYP(i,1);
    spkID_beg = HYP(i,2);
    spkID_end = HYP(i,3);
    j = i + 1;
    spkID_next = HYP(j,1);
    cond = j <= size(HYP,1) && spkID_next == spkID;
    while cond
        spkID_end = HYP(j,3);
        j = j + 1;
        if j <= size(HYP,1)
            spkID_next = HYP(j,1);
        end
        cond = j <= size(HYP,1) && spkID_next == spkID;
    end
    HYP_temp = [HYP_temp; spkID, spkID_beg, spkID_end];
    i = j;
        
end
    
if size(HYP_temp,1) >= 1
HYP = HYP_temp;
end
Real_bound = unique([REF(:,2);REF(:,3)]);
nr_Real = length(Real_bound);
Comp_bound = unique([HYP(:,2);HYP(:,3)]);
nr_Comp = length(Comp_bound);
nr_links = 0;    
for i = 1:nr_Real
    Diff = abs(Comp_bound - Real_bound(i));
    if any(Diff<T_th)
        nr_links = nr_links + 1;
        [~,idx] = min(Diff);
        Comp_bound(idx) = [];
    end
end
P = nr_links/nr_Real;
R = nr_links/nr_Comp;
end

