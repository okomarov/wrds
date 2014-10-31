* Taken from https://communities.sas.com/message/185605#185605;

* Write header line first;
PROC EXPORT DATA= %s (OBS=0)
            OUTFILE= "%s"
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;

* Write the data;
DATA _NULL_;
   SET %s;
   FILE  "%s" MOD DSD DLM=',' LRECL=1000000;
   PUT (_ALL_) (:);
RUN;