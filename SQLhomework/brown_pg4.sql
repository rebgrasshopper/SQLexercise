#page 4 is reserved for creating the date_dim table in PROBLEM 4
#Place your INSERT statement as the very last command on this page (after the UPDATE), since it's very long. 

use da_bootcamp_brown;

DROP TABLE IF EXISTS date_dim;

CREATE TABLE IF NOT EXISTS date_dim (
	TheDate date PRIMARY KEY,
    TheYear int,
    TheMonth int,
    TheMonthName varchar(9), #January February March etc
    TheDay int,
    TheDayOfWeek int,
    TheDayOfWeekName varchar(9), #Sunday Monday Tuesday etc
    YYYYQQ char(6) #2019Q3, 2019Q4
);

UPDATE date_dim 
set 
	TheYear = YEAR(TheDate),
    #Provide rest of fields
    
;

SELECT * FROM date_dim;

/*** 
	INSERT into date_dim only column date_full. A few lines are provided.
	You must use Excel to generate the data. HINT: Use TEXT to convert a date value to YYYY-MM-DD, 
	then concatenate to get ('YYYY-MM-DD'), format
***/
INSERT INTO date_dim (TheDate) VALUES 
('2019-07-01'),
('2019-07-02'),
('2019-07-03'),
#...
('2019-12-31')