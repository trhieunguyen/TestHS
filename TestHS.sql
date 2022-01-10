--Import Excel file to Microsoft SQL Server 2017
SELECT * FROM Handshake..Log;
SELECT * FROM Handshake..Users;

--Get date data based on CreatedAt column
SELECT CreatedAt, CONVERT(DATE, CreatedAt)
FROM Handshake..Log;

--Create column CreatedAtDate with date value converted from column CreatedAt
ALTER TABLE Handshake..Log;
ADD CreatedAtDate DATE;

UPDATE Handshake..Log
SET CreatedAtDate = CONVERT(DATE, CreatedAt);

--Retrieve users that have logged in for any 3 consecutive days
--Approach 1
WITH CTE as (
SELECT DISTINCT UserID, CreatedAtDate
FROM Handshake..Log)

SELECT DISTINCT UserID from (
SELECT *, CASE WHEN (LAG(CreatedAtDate,1) OVER(PARTITION BY UserID order by CreatedAtDate)) = DATEADD(d, -1,CreatedAtDate) 
		  THEN 1 ELSE 0 END second_day ,
          CASE WHEN (LAG(CreatedAtDate,2) OVER(PARTITION BY UserID order by CreatedAtDate)) = DATEADD(d, -2,CreatedAtDate) 
		  THEN 1 ELSE 0 END third_day
FROM CTE) a 
WHERE a.second_day =1 and a.third_day =1;
--Approach 2
WITH CTE as (
SELECT UserID, Col1, ROW_NUMBER() OVER(PARTITION BY UserID, Col1 ORDER BY Col1) as PT
FROM 
(SELECT *, DATEADD(d, -ROW_NUMBER() OVER(PARTITION BY UserID ORDER BY CreatedAtDate),CreatedAtDate) as Col1
FROM (
SELECT DISTINCT UserID, CreatedAtDate
FROM Handshake..Log) b) c)

SELECT DISTINCT UserID
FROM CTE
WHERE PT >2