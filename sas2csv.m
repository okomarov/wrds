function sas2csv(dtname)
% Import sas command
fid = fopen('sas2csv.sas');
str = fread(fid,'*char')';
fclose(fid);
% Fill in dataset and temp file
str = sprintf(str,  dtname, outfile, dtname, outfile);

end