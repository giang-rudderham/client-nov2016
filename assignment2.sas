*Question 1;
PROC FORMAT;
	VALUE agegroup low-30 = "0 to 30"
					31-50 = "31 to 50"
					51-70 = "51 to 70"
					71-high = "71 and older";
	VALUE $party "D" = "Democrat"
				 "R" = "Republican";
	VALUE $opinion "1" = "Strongly disagree"
				   "2" = "Disagree"
				   "3" = "No opinion"
				   "4" = "Agree"
				   "5" = "Strongly agree";
RUN;

DATA Voter; 
	INPUT Age Party $ (Ques1-Ques4) ($);
	LABEL Ques1 = "The president is doing a good job"
		  Ques2 = "Congress is doing a good job"
		  Ques3 = "Taxes are too high"
		  Ques4 = "Government should cut spending";
	FORMAT Age agegroup. Party $party. Ques1-Ques4 $opinion.;
	DATALINES;
23 D 1 1 2 2 
45 R 5 5 4 1
67 D 2 4 3 3
39 R 4 4 4 4
19 D 2 1 2 1
75 D 3 3 2 3
57 R 4 3 4 4
	;
RUN;

PROC PRINT DATA = Voter LABEL;
	TITLE "Voter data";
RUN;

*Question 2;
PROC FORMAT;
	VALUE $newop "1", "2" = "Generally Disagree"
					  "3" = "No Opinion"
				  "4","5" = "Generally Agree";
RUN; 
PROC FREQ DATA = Voter;
	TITLE "Frequencies for questions";
	TABLES Ques1-Ques4;
	FORMAT Ques1-Ques4 $newop.;
RUN;

*Question 3;
LIBNAME homework "H:\cat\MySASLib";
TITLE "Formats for the voter data";
PROC FORMAT LIBRARY = homework FMTLIB;
	VALUE agegroup low-30 = "0 to 30"
					31-50 = "31 to 50"
					51-70 = "51 to 70"
					71-high = "71 and older";
	VALUE $party "D" = "Democrat"
				 "R" = "Republican";
	VALUE $opinion "1" = "Strongly disagree"
				   "2" = "Disagree"
				   "3" = "No opinion"
				   "4" = "Agree"
				   "5" = "Strongly agree";
RUN;
OPTIONS FMTSEARCH = (homework);
DATA homework.voter;
	SET Voter;
	LABEL Ques1 = "The president is doing a good job"
		  Ques2 = "Congress is doing a good job"
	 	  Ques3 = "Taxes are too high"
		  Ques4 = "Government should cut spending";
	FORMAT Age agegroup. Party $party. Ques1-Ques4 $opinion.;
RUN;
PROC PRINT DATA = homework.voter LABEL;
	TITLE "Permanent Voter data set";
RUN;

*Question 4;
LIBNAME myformat "H:\cat\MyFormatLib";
OPTIONS FMTSEARCH = (myformat);
TITLE "New formats";
PROC FORMAT LIBRARY = myformat FMTLIB;
	VALUE YESNO 0 = "Yes" 1 = "No";
	VALUE $YESNO "YY" = "Yes" "NN" = "No";
	VALUE $Gender "MM" = "Male" "FF" = "Female";
	VALUE Age20yr low-30 = "1"
					31-50 = "2"
					51-70 = "3"
					71-high = "4";
RUN;

*Question 5;
DATA Places;
	INPUT Name :$1-10 Num1 Num2;
	DATALINES;
Readington 20 3
Raritan 10 10
Branchburg 3 18
Somerville 5 18
;
RUN;
ODS CSV FILE = "H:\cat\MyExportData\hw2-ques5.csv";
PROC PRINT DATA = Places NOOBS;
RUN;
ODS CSV CLOSE;
