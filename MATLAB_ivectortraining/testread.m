fid = fopen('compa_listpath.txt','rt');
filenames = textscan(fid,'%s');
fclose(fid);
datalist = filenames{1};
datalist{1}
[test,fs] = audioread(datalist{1});