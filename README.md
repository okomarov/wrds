### Description
High level Matlab API that interacts with the Wharton Reasearch Data Services (WRDS) Unix server and its SAS data sets through SSH2.
    
### Requirements
* An account with WRDS of the type that admits SSH connections (PhD or above). 
  See WRDS's [account types](http://wrds-web.wharton.upenn.edu/wrds/support/Additional%20Support/Account%20Types.cfm) for details.
* [Java enabled](http://www.mathworks.co.uk/help/matlab/ref/usejava.html)

### Syntax

Connect to WRDS Unix servers:

    w = wrds('username', 'password')

Execute commands:

    w.cmd('cmdstring')
    
Download .sas7bdat file to zipped .csv:

    w.sas2csv('libref.datasetname')

###Examples:

Print `Hello World` in the Unix shell and print result into Matlab's cmd window (Verbose)
```matlab
w = wrds('olegkoma','forgiveMeIfIDontTellYou');
w.Verbose = true;
w.cmd('echo "Hello World!"')
```

Download the [CRSPA/MSI dataset](http://wrds-web.wharton.upenn.edu/wrds/tools/variable.cfm?library_id=137&file_id=67079)

    w.sas2csv('CRSPA.MSI')
