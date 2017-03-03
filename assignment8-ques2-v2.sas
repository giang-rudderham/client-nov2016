*Question 2;
DATA sat;
	INFILE DATALINES DLM = "09"x; 
	INPUT year  lower  upper;
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