###  	Data Acquisition

The [Toronto Open Data Portal](https://https://open.toronto.ca/) hosts datasets from many municipal government departments, including the Toronto Parking Authority, which runs Bike Share Toronto.

The website hosts ridership data covering the years 2014 to 2024. The last year with complete monthly data is 2023, with 12 cvs files available. The information is anonymized. Only whether a user is an annual member or a casual user is recorded.

The data includes the following information:

* Trip ID
* Trip Duration
* Trip Start Station ID
* Trip Start time
* Trip Start Station Location
* Trip End Station ID
* Trip End Time
* Trip End Station Location
* Bike ID
* User type

### Data Validation:

After loading the data, I ran the following checks:

* Data was available for 12 distinct month
```
SELECT
   DISTINCT EXTRACT(MONTH FROM start_time)
FROM ridership2023
```
* Data was available from 365 distinct days
```
SELECT 
	DISTINCT EXTRACT(DOY FROM start_time) 
FROM ridership2023
```
* Results were then compared to CSV files opened in Excel
* The number of rows in each month matches the number of rows in each csv file
```
SELECT 
	COUNT(trip_id) 
FROM ridership2023 
GROUP BY EXTRACT(MONTH FROM start_time)
```

### Data Cleaning

First, the data table was backed up:
```
/*
Back up the ridership2023 table.
*/
CREATE TABLE ridership2023_backup AS
SELECT * FROM ridership2023
```
Trips of less than one minutes duration should be excluded. These trips may represent people changing their minds after signing out the bike. These trips number 12198.
```
/*
Count number of trips with 
less than one minutes duration.
*/
SELECT
	COUNT(*)
FROM
	ridership2023
WHERE trip_duration <= 60
```
Several data columns have NULL values.  There were 
* 595,075 nulls in the start station name column
* 598,563 nulls in the end station name column
* 2944 nulls in the end station id columns
* No nulls in any other columns

```
/*
Count number of NULL data entries across 
the ridership2023 data table.
*/
SELECT
(SELECT COUNT(*) FROM ridership2023
	WHERE start_stn_name IS NULL) AS srt_stn_name_null,
(SELECT COUNT(*) FROM ridership2023
	WHERE start_stn_id IS NULL) AS srt_stn_id_null,
(SELECT COUNT(*) FROM ridership2023
	WHERE start_time IS NULL) AS strt_time_null,
(SELECT COUNT(*) FROM ridership2023
	WHERE end_stn_name IS NULL) AS end_stn_name_null,
(SELECT COUNT(*) FROM ridership2023
	WHERE end_stn_id IS NULL) AS end_stn_id_null,
(SELECT COUNT(*) FROM ridership2023
	WHERE end_time IS NULL) AS end_time_null,
(SELECT COUNT(*) FROM ridership2023
	WHERE bike_id IS NULL) AS bike_id_null,
(SELECT COUNT(*) FROM ridership2023
	WHERE user_type IS NULL) AS user_nulls

```

The null values in the end_station_name column (2944) may represent bikes that are either lost, stolen or removed from service. These rows represent trips that are incomplete.
Another query was run to examine these trips. The questions of interest are: 
* Do  rows missing an end_station_id also lack an end_station_name value, consistent with an incomplete trip?
* What is the average trip duration and modal trip duration for trips without an end_stn_id?
* Are all the start_station_names present for trips that lack both an end_station_name and end_station_id?


<!-- /*
Data Cleaning: NULL values
Query to assess null values in end_station_id
*/
SELECT
	AVG(trip_duration) AS average_trip_time, COUNT (trip_duration),
	COUNT(trip_id) AS null_trips,
	(SELECT
		MODE()
		WITHIN GROUP(ORDER BY trip_duration)
		FROM ridership2023
		WHERE
		end_stn_id IS NULL and end_stn_name IS NULL
		) AS modal_duration,
	COUNT(DISTINCT start_stn_name) AS num_start_stn,
	COUNT(DISTINCT end_stn_name) AS num_end_stn
FROM
	ridership2023
WHERE
	end_stn_id IS NULL and end_stn_name IS NULL ; -->
   

When end_station_id is null:
* The average trip_duration is  2377.49 seconds
* The modal trip duration is 0 seconds
* There were 484 distinct station names for start stations
* There were 0 distinct station names for end stations

Because stations that lack both an end_station_name and end_station_id repesent incomplete trips, these trips will be dropped from the analysis.

