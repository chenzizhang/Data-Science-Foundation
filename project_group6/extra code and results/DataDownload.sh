wget https://raw.githubusercontent.com/coatless/stat490uiuc/master/airlines/airlines_data.sh
chmod u+x airlines_data.sh

./airlines_data.sh 2000 2000
mv airlines.csv AirlineData00.csv
./airlines_data.sh 2007 2007
mv airlines.csv AirlineData07.csv

cp AirlineData00.csv AirlineData0007.csv
tail -n+2 AirlineData07.csv >>AirlineData0007.csv
