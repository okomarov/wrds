filename outfile pipe "zip -r > myfile.zip ";

proc sql noprint;
 select '"'||trim(name)||'"'
 into :names
 separated by " ','"
 from dictionary.columns
 where libname eq "CRSPA" and
 memname eq "MSI"
 ;
quit;

data _null_;
 set CRSPA.MSI;
 file outfile mod dsd dlm=',' lrecl=1000000;
 if _n_ eq 1 then put &names.;
 put (_all_) (+0); 
run;