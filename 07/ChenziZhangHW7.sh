
# I have uploaded 'stocks.csv' (downloaded from https://github.com/oreillymedia/programming_hive) to 'chenziz2/input/' by Rstudio Cloud

cd ~/Stat480/hb-workspace/ch17-hive/hw7

# Start hive.
hive

-- exercise1

-- create records table to populate
CREATE TABLE stocks (market STRING, stocksymbol STRING, datemdy STRING, price_open FLOAT, price_high FLOAT, price_low FLOAT, price_close FLOAT, volume INT, price_adj_close FLOAT)
ROW FORMAT DELIMITED
  FIELDS TERMINATED BY ',';

-- populate table with data from sample.txt file
LOAD DATA LOCAL INPATH 'input/stocks.csv'
OVERWRITE INTO TABLE stocks;

-- see the rows in records
-- we can see the data that was added
SELECT * FROM stocks LIMIT 5;

# Result
hive> SELECT * FROM stocks LIMIT 5;
NASDAQ	ABXA	2009-12-09	2.55	2.77	2.5	    2.67	158500	2.67
NASDAQ	ABXA	2009-12-08	2.71	2.74	2.52	2.55	131700	2.55
NASDAQ	ABXA	2009-12-07	2.65	2.76	2.65	2.71	174200	2.71
NASDAQ	ABXA	2009-12-04	2.63	2.66	2.53	2.65	230900	2.65
NASDAQ	ABXA	2009-12-03	2.55	2.62	2.51	2.6	    360900	2.6
Time taken: 0.03 seconds, Fetched: 5 row(s)

-- exercise2

CREATE TABLE ibm (datemdy STRING, price_open FLOAT, price_high FLOAT, price_low FLOAT, price_close FLOAT, volume INT, price_adj_close FLOAT);

FROM stocks
INSERT OVERWRITE TABLE ibm
  SELECT datemdy, price_open, price_high, price_low, price_close, volume, price_adj_close
  WHERE market = 'NYSE' AND stocksymbol = 'IBM';

SELECT * FROM ibm LIMIT 5;

# Result
hive> SELECT * FROM ibm LIMIT 5;
2010-02-08	123.15	123.22	121.74	121.88	5718500	121.88
2010-02-05	123.04	123.72	121.83	123.52	8617000	122.97
2010-02-04	125.19	125.44	122.9	123.0	9126900	122.45
2010-02-03	125.16	126.07	125.07	125.66	4177100	125.1
2010-02-02	124.79	125.81	123.95	125.53	5899900	124.97
Time taken: 0.038 seconds, Fetched: 5 row(s)

-- exercise2.max

SELECT ibm.datemdy, ibm.price_high
FROM (
  SELECT MAX(price_high) AS max_price
  FROM ibm
)maxp JOIN ibm ON (maxp.max_price = ibm.price_high);

# Result
1968-04-15	649.88
Time taken: 37.42 seconds, Fetched: 1 row(s)


FROM ibm
SELECT datemdy, price_high
SORT BY price_high DESC LIMIT 1;

# Result
1968-04-15	649.88
Time taken: 37.792 seconds, Fetched: 1 row(s)

-- exercise2.min

SELECT ibm.datemdy, ibm.price_low
FROM (
  SELECT MIN(price_low) AS min_price
  FROM ibm
)minp JOIN ibm ON (minp.min_price = ibm.price_low);

# Result
1993-08-16	40.63
Time taken: 38.019 seconds, Fetched: 1 row(s)


FROM ibm
SELECT datemdy, price_low
SORT BY price_low ASC LIMIT 1;

# Result
1993-08-16	40.63
Time taken: 38.754 seconds, Fetched: 1 row(s)


-- exercise3

CREATE VIEW max_daily_spreads (stocksymbol, market, max_daily_spread)
AS
SELECT stocksymbol, market, MAX(price_high - price_low)
FROM stocks
GROUP BY stocksymbol, market;

SELECT MIN(max_daily_spread), AVG(max_daily_spread), MAX(max_daily_spread)
FROM max_daily_spreads;

# Result
0.0	9.29882749493392	146.5
Time taken: 43.174 seconds, Fetched: 1 row(s)

-- exercise4

CREATE VIEW market_records (market, stocksymbol, spread, price_high, price_low, datemdy)
AS
SELECT market, stocksymbol, (price_high - price_low), price_high, price_low, datemdy 
FROM stocks;

SELECT mt.market, stocksymbol, mt.largest_spread, price_high, price_low, datemdy
FROM (
  SELECT market, MAX(max_daily_spread) AS largest_spread
  FROM max_daily_spreads
  GROUP BY market
) mt JOIN market_records ON (mt.market = market_records.market AND mt.largest_spread = market_records.spread);

# Result
NASDAQ	INFY	146.5	    681.0	534.5	2000-02-11
NYSE	GTC	    67.54999	507.12	439.57	2000-04-04
Time taken: 64.194 seconds, Fetched: 2 row(s)







