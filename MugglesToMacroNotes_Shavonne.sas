data _null_;
set sashelp.class;
where name='Alfred';
%let alfred_age = age; 
run;

*macro variable alfred_age is literally assigned the value "age". 
It's important to now that the SAS compiler only sees this: 

data _null_
set sashelp.class
where name='Alfred';
*-----------------------------------------------------------------------------/

*Proc SQL and into: are used to get the values of a variable into a bucket at execution time. It is using SAS Code 
inside of proc sql data set so that sas can recognize it at execution time and store the values. From here you can invoke the 
maceo facility now and use macro variables and refrences... etc ;

proc sql noprint; 
select age 
into:alfred_age
from sashelp.class
where name='Alfred';
quit;
*-----------------------------------------------------------------------------/

*Incantation 1 Creating a Macro Variable List using PROC SQL;

*part 1;
proc sql noprint; 
select distinct origin
into :origin1-
from sashelp.cars
order by origin;
%let numorigins = &sqlobs; *SQLOBS IS A SYSTEM MACRO;
quit;
%put There were &sqlobs distinct values


*part 2; *Using Macro Variable List;


%do i = 1 %to &numorigins;
%put Item &i: &&origin&i;
%end;

*-----------------------------------------------------------------------------/

*Example #1. Dynamic Report Creation

Goal: Create a separate plot in a separate PDF file for each unique value
of STOCK in the SASHELP.STOCKS dataset.

Muggle approach: Code a seperate call to PROC SGPLOT for each unique value 
of STOCK. 

Macro Wizard approach: Use a macro variable list to dynamically generate the
calls to PROC SGPLOT.

Josh's SG Plot paper 
https://support.sas.com/resources/papers/proceedings19/3167-2019.pdf;


*Muggle Code;

ods pdf file="IBM.pdf";
proc sgplot data=sashelp.stocks;
where stock="IBM";
highlow x=date high=high low=low;
run;
ods pdf close;

*Macro Wizard;

%macro graph_stocks;

proc sql noprint; 
select distinct stock
into :stock1-
from sashelp.stocks; 

%let numstocks = &sqlobs; 

quit;

*each iteration of the %do loop generates the code to plot one stock;
%do i= 1 %to &numstocks; 

ods html file="&&stock&i...pdf"; *The extra dots are called "Two-pass macro variable resolution;
proc sgplot data=sashelp.stocks; 
where stock = "&&stock&i";
highlow x=date high=high low=low;
run;
ods pdf close;
%end; 
%mend graph_stocks; 

%graph_stocks

/*-----------------------------------------------------------------------------*/


/*Example #2: Building Variable Attributes */



*Muggle Code ;

proc print data=sashelp.class;
run;

options varlenchk = nowarn;
data myclass;
attrib name length = $7 label = 'student name';
attrib age length = 3 label = 'age'; 
attrib sex length = $1 label = 'sex';
attrib height length = 8 label = 'height';
attrib weight length = 8 label = 'weight';
attrib bmi length = 8 label = 'body mass index' format = 8.2; 

set sashelp.class; 
call missing(bmi);
run;

proc print data=work.myclass;
run;

*macro wizard code;
proc sql noprint; 
select variable, label, type, len, format
into :var1 - , 
	 :lbl1 - ,
	 :typ1 - ,
	 :len1 - ,
	 :fmt1 - 
from attrs; 
%let numvars = &sqlobs;
quit;
	 
	

%macro attrib(dsn =); 
data myfile; 


%do i = 1 %to &numvars; 
attrib &&var&i
%if &&len&i ne %then %do; 
%if &&typ&i = Char %then length = $&&len&i; 
%else length = &&len&i; 
%end; 


%if &&fmt&i ne %then format = &&fmt&i; 
%if &&lbl&i ne %then label = "&&lbl&i";

; 

%end;

call missing(of _all_); 

set &dsn; 

run;
%mend attrib;

%attrib(dsn = sashelp.class);

/*Incantation #2: Automated Macro Variables

Several automatic macro variables are created when a SAS session starts.
Some can be quite usefull for dynamic programming:

Macro Variable/ Description / Sample Value 

SYSDATE9 / Current date in DATE9 format / 17APR2024
SYSERR / Return code status from last step executed / 0 
SYSLAST / Name of last SAS dataset created/modified / Work.class
SYSNOBS / Number of observations in last dataset created/modified / 19 
SYSSCP / Identifier of the current operating system / WIN 
SYSUSERID / System ID of current user / rwatson 

To write current values of all automatic macro variables to the log: 
%put _automatic_; 









;


	
	 






























