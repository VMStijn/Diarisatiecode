function [Header] = Construct_Header(Parameters)
% This function will check the given parameters to build a header that
% appears at the top of the results cell.

%Start from standard Header that'll be expanded later on.
Header_All = { 'filename', 'nr spk desired','f_length','smoothing','lambda_B','lambda_C','nr Boundaries','nr Speakers'};

%Check how many assign modes* are evaluated in this run (min 1, max 3)
%   *assign mode = how is a meaningful label assigned to the calculated
%                  diarization
nr_Assign = length(Parameters.assign_mode);
for i = 1:nr_Assign
    Header_Add = {['DER - ',Parameters.assign_mode{i}], 'nr Meaningful Speakers'};
    Header_All = [Header_All, Header_Add];
end
    Header = Header_All;
end

