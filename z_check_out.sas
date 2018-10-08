*************************************************************************
* 
*           CLIENT:  
*         PROTOCOL:  
*
*          PURPOSE:  To check out files currently not in my user area
*      
*      INPUT FILES:  
*     OUTPUT FILES:  
*
*      USAGE NOTES:  Fill out the dataset with files you want to check out
*      
************************************************************************* 
*  © 2018 PPD
*  All Rights Reserved. 
*************************************************************************;

%* USAGE:
> List all files in the macro variable FilesToCheckout delimited by space or enter-key.
> Include file extensions.
> NOT case-sensitive.
> Place this program in the user area you want check out to happen
;

%* Step 1: List all  files for check out or update;

%let FilesToCheckout =


;

****************** DO NOT EDIT BEYOND THIS POINT ******************;

	data files_to_checkout (keep = files_to_checkout x2);
		length files_to_checkout x2 $200.;
		N = countw(compbl(strip("&FilesToCheckout")), " ");
		do i = 1 to N;
			files_to_checkout = strip(scan("&FilesToCheckout",i, " "));
			x2 = upcase(files_to_checkout);
			output;
		end;
	run;

	proc sort data = files_to_checkout;
		by x2;
	run;

%* Step 2: List all files ready for check out or update;

	data _null_;
		repo0 = substr("&g_fullpath.", 3);
		if "&g_toplevel" = "Trunk" then repo1 = tranwrd(repo0, "&g_toplevel", "Repository\"||"&g_toplevel.");
		else repo1 = tranwrd(repo0, "&g_toplevel", "Repository\Branches\"||"&g_toplevel.");
		repo2 = reverse(substr(reverse(strip(repo1)),2));
		repo3 = '\'||tranwrd(repo2, '\', '/');
		repo4 = strip(tranwrd(strip(repo3),"/Users/&SYSUSERID./","/"));
		call symput('g_repo', strip(repo4));
	run;

	filename filelist pipe "svn list ""file:///&g_repo.""";

	data filelist;
		infile filelist truncover;
		input x $300.;
		x2 = upcase(x);
		proc sort data = filelist; by x2;
	run;

%* Step 3: Merge;
	
	data files_to_checkout2;
		merge
			filelist (in = a)
			files_to_checkout (in = b)
			;
		by x2;

		if b and not a then put "ALERT_R: >>>>> " files_to_checkout "not checked out! Please check.";
		if a and b then output;
	run;

	options noxwait;

	%put ALERT_I: LIST OF FILES CHECKED OUT/UPDATED-----------------------;
	data _null_;
		set files_to_checkout2;
		call execute(
		'%nrstr(
			%sysexec svn update "&g_fullpath.'||strip(x)||'";
		);'
		);
		put 'ALERT_I: ' x;
	run;
	%put ALERT_I: END----------------------------------------------------;

%* End of program;
