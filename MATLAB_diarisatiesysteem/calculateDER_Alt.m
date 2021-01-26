function [DER] = calculateDER_Alt(REF,HYP)
%new DER calculation
Intersect_Matrix = zeros(size(HYP,1),size(REF,1));
for i = 1:size(HYP,1)
    for j = 1:size(REF,1)
        start = max(HYP(i,2),REF(j,2));
        fin = min(HYP(i,3),REF(j,3));
        itsL = max(0,fin-start);
        Intersect_Matrix(i,j) = itsL;
    end
end
total_Length = REF(end,3)-REF(1,2);

%count false alarms
SubM = Intersect_Matrix(:,REF(:,1) == 0);
SubM = SubM(HYP(:,1) ~=0,:);
FA = sum(sum(SubM));

%count misses
SubM = Intersect_Matrix(:,REF(:,1) ~= 0);
SubM = SubM(HYP(:,1) == 0,:);
MI = sum(sum(SubM));

%count confusion
CO = 0;
for i = 1:size(HYP,1)
    for j = 1:size(REF,1)
        if HYP(i,1) ~= 0 && REF(j,1) ~= 0
            if HYP(i,1) ~= REF(j,1)
                CO = CO + Intersect_Matrix(i,j);
            end
        end
    end
end

DER = (FA + MI + CO)/total_Length;
end

