************************************************************************
*        CLIENT NAME:   
*       PROGRAM NAME:   PP_Email.SAS
*             AUTHOR:   
*       DATE CREATED:   
*            PURPOSE:   Zips and e-mails the PP output
*        INPUT FILES:   
*       OUTPUT FILES:  
*
*        USAGE NOTES:   Put in your PP folder.
*                       Update the email address
*
*              NOTES:   
*
*   MODIFICATION LOG:   
*************************************************************************
* DATE          BY              DESCRIPTION
*************************************************************************
* MM/DD/YYYY    USERID          Complete description of modification made
*                               including reference to source of change.
*
*************************************************************************
*  © Pharmaceutical Product Development, Inc., 2009
*  All Rights Reserved.
*************************************************************************;

options mprint;

%macro ZIPME(outname=);
/* If the MPTable output has been created, remove it for the automated process */
options noxwait;

/* Get a list of all .rtf, files to output */

%let filecnt = 0;

%let rcsp=%sysfunc(filename(filerfsp,&g_fullpath.output));
%let didsp=%sysfunc(dopen(&filerfsp));
%if &didsp gt 0 %then %do;
  %let memcntsp=%sysfunc(dnum(&didsp));

  /* Loops through the output directory */
  %do i = 1 %to &memcntsp;
    %let namesp=%qsysfunc(dread(&didsp,&i));
	%put &namesp.;
	%if %index(&namesp,.sas7bdat) > 0 and &namesp. ne lab.sas7bdat and &namesp. ne formats.sas7bdat %then %do;
		  %let filecnt = %eval(&filecnt + 1);
		  %let file&filecnt. = &namesp;
		  %put &namesp.;
		%end;
	  %end;
  %let rcsp=%sysfunc(dclose(&didsp));
%end;
%global allfile;
%let allfile = ;
%do i = 1 %to 70;  %let allfile = %trim(%left(&allfile))  "&&file&i.."; %end; ;
%put &allfile.;

%sysexec cd "&g_fullpath.output";
%sysexec "c:\Program Files\WinZip\Winzip64.exe" -min -a
         "&G_projectpath.&G_toplevel\packaged deliverables\EDC.zip"
        &allfile. ;

%global allfile;
%let allfile = ;
%do i = 71  %to &filecnt.;  %let allfile = %trim(%left(&allfile))  "&&file&i.."; %end; ;
%put &allfile.;

%sysexec cd "&g_fullpath.output";
%sysexec "c:\Program Files\WinZip\Winzip64.exe" -min -a
         "&G_projectpath.&G_toplevel\packaged deliverables\EDC.zip"
        &allfile. ;

/* imaging datasets */
%sysexec "c:\Program Files\WinZip\Winzip64.exe" -min -a
		"&G_projectpath.&G_toplevel\packaged deliverables\Imaging.zip"
		/* DXA */		"&G_projectpath.&G_toplevel\Databases\Import Data\BioClinica\Output\dxa.sas7bdat"
		/* XR1 */		"&G_projectpath.&G_toplevel\Databases\Import Data\BioClinica\Output\xr1.sas7bdat"
		/* XR2 		"&G_projectpath.&G_toplevel\Databases\Import Data\BioClinica\Output\xr2.sas7bdat" */
		/* MR 		"&G_projectpath.&G_toplevel\Databases\Import Data\BioClinica\Output\mr.sas7bdat" */
		;

/* include import datasets */
%sysexec "c:\Program Files\WinZip\Winzip64.exe" -min -a
         						"&G_projectpath.&G_toplevel\packaged deliverables\BLINDED_Clementia_CLMPVO2A201_&sysdate..zip"
	         /* EDC */			"&G_projectpath.&G_toplevel\packaged deliverables\EDC.zip"
			 /* GCL */			"lab.sas7bdat" 
			 /* ECG */ 			"&G_projectpath.&G_toplevel\Databases\Import Data\BioTelemetry\Output\ecg.sas7bdat"
			 /* BLINDED IWRS */	"&G_projectpath.&G_toplevel\Databases\Import Data\IWRS BLINDED\Output\blinded_iwrs.sas7bdat"
			 /* Imaging */ 		"&G_projectpath.&G_toplevel\packaged deliverables\Imaging.zip"
			 /* PK */
		 ;

/* delete the original EDC.zip since it's already included in the final zip. */
%sysexec del "&G_projectpath.&G_toplevel\packaged deliverables\EDC.zip";
%sysexec del "&G_projectpath.&G_toplevel\packaged deliverables\Imaging.zip";

%mend;
%ZIPME(outname=EXTRACT);


