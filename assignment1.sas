* Question 1; 
LIBNAME homework "H:\cat\MySASLib";
DATA homework.airports;
	INFILE "H:\cat\MyRawData\airport.csv" FIRSTOBS = 2 DLM = ",";
	INPUT city :$26. state $ abrev $ pass95 pass85;
RUN;

PROC PRINT DATA = homework.airports;
	TITLE "Airport Data";
RUN;

*Question 2;
DATA ryan;
	INFILE "H:\cat\MyRawData\ryan.txt" FIRSTOBS = 2 DLM = '09'x MISSOVER;
	INPUT title :$24. roger nytimes usat;
RUN;
PROC PRINT DATA = ryan;
	TITLE "Ryan Data";
RUN;

*Question 3;
DATA hockey;
	INFILE "H:\cat\MyRawData\hockey.csv" FIRSTOBS = 2 DLM = ",";
	INPUT Date :MMDDYY10. Team :$17. City :$17. State :$13. OSU OPP;
RUN;
PROC PRINT DATA = hockey;
	TITLE "Hockey Data";
RUN;

*Question 4;
DATA limes;
	INFILE "H:\cat\MyRawData\limes.txt" FIRSTOBS = 2 DLM = "," MISSOVER;
	INPUT Date :MMDDYY10. FruitDia FruitLength FruitWt FruitVol JuiceVol JuiceWt PeelWt;
RUN;
PROC PRINT DATA = limes;
	TITLE "Limes Data";
RUN;

*Question 5;
DATA hanks;
	INFILE "H:\cat\MyRawData\hanks.txt" FIRSTOBS = 2 DSD;
	INPUT Title $ 1-25 Year 26-29 Length 34-36 MPAA $ 42-46 Action 50-51 Drama 58-59 
 	Humor 66-67 Sex 74 Violence 82-83 Suspense 90 Offbeat 98;
RUN;

PROC PRINT DATA = hanks;
	TITLE "Hanks Data";
RUN;
