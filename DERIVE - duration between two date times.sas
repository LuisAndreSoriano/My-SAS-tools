

%MACRO duration(start_date=, start_time=, end_date=, end_time=, dur_name=);
	*** derivation of &dur_name. ***;

	* difference in days NOT CONSIDERING time points - this is not the real difference in days;
	if not missing(&end_date.) and not missing(&start_date.) then diff_day_INITIAL = &end_date._NUM - &start_date._NUM;

	* difference in seconds;
	* NOTE: includes diff_day_initial converted to seconds to properly compute difference in seconds BETWEEN DATES CONSIDERING time points - this is the starting point;
	if not missing(&end_time.) and not missing(&start_time.) then diff_seconds = (diff_day_initial * 86400) + &end_time._NUM - &start_time._NUM;

	* REAL difference in days = rounded down seconds over 86400;
	if not missing(diff_seconds) then diff_days = floor(diff_seconds/86400);

	* REAL difference in hours = rounded down remainder of seconds from above over 3600;
	if not missing(diff_seconds) then diff_hours = floor(mod(diff_seconds, 86400)/3600);

	* REAL difference in minutes = rounded down remainder of seconds from the above over 60;
	if not missing(diff_seconds) then diff_minutes = floor(mod(mod(diff_seconds, 86400), 3600)/60);

	* putting in words...;

	* days;
	if not missing(diff_days) then days = strip(put(diff_days, best.))||" day";

	* hours;
	if not missing(diff_hours) then hours = strip(put(diff_hours, best.))||" hr";

	* minutes;
	if not missing(diff_minutes) then minutes = strip(put(diff_minutes, best.))||" min";

	* &dur_name.;
	if not missing(diff_days) and not missing(diff_hours) and not missing(diff_minutes) then do;
		&dur_name. = strip(days)||", "||strip(hours)||", "||strip(minutes);
	end;

%MEND;