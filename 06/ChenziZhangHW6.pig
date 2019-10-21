/* My reference book is "The Definitive Guide, Chapter16, Fourth Edition" by Tom White */
/* with Chapter16CodeSegments.sh modified by Darren Glosemeyer in Spring 2019. */

/* Data 'Data1920s.txt' and 'StationCodes.txt' are provided by Darren Glosemeyer at STAT480 Spring 19, modified from the reference book. */


/* Exercise 1 */

/* Create the records. */
/* I uploaded 'Data1920s.txt' and 'StationCodes.txt' by Browser into  ~/input/ncdc/micro-tab/ */
temprecords = LOAD 'input/ncdc/micro-tab/Data1920s.txt'
  AS (usafID:int, wbanID:int, year:int, temp:int);
stationcodes = LOAD 'input/ncdc/micro-tab/StationCodes.txt'
  AS (usafID:int, wbanID:int, station:chararray);

/* use left outer join to get results for all records in temprecords even when there is no matching value in stationcodes */
A = JOIN temprecords BY ($0, $1) LEFT OUTER, stationcodes BY ($0, $1);

/* do not need repeat columns $4(usafID), $5(wbanID) */
joinstation = FOREACH A GENERATE $0, $1, $2, $3, $6;

/* select 5 tuples from the joinstation relation */
ex1 = LIMIT joinstation 5;

/* store selected result */
STORE ex1 INTO 'hw6_1';


/* Exercise 2 */

/* group relation in Exercise1 by Station name */
grouped = GROUP joinstation BY $4;

/* for each group, count obervations, obtain max temperature, min temperature, average temperature */
ex2_stationtemp = FOREACH grouped GENERATE group,
	COUNT(joinstation),
    MAX(joinstation.temp), MIN(joinstation.temp), AVG(joinstation.temp);

/* select first 5 tuples from the  */
ex2 = LIMIT ex2_stationtemp 10;

/* store selected result */
STORE ex2 INTO 'hw6_2';


/* Exercise 3 */

/* order temperature data for every station by min temperature, from min to max*/
stationtemporder = ORDER ex2_stationtemp BY $3;

/* obtain the first one -- the station record with the min temperature */
C = LIMIT stationtemporder 1;

/* store C */
STORE C INTO 'hw6_3_station';

/* use FILTER to get station 'SODANKYLA's record from joinstation relation*/
lowtempstation = FILTER joinstation BY station == 'SODANKYLA';

/* group lowtempstation by station with year, get 'SODANKYLA's record for every year */
grouped2 = GROUP lowtempstation BY (year, station);

/* get the min temp, average temp, max temp at 'SODANKYLA' for each year */
ex3 = FOREACH grouped2 GENERATE FLATTEN(group),
				MIN(lowtempstation.temp), AVG(lowtempstation.temp), 
				MAX(lowtempstation.temp);

/* store selected result */
STORE ex3 INTO 'hw6_3';


/* Exercise 4 */

/* group temp and station relation, get obervations from each station for each year */
grouped3 = GROUP joinstation BY station;

/* for each station with year, calucate max temp deviation above avg temp and max temp below avg temp */
tempdeviation = FOREACH grouped3 GENERATE group,
						MAX(joinstation.temp) - AVG(joinstation.temp),
						AVG(joinstation.temp) - MIN(joinstation.temp);

/* order tempdeviation by max temp deviation above avg temp, using descenting order */
D = ORDER tempdeviation BY $1 DESC;

/* limit order to the first one, so I find the largest max temp deviation above avg temp observation*/
E = LIMIT D 1;

/* store E */
STORE E INTO 'hw6_4_station';

/* get the deviation data from ABERDEEN/DYCE AIRPO station */
F = FILTER joinstation BY station == 'ABERDEEN/DYCE AIRPO';

/* group ABERDEEN/DYCE AIRPO station deviation data by year */
grouped4 = GROUP F BY (station,year);

/* for each year, get the Max Temp Deviation below Avg Temp from ABERDEEN/DYCE AIRPO station */
ex4 = FOREACH grouped4 GENERATE FLATTEN(group), 
								AVG(F.temp) - MIN(F.temp);

/* store selected result */
STORE ex4 INTO 'hw6_4';













