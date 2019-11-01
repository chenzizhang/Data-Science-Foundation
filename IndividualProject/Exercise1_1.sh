
# Change to the data directory if we are not already in that director.
cd ~/Stat480/RDataScience/AirlineDelays

# Open a new file to enter shell code for combining csv file content.
vi combinescript_new

# Insert the following modified code from page 222 of Data Science in R in the file
# and then write and quit out of the file. We will just work with the 1980s data.
# To insert, type i . Then you can type or paste into the editor.
# To save the changes and exit the editor, first type the <Esc> key, then type :wq and hit <Enter> 
cp 1990.csv AirlineData1990_1995.csv
	for year in {1991..1995}
		do
		tail -n+2 $year.csv >>AirlineData1990_1995.csv
done

# At command line, make the file executable and then run the script.
chmod u+x combinescript_new
./combinescript_new

# See entire storage currently used on .
df -h

# rm 198*.csv
# rm 199*.csv
# rm 20**.csv

