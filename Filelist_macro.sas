%macro fileList
      (directory=,    /* Directory to read */
       out=,          /* Output data set to create */
       extensions=    /* Space delimited extensions to include. Not case sensitive.
                         Leave blank to not subset based on extension */
      );
 /*----------------------------------------------------------------------------------
   Copyright (c) 2005 Henderson Consulting Services, LLC
   This copyright notice may be moot given its publication on sasCommunity.org.
   Please simply acknowledge sasCommunity.org as the source should you decide to
   download and use this macro.

   PROGRAM      : fileList
   PROGRAMMER   : Don Henderson
   PURPOSE      : Creates a data set that contains all the files found in the
                  specified directory.
   ASSUMPTIONS  : None.
   USAGE        : %fileList(directory=c:\)
   COMMENT      : Can optionally specify whether the list is to be subset to certain
                  types of files (based on the extension).
                  If no output data set name specified, the SAS DATAn convention
                  is used.
 |----------------------------------------------------------------------------------|
 |  MAINTENANCE HISTORY                                                             |
 |----------------------------------------------------------------------------------|
 |  DATE    | WHODUNIT  | DESCRIPTION OF CHANGE                                     |
 |----------|-----------|-----------------------------------------------------------|
 | 10/2005  |Don H.     | Original Creation
 ----------------------------------------------------------------------------------*/

 %if %length(&extensions) gt 0 %then
 %do;  /* convert to an upper case quoted list */

     %let extensions = %sysfunc(compbl(&extensions));
     %let extensions = "%lowcase(%sysfunc(tranwrd(&extensions,%str( )," ")))";

 %end; /* convert to an upper case quoted list */

 data &out;

  keep fileName extension directoryOrFile;
  length fileName $256 extension $16 directoryOrFile $1 fileref $8;

  fileref = '        '; /* must be explicitly set to blank to have the filename 
                           function generate a fileref */
  rc = filename(fileref,"&directory");
  did=dopen(fileref);

  do i = 1 to dnum(did);

     fileName = dread(did,i);
     fid = mopen(did,fileName);
     extension = ' ';

     if fid then
     do;  /* files, but not directories can be opened */
        rc = fclose(fid);
        directoryOrFile = 'F';
        extension = lowcase(scan(fileName,-1,'.'));
     end; /* files, but not directories can be opened */
     else Dir_or_File = 'D';

     %if %length(&extensions) gt 0
         %then %str(if extension in (&extensions) then output;);
     %else %str(output;);

  end;

  rc = dclose(did);
  rc = filename(fileref);

 run;

%mend fileList;

%*fileList(directory = \\wilbtib\wilbtib05\AZ AZD3610C00001\AZD3610C00001 Part E\TLF\, out=files, extensions=sas);
