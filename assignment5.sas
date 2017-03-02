*Question 1;
* Read data;
DATA cats1;
	INFILE "H:\cat\MyRawData\cats1.txt";
	INPUT cat $ side $ @@;
RUN;

DATA cats2;
	INFILE "H:\cat\MyRawData\cats2.txt" FIRSTOBS = 2;
	INPUT cat :$1-8 side2 $9-12 week02 21-24 week1 29-32 week2 37-40;
	DROP week1 week2;
RUN;

DATA cats3;
	INFILE "H:\cat\MyRawData\cats3.txt" FIRSTOBS = 2;
	INPUT cat $ side3 $ week03 week1 week2;
	DROP week1 week2;
RUN;
*Sort data to prepare for merging;
PROC SORT DATA = cats1;
	BY cat;
RUN;
PROC SORT DATA = cats2;
	BY cat;
RUN;
PROC SORT DATA = cats3;
	BY cat;
RUN;
*Merge data;
DATA combine;
	MERGE cats1 cats2 cats3;
	BY cat;
RUN;
*Final answer;
DATA final;
	SET combine;
	IF side = side2 THEN DO;
							Treated = week02;
							Untreated = week03;
						END;
	ELSE DO;
			Treated = week03;
			Untreated = week02;
		END; 	
RUN;

PROC PRINT DATA = final;
	TITLE "Cats and their GFR at week 0";
	VAR cat Treated Untreated;
RUN;
*Question 2;
DATA soccer;
	INFILE "H:\cat\MyRawData\soccer.txt";
	INPUT number first $ last :$11. code1 $ height $ code2 $ code3$;
	*extract height in feet, convert to numeric by INPUT;
	feet = INPUT(SUBSTR(height, 1, 1), 1.);
	*extract height in inches, convert to numeric by INPUT;
	inch = INPUT(SUBSTR(height, 3), 2.);
	*convert height to meter, round to the second decimal place;
	height_meter = ROUND(feet * 0.3048 + inch * 0.0254, 0.01);
RUN;

PROC PRINT DATA = soccer;
	TITLE "Soccer data";
	VAR number first last height_meter;
	FORMAT height_meter 4.2;
RUN;

*Question 3;
DATA hockey;
	INFILE "H:\cat\MyRawData\hockey.csv" FIRSTOBS = 2 DLM = ",/";
	INPUT Month :2. Day :2. Year :4. Team :$17. City :$17. State :$13. OSU OPP;
RUN;

DATA revised;
	SET hockey;
	IF Team = "Boston College" THEN DO;
			OSU = 2;
			OPP = 5;
		END;
	Date = MDY(Month, Day, Year);
RUN;

PROC PRINT Data = revised;
	TITLE "Revised hockey data set";
	VAR Team City State OSU OPP Date;
	FORMAT Date Date9.;
RUN;
*Question 4;
DATA cars;
	INFILE "H:\cat\MyRawData\usedcars.txt" FIRSTOBS = 2 OBS = 51;
	INPUT year 1-2 manufacturer $9-18 model $24-34 @37 miles COMMA8. @48 price COMMA8. dealer $60-83;
RUN;
*sort by dealer and price. Minimum price occurs first for each dealer;
PROC SORT DATA = cars;
	BY dealer price;
RUN;
*extract chepeast car for each dealer;
DATA minprice;
	SET cars;
	BY dealer price; *without this line first.dealer would be uninitialized;
	IF first.dealer THEN OUTPUT;
	DROP miles;
RUN;

PROC PRINT DATA = minprice;
	TITLE "Least expensive car offered by each dealer";
RUN;

*Question 5;
LIBNAME homework "H:\cat\MySASLib";
DATA bread;
	INFILE "H:\cat\MyRawData\bread.txt" FIRSTOBS = 3 DLM = ",";
	INPUT dough $ water oil sugar salt milk flour yeast wheat oregano eggs;
RUN;

DATA homework.noegg;
	SET bread;
	IF eggs eq 0 THEN OUTPUT;
RUN;

PROC PRINT DATA = homework.noegg;
	TITLE "Bread recipes with no eggs";
RUN;

*Question 6;
DATA old;
	INFILE "H:\cat\MyRawData\clinton.txt" FIRSTOBS = 3;
	INPUT Day $7-8 Month $10-12 Year $14-17 Approve 24-25 Disapprove 32-33 Noop 40-41;
	*concatenate Day, Month, Year into a string, and then convert into date variable;
	Date = INPUT(CATS(Day, Month, Year), DATE10.);
	DROP Day Month Year;
RUN;

DATA new;
	INPUT Date MMDDYY10. Approve Disapprove Noop;
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

PROC SORT DATA = clinton_combine;
	BY DESCENDING Date;
RUN;

PROC PRINT DATA = clinton_combine;
	TITLE "Clinton data combined and sorted by date";
	FORMAT Date DATE9.;
RUN;

*Question 7;

%let path = H:\cat\MyRawData;
%put &path;
libname assign "&path";
options compress = yes mcompilenote = all mprint mlogic symbolgen;
%macro import(dataset);
proc import out = assign.&dataset
	datafile = "&path\&dataset" dbms = excel replace;
     getnames = yes;
     mixed = yes;
     scantext = yes;
     usedate = yes;
     scantime = yes;
run;
%mend import;

%import(Blood)

data blood;
	set assign.blood;
	combined = 0.001 * WBC + RBC;
RUN;

data subset_A subset_B;
	set blood;
	IF Gender = "Female" and BloodType = "AB" THEN OUTPUT subset_A;
	IF Gender = "Female" and BloodType = "AB" and Combined ge 14 THEN OUTPUT subset_B;
RUN;
*Alternative way;
data subset_a2;
	set assign.blood;
	where Gender = "Female" and BloodType = "AB";
	combined = 0.001 * WBC + RBC;
RUN;

data subset_b2;
	set assign.blood;
	combined = 0.001 * WBC + RBC;
	IF Gender = "Female" and BloodType = "AB" and combined ge 14;
RUN;

*Question 8;
DATA lowmale2 lowfemale2;
	set assign.blood;
	if chol ne . THEN DO;
				if Gender = "Female" and Chol < 100 THEN OUTPUT lowfemale2;
				if Gender = "Male" and Chol < 100 THEN OUTPUT lowmale2;
				END;
RUN;

*Alternative way;
data lowmale lowfemale;
	set assign.blood;
	where chol lt 100 and chol is not missing;
	if Gender = "Female" then output lowfemale;
	else if gender = "Male" then output lowmale;
RUN;
