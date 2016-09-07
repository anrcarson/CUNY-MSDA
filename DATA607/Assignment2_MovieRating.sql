
### create movierating table
CREATE TABLE movierating(
  ID int PRIMARY KEY
  ,Reviewer nvarchar(50) NOT NULL
  ,Movie nvarchar(50) NOT NULL
  ,Rating int DEFAULT NULL
  );


## Load file
LOAD DATA LOCAL INFILE 'C:/Users/Andy/Desktop/Personal/Learning/CUNY/DATA607/MovieDB.csv' 
INTO TABLE movierating
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

## since missing (NULL) values are coerced to 0 by mysql on the import, replace all 0 in Ratings with NULL
UPDATE movierating
	SET Rating = null
WHERE Rating = 0;

##view results
SELECT * 
FROM movierating;