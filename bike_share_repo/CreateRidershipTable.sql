CREATE TABLE IF NOT EXISTS ridership2023 (
	-- unique identifier of trip
	trip_id int PRIMARY KEY,
	-- trip duration in seconds
	trip_duration int,
	-- start station identification number
	-- primary key in location table
	start_stn_id int,
	-- date and time trip started
	start_time timestamp,
	-- name of start station
	-- will be dropped when location table added
	start_stn_name VARCHAR(100),
	-- end station identification number
	-- primary key in location table
	end_stn_id int,
	-- date and time trip ended
	end_time timestamp,
	-- name of end station
	-- will be dropped when location table added
	end_stn_name VARCHAR(100),
	-- identity of rented bike
	bike_id int,
	-- whether user is casual or an annual member
	user_type VARCHAR(100)
);