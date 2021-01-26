function [hyp] = constructHYP(labels,precision,windowL)
seq=[1];
hyp = [];
Times = [0:precision:(size(labels,1)-1)*precision; windowL:precision:(size(labels,1)-1)*precision+windowL];
for i = 2:size(labels,1)
    
    if round(labels(i-1)) == round(labels(i))
        seq = [seq, i];
    elseif round(labels(i-1)) ~= round(labels(i)) 
     
        
        start = Times(1,seq(1));
        fin = Times(1,seq(end)+1);
        hyp = [hyp; round(labels(i-1)),start,fin];
        seq = [i];
    end
    if i == size(labels,1)
       start = Times(1,seq(1));
        fin = Times(2,seq(end));
        hyp = [hyp; round(labels(i-1)),start,fin];
    end
        
end
end

