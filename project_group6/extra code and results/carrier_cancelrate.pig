--load carrier data
carrier = LOAD 'final/carriers_pig.csv' USING PigStorage (',')
	AS (code:chararray,desc:chararray);
--load airline data
air = LOAD 'final/0007_pig.csv' USING PigStorage (',')
	AS ( Year:int, Month:int, DayofMonth:int, DayofWeek:int, DepTime:int, CRSDepTime:int, ArrTime:int, CRSArrTime:int, UniqueCarrier:chararray, FlightNum:int, TailNum:chararray, ActualElapsedTime:int, CRSElapsedTime:int, AirTime:int, ArrDelay:int, DepDelay:int, Origin:chararray, Dest:chararray, Distance:int, TaxiIn:int, TaxiOut:int, Cancelled:int, CancellationCode:int,Diverted:int, CarrierDelay:int, WeatherDelay:int, NASDelay:int, SecurityDelay:int, LateAircraftDelay:int);

--select specific columns from airline datasets
airr = FOREACH air GENERATE Year as year,Cancelled as cancelled, UniqueCarrier as uniquecarrier;

--join carrier and airline data (add carrier carrier description to uniquecarrier)
airc = JOIN airr BY uniquecarrier LEFT OUTER, carrier BY code;

--filter 2000 and 2007
airc00 = FILTER airc BY year==2000;
airc07 = FILTER airc BY year==2007;

--compute total flight counts and cancelled flight counts for each carrier
airgroup00 = GROUP airc00 BY carrier::desc;
airgroup07 = GROUP airc07 BY carrier::desc;
carrier_cancel_00 = FOREACH airgroup00 GENERATE group, COUNT(airc00.airr::cancelled) AS totalflights, SUM(airc00.airr::cancelled) AS cancelledflights;
carrier_cancel_rate_00 = FOREACH carrier_cancel_00 GENERATE $0, $1, $2, (float)$2/$1 AS cancelrate;

carrier_cancel_07 = FOREACH airgroup07 GENERATE group, COUNT(airc07.airr::cancelled) AS totalflights, SUM(airc07.airr::cancelled) AS cancelledflights;
carrier_cancel_rate_07 = FOREACH carrier_cancel_07 GENERATE $0, $1, $2, (float)$2/$1 AS cancelrate;

--dump and save results
STORE carrier_cancel_rate_00 INTO '2000pig';
STORE carrier_cancel_rate_07 INTO '2007pig';







