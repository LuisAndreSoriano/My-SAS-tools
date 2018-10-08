*************************************************************************
* 
*           CLIENT:  Clementia
*         PROTOCOL:  PVO-1A-301
*
*          PURPOSE:  To automatically merge files from one branch to another
*      
*      INPUT FILES:  
*     OUTPUT FILES:  
*
*      USAGE NOTES: 
*      
************************************************************************* 
*  © 2018 PPD
*  All Rights Reserved. 
*************************************************************************;

%* USAGE:
> List all files in the macro variable FilesToMerge delimited by space or enter-key.
> Include file extensions.
> NOT case-sensitive.
> Place this program in the user area you want merge to happen
;

%* Step 1: Set up paths and URLs;

%let source_path = \\wilbtib\wilbtib07\Clementia CLMPVO2A201\Trunk\Data Reports; /* specify source path here, where do you want to merge from? */
%let target_path = &g_fullpath.; /* defaults to current. but you can also specify if you want to */

%* Step 2: List all  files for check out or update;

%let FilesToMerge =


test.txt
;

****************** DO NOT EDIT BEYOND THIS POINT ******************;
	options noxwait;

	data files_to_merge (keep = files_to_merge x2);
		length files_to_merge x2 $200.;
		N = countw(compbl(strip("&FilesToMerge")), " ");
		do i = 1 to N;
			files_to_merge = scan("&FilesToMerge",i, " ");
			x2 = upcase(files_to_merge);
			output;
		end;
	run;

	proc sort data = files_to_merge;
		by x2;
	run;

	%let source_toplevel = %scan(%sysfunc(tranwrd(&source_path.,&g_projectpath.,)),1,\);
	%let target_toplevel = %scan(%sysfunc(tranwrd(&target_path.,&g_projectpath.,)),1,\);

	data _null_;
		length repo0 repo1 repo2 repo3 repo4 $1000.;

		/* Source */
		repo0 = substr("&source_path", 3);
		if "&source_toplevel." = "Trunk" then repo1 = tranwrd(repo0, "&source_toplevel.", "Repository\"||"&source_toplevel.");
		else repo1 = tranwrd(repo0, "&source_toplevel.", "Repository\Branches\"||"&source_toplevel.");
		if index(reverse(strip(repo1)),"\") = 1 then repo2 = reverse(substr(reverse(strip(repo1)),2));
		else repo2 = strip(repo1);
		repo3 = '\'||tranwrd(repo2, '\', '/');
		repo4 = strip(tranwrd(strip(repo3),"/Users/&SYSUSERID./","/"));
		call symput('source_URL', strip(repo4));

		/* Target */
		repo0 = substr("&target_path.", 3);
		if "&target_toplevel." = "Trunk" then repo1 = tranwrd(repo0, "&target_toplevel", "Repository\"||"&target_toplevel.");
		else repo1 = tranwrd(repo0, "&target_toplevel.", "Repository\Branches\"||"&target_toplevel.");
		if index(reverse(strip(repo1)),"\") = 1 then repo2 = reverse(substr(reverse(strip(repo1)),2));
		else repo2 = strip(repo1);
		repo3 = '\'||tranwrd(repo2, '\', '/');
		repo4 = strip(tranwrd(strip(repo3),"/Users/&SYSUSERID./","/"));
		call symput('target_URL', strip(repo4));
	run;

	%put ALERT_I: Source Path is &source_path.;
	%put ALERT_I: Target Path is &target_path.;
	%put ALERT_I: Source URL &source_URL;
	%put ALERT_I: Target URL &target_URL;

	filename filelist pipe "svn list ""file:///&target_URL.""";

	data filelist;
		infile filelist truncover;
		input x $300.;
		x2 = upcase(x);
		proc sort data = filelist; by x2;
	run;

%* Step 3: Merge;
	
	data files_to_merge2;
		merge
			filelist (in = a)
			files_to_merge (in = b)
			;
		by x2;

		if b and not a then put "ALERT_R: >>>>> " files_to_merge "not merged! Please check.";
		if a and b then output;
	run;

	%put ALERT_I: LIST OF FILES TO MERGE-----------------------;
	data _null_;
		set files_to_merge2;
		call execute(
		'%nrstr(
			%sysexec svn merge "file:///&source_URL./'||strip(x)||'" "&target_path.'||strip(x)||'" --force;

		);'
		);
		put 'ALERT_I: ' x;
	run;
	%put ALERT_I: END----------------------------------------------------;

%* End of program;
