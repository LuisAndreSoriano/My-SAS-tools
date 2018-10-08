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
options noxwait;

%let password = nvud@#!dMOITg8080; /* to send to unblinded team */

/* Get a list of all datasets to output */

%sysexec "c:\Program Files\WinZip\Winzip64.exe" -min -a -s"&password."
         							"&G_projectpath.&G_toplevel\packaged deliverables\UNBLINDED_Clementia_CLMPVO2A201_&sysdate..zip"
			 /* UNBLINDED IWRS */	"&G_projectpath.&G_toplevel\Databases\Import Data\IWRS UNBLINDED\Output\Unblinded_iwrs.sas7bdat"
			 /* PK 					"&G_projectpath.&G_toplevel\Databases\Import Data\IWRS\Output\pk.sas7bdat"*/
		 ;



