*Question 1;
DATA hockey;
	INFILE "~/MyRawData/hockey.csv" FIRSTOBS = 2 DLM = ",";
	INPUT Date :MMDDYY10. Team :$17. City :$17. State :$13. OSU OPP;
	IF Team = "Boston College" THEN DO;
			OSU = 2;
			OPP = 5;
		END;
	IF OSU > OPP THEN W + 1;
	ELSE IF OSU < OPP THEN L + 1;
	ELSE T + 1;
RUN;

PROC PRINT DATA = hockey;
	TITLE "Hockey data";
	FORMAT Date MMDDYY8.;
RUN;

*Question 2;
DATA roman;
	DO arabic = 1 to 50;
		roman = arabic;
		FORMAT roman ROMAN7.;
		OUTPUT; *without output statement, will end up with only 1 observation;
	END;
RUN;

*Question 3;
Data dogs;
	INFILE '~/MyRawData/dogs3.txt' FIRSTOBS = 3;
	INPUT dogname :$1-8 week0 13-16 week2 21-24 week4 29-32;
RUN;

DATA dogslong;
	SET dogs;
	week = "0";
	eos = week0;
	OUTPUT;
	
	week = "2";
	eos = week2;
	OUTPUT;
	
	week = "4";
	eos = week4;
	OUTPUT;
	
	DROP week0 week2 week4;
RUN;

PROC PRINT DATA = dogs;
	TITLE "Dogs data wide form";
RUN;

PROC PRINT DATA = dogslong;
	TITLE "Dogs data long form";
RUN;

*Question 4;
DATA ryan;
	INFILE "~/MyRawData/ryan.txt" FIRSTOBS = 2 DLM = '09'x MISSOVER;
	INPUT title :$24. roger nytimes usat;
	ARRAY ratings {3} roger nytimes usat;
	DO i = 1 to 3;
		IF ( ratings{i} = . ) THEN ratings{i} = 5;
	END;
	DROP i;
RUN;

PROC PRINT DATA = ryan;
	TITLE "Ryan data corrected";
RUN;

*Question 5;
*Define macro;
%MACRO largestdate(Data = );
PROC SORT DATA = &Data;
	BY DESCENDING Date;
RUN;

DATA largest;
	SET &Data (obs = 10);
RUN; 

PROC PRINT DATA = largest;
	TITLE "&Data data with 10 most recent dates";
	FORMAT Date DATE9.;
RUN;

%MEND largestdate;

*hockey data;
DATA hockey;
	INFILE "~/MyRawData/hockey.csv" FIRSTOBS = 2 DLM = ",";
	INPUT Date :MMDDYY10. Team :$17. City :$17. State :$13. OSU OPP;
	IF Team = "Boston College" THEN DO;
			OSU = 2;
			OPP = 5;
		END;
RUN;

*Clinton data;
DATA old;
	INFILE "~/MyRawData/clinton.txt" FIRSTOBS = 3;
	INPUT Day $7-8 Month $10-12 Year $14-17 Approve 24-25 Disapprove 32-33 Noop 40-41;
	*concatenate Day, Month, Year into a string, and then convert into date variable;
	Date = INPUT(CATS(Day, Month, Year), DATE10.);
	DROP Day Month Year;
RUN;

DATA new;
	INFILE DATALINES DLM = "09"x;
	INPUT Date :MMDDYY7. Approve Disapprove Noop;
	DATALINES;
8-18-98		66		29		5
8-20-98		61		34		5
8-21-98		62		35		3
9-1-98		62		33		5
9-10-98		60		37		3
9-11-98		63		34		3
;
RUN;
*Concatenate two data sets Old and New;
DATA clinton_combine;
	SET old new;
RUN;

*Use Macro on the two data sets;
%largestdate(Data = hockey);
%largestdate(Data = clinton_combine);

*Question 6;
DATA grades;
	INFILE "~/MyRawData/grades.txt" DLM = "";
	INPUT student $4. @6 (score1-score13) (1.); 
	ARRAY score{13};
	Total = 0; *set total back to 0 for each observation;
	DO Weeks = 1 to 13 UNTIL (Total ge 60);
		 Total + score{Weeks};
	END;
RUN;

PROC PRINT DATA = grades;
	VAR student Weeks;
RUN;

	
*Question 7;
*Use only polls taken in year 1998;
DATA clinton98;
	SET clinton_combine; *clinton_combine was created in question 5;
	IF YEAR(Date) = 1998;
RUN;

*Sort data by date in increasing order;
PROC SORT DATA = clinton98;
	BY Date;
RUN; 

*Create 2 new variables;
DATA clinton98new;
	SET clinton98;
	
	*Trend of percentage approving;
	lastapprove = LAG1(Approve);
	LENGTH Trend $ 10;
	IF Approve > lastapprove THEN Trend = "Increased";
	ELSE IF Approve < lastapprove THEN Trend = "Decreased";
	ELSE Trend = "No change";
	IF _N_ = 1 THEN Trend = "First poll"; *First in year 1998;
	
	*Elapsed days from the previous poll;
	lastdate = LAG1(Date);
	Elapsed = INTCK("Day", lastdate, Date);
	
	DROP lastapprove lastdate;
RUN;

PROC PRINT DATA = clinton98new;
	TITLE "Clinton data year 1998";
	FORMAT Date DATE9.;
RUN;

*Question 8;
DATA airport;
	INFILE "~/MyRawData/airport.csv" FIRSTOBS = 2 DLM = ",";
	INPUT city :$26. state $ abrev $ pass95 pass85;
RUN;

*Transpose airport data;
PROC TRANSPOSE DATA = airport OUT = airportnew NAME = Year PREFIX = City;
RUN;

*Print the two data sets;
PROC PRINT DATA = airport;
	TITLE "Airport data";
RUN;

PROC PRINT DATA = airportnew;
	TITLE "Airport data transposed";
RUN;

*Question 12;
DATA scores;
	ARRAY pass_score{5} _temporary_ (65, 70, 60, 62, 68);
	ARRAY Score{5};
	INPUT ID :$3. Score1-Score5;
	NumberPassed = 0;
	DO i = 1 to 5;
		NumberPassed + (Score{i} ge pass_score{i});
	END;
	DROP i;
	DATALINES;
001 90 88 92 95 90
002 64 64 77 72 71
003 68 69 80 75 70
004 88 77 66 77 67
;
RUN;

PROC PRINT DATA = scores;
	TITLE "Number of passed exams";
RUN;