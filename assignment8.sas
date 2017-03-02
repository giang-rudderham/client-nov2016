*Question 1;
*Read data set. Create total, human, and two label variables;
DATA manatees;
	INFILE "~/MyRawData/manatees.txt" FIRSTOBS = 2 DLM = "09"x;
	INPUT year 4. waterc :2. lock :2. relat 1. perin :2. natur :3. undet :3.;
	total = waterc + lock + relat + perin + natur + undet;
	human = waterc + perin + lock + relat;
	tlabel = "T";
	hlabel = "H";
RUN;
*Scatterplot;
PROC SGPLOT DATA = manatees;
	TITLE "Manatee deaths by year";
	SCATTER x=year y=total /DATALABEL=tlabel LEGENDLABEL="Total deaths"; 
		*Use MARKERCHAR = tlabel if want to replace point with "T"--see Question 2;
		*Use SERIES instead of SCATTER if want time series plots--see Question 4;
	SCATTER x=year y=human /DATALABEL=hlabel LEGENDLABEL="Human-related deaths";
	XAXIS VALUES = (1974 to 1998 by 2)
		  LABEL = "Year";
	YAXIS LABEL = "Deaths";
RUN; 

*Question 2;
DATA sat;
	INFILE DATALINES DLM = "09"x; 
	INPUT year :4. lower :4. upper :4.;
	DATALINES;
2015	1200	1360
2014 	1170	1330
2013	1170	1330
2012	1140	1330
2011	1130	1320
2010	1110	1310
2009	1140	1310
2008	1120	1290
2007	1130	1300
2006	1150	1310
;
RUN;
*Create label variables;
DATA sat;
	SET sat;
	lowerlabel = "v";
	upperlabel = "^";
RUN;
*Scatterplot;
PROC SGPLOT DATA = sat;
	TITLE "Lower and upper quartiles of SAT scores";
	SCATTER x = year y = lower / MARKERCHAR = lowerlabel 
								MARKERCHARATTRS = (color=black)
								LEGENDLABEL = "Lower quartile";
	SCATTER x = year y = upper / MARKERCHAR = upperlabel 
								MARKERCHARATTRS = (color=red)
								LEGENDLABEL = "Upper quartile";
	XAXIS VALUES = (2005 to 2015 by 2)
		  LABEL = "Year";
	YAXIS LABEL = "SAT scores";
RUN;

*Question 3;
DATA iris;
	INFILE "~/MyRawData/iris.txt" FIRSTOBS=2;
	INPUT class :$10. @16 sl  @23 sw  @31 pl  @39 pw;
RUN;

PROC SORT DATA = iris;
	BY class;
RUN;

PROC SGPLOT DATA = iris UNIFORM = SCALE;
	BY class;
	SCATTER x = sl y = sw;
	LABEL class = "Species"
		  sl = "Sepal length"
		  sw = "Sepal width";
	TITLE "Sepal length and sepal width for 3 species of iris";
RUN;

*Question 4;
*Clinton data (code from hw6 question 5);
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
DATA clinton;
	SET old new;
	year = YEAR(Date);
RUN;

PROC SORT DATA = clinton;
	BY year;
RUN;
*Calculate average percent approval rating;
DATA clinton_avr;
	SET clinton;
	BY year;
	*Initialize to 0 for first observation of each year;
	IF (FIRST.year) THEN DO;
		Total = 0;
		N = 0;
		END;
	*Sum statement to calculate total;
	Total + Approve;
	*Calculate # observations in each year;
	IF (Approve ne .) THEN N + 1;
	*Calcualte average and output;
	IF (LAST.year) THEN DO;
		average = Total/N;
		OUTPUT;
		END;
RUN;

*Plot;
PROC SGPLOT DATA = clinton_avr;
	TITLE "Average Percent Approval Rating for President Clinton";
	SERIES x = year y = average / MARKERS; *option markers add points to series plot;
	XAXIS LABEL = "Year";
	YAXIS LABEL = "Approval Rating (%)";
RUN;

*Question 5;
* Cats data (from hw5 question 1);
DATA cats1;
	INFILE "~/MyRawData/cats1.txt";
	INPUT cat $ side $ @@;
RUN;

DATA cats2;
	INFILE "~/MyRawData/cats2.txt" FIRSTOBS = 2;
	INPUT cat :$1-8 side2 $9-12 week02 21-24 week12 29-32 week22 37-40;
	DROP week02 week22;
RUN;

DATA cats3;
	INFILE "~/MyRawData/cats3.txt" FIRSTOBS = 2;
	INPUT cat $ side3 $ week03 week13 week23;
	DROP week03 week23;
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
DATA cats;
	SET combine;
	IF side = side2 THEN DO;
							Treated = week12;
							Untreated = week13;
						END;
	ELSE DO;
			Treated = week13;
			Untreated = week12;
		END; 	
	namelabel = SUBSTR(cat, 1, 1);
RUN;

*Plot;
PROC SGPLOT;
	TITLE "GFR at week 1 for all cats";
	SCATTER x = Untreated y = Treated / MARKERCHAR = namelabel
										LEGENDLABEL = "Individual cat";
	SCATTER x = Untreated y = Untreated / MARKERATTRS = (SYMBOL = Plus COLOR = red);
	SCATTER x = Treated y = Treated / MARKERATTRS = (SYMBOL = Plus COLOR = blue);
RUN;

*Question 6;
DATA airports;
	INFILE "~/MyRawData/airport.csv" FIRSTOBS = 2 DLM = ",";
	INPUT city :$26. state $ abrev $ pass95 pass85;
	Plotchar = BYTE(_N_ + 32);
	citylabel = SUBSTR(city, 1, 1);
RUN;

PROC PRINT DATA = airports;
	TITLE "Airport Data";
RUN;

PROC SGPLOT DATA = airports;
	TITLE "Total passengers in 1985 and 1995 labelled by city name";
	SCATTER x = pass85 y = pass95 / DATALABEL = citylabel;
	XAXIS LABEL = "Total passengers 1985";
	YAXIS LABEL = "Total passengers 1995";
RUN;

PROC SGPLOT DATA = airports;
	TITLE "Total passengers in 1985 and 1995 labelled by plotchar variable";
	SCATTER x = pass85 y = pass95 / DATALABEL = plotchar;
	XAXIS LABEL = "Total passengers 1985";
	YAXIS LABEL = "Total passengers 1995";
RUN;

*Question 7;
DATA dogs1;
	INFILE "~/MyRawData/dogs1.txt" FIRSTOBS = 2;
	INPUT dog $1-8 conc $16-16 sex $17-17 age 30-32 haircoat $33-37 weight 45-48;
RUN;

PROC SGPLOT DATA = dogs1;
	TITLE "Male and female dogs in each treatment";
	VBAR conc / GROUP = sex GROUPDISPLAY = CLUSTER STAT = FREQ;
	XAXIS LABEL = "Treatment group";
RUN;

*Question 8;
DATA limes;
	INFILE "~/MyRawData/limes.txt" FIRSTOBS = 2 DLM = "," MISSOVER;
	INPUT Date :MMDDYY10. FruitDia FruitLength FruitWt FruitVol JuiceVol JuiceWt PeelWt;
RUN;

PROC SGPLOT DATA = limes;
	TITLE "Fruit diameters and fruit lengths";
	SCATTER x = fruitdia y = fruitlength;
	REFLINE 6 / AXIS = X;
	REFLINE 7 / AXIS = Y;
	XAXIS LABEL = "Fruit Diameters";
	YAXIS LABEL = "Fruit Lengths";
RUN;