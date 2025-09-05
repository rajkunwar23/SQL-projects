-- 1142 Write an SQL query to find the average number of sessions per user for a period of 30 days ending 2019-07-27 inclusively, rounded to 2 decimal places. 
-- The sessions we want to count for a user are those with at least one activity in that time period.
USE mydb;
CREATE TABLE Activity(user_id int,session_id int,activity_date date,activity_type enum('open_session', 'end_session', 'scroll_down', 'send_message'));
INSERT INTO Activity VALUES(1,1,'2019-07-20','open_session'),
(1,1,'2019-07-20','scroll_down'),
(1,1,'2019-07-20','end_session'),
(2,4,'2019-07-20','open_session'),
(2,4,'2019-07-21','send_message'),
(2,4,'2019-07-21','end_session'),
(3,2,'2019-07-21','open_session'),
(3,2,'2019-07-21','send_message'),
(3,2,'2019-07-21','end_session'),
(3,5,'2019-07-21','open_session'),
(3,5,'2019-07-21','scroll_down'),
(3,5,'2019-07-21','end_session'),
(4,3,'2019-06-25','open_session'),
(4,3,'2019-06-25','end_session');

SELECT * FROM Activity;
 WITH x AS(
     SELECT DISTINCT user_id,COUNT(DISTINCT session_id) AS cnt
     FROM Activity
     WHERE  activity_date BETWEEN '2019-06-28' AND '2019-07-27'
	 GROUP BY user_id
     HAVING COUNT(*)>=1)
SELECT ROUND(AVG(cnt),2) AS average_sessions_per_user
FROM x;
     

-- 1225 Write an SQL query to generate a report of period_state for each continuous interval of days in the period from 2019-01-01 to 2019-12-31.
-- period_state is 'failed' if tasks in this interval failed or 'succeeded' if tasks in this interval succeeded.
-- Interval of days are retrieved as start_date and end_date.
-- Order result by start_date.
USE mydb;
CREATE TABLE failed (fail_date date);
INSERT INTO  failed VALUES('2018-12-28'),
('2018-12-29'),
('2019-01-04'),
('2019-01-05');

CREATE TABLE succeeded (success_date date);
INSERT INTO  succeeded VALUES('2018-12-30'),
('2018-12-31'),
('2019-01-01'),
('2019-01-02'),
('2019-01-03'),
('2019-01-06');


-- 1241 Write an SQL query to find number of comments per each post.
-- Result table should contain post_id and its corresponding number_of_comments, and must be sorted by post_id in ascending order.
-- Submissions may contain duplicate comments. You should count the number of unique comments per post.
-- Submissions may contain duplicate posts. You should treat them as one post.
CREATE TABLE Submissions (sub_id int ,parent_id int);
INSERT INTO Submissions VALUES (1,null),
(2,Null),
(1,Null),
(12,Null),
(3,1),
(5,2),
(3,1),
(4,1),
(9,1),
(10,2),
(6,7);

WITH distinct_posts AS(
     SELECT DISTINCT sub_id AS post_id
     FROM Submissions
     WHERE parent_id IS null)

SELECT d.post_id,COUNT(DISTINCT s.sub_id) AS number_of_comments
FROM distinct_posts d LEFT JOIN Submissions s
ON d.post_id=s.parent_id
GROUP BY d.post_id
ORDER BY d.post_id;
     
-- 1264 Write an SQL query to recommend pages to the user with user_id = 1 using the pages that your friends liked.
-- It should not recommend pages you already liked.
-- Return result table in any order without duplicates.
CREATE TABLE Friendship(user1_id int,user2_id int);
INSERT INTO Friendship VALUES(1,2),
(1,3),
(1,4),
(2,3),
(2,4),
(2,5),
(6,1);

CREATE TABLE Likes(user_id int,page_id int);
INSERT INTO Likes VALUES(1,88),
(2,23),
(3,24),
(4,56),
(5,11),
(6,33),
(2,77),
(3,77),
(6,88);

SELECT DISTINCT page_id AS recomended_pages
FROM Friendship f LEFT JOIN Likes l on f.user2_id=l.user_id
WHERE user1_id=1 AND page_id NOT IN(
                                 SELECT page_id
                                 FROM Likes
                                 WHERE user_id=1)
UNION
SELECT DISTINCT page_id AS recomended_pages
FROM Friendship f LEFT JOIN Likes l 
ON f.user1_id=l.user_id
WHERE user2_id=1 AND page_id NOT IN(
                                 SELECT page_id
                                 FROM Likes
                                 WHERE user_id=1)


-- 1270 Write an SQL query to find employee_id of all employees that directly or indirectly report their work to the head of the company.
-- The indirect relation between managers will not exceed 3 managers as the company is small.
-- Return result table in any order without duplicates.

CREATE TABLE Employees (employee_id int PRIMARY KEY,employee_name varchar(50),manager_id int);
INSERT INTO Employees VALUES( 1,'Boss',1),
( 3,'Alice',3),
( 2,'Bob',1),
( 4,'Daniel',2),
( 7,'Luis',4),
( 8,'Jhon',3),
( 9,'Angela',8),
( 77,'Robert',1);


-- 1285 Since some IDs have been removed from Logs. Write an SQL query to find the start and end number of continuous ranges in table Logs.
-- Order the result table by start_id.
CREATE TABLE Logs(log_id int PRIMARY KEY);
INSERT INTO Logs VALUES(1),
(2),
(3),
(7),
(8),
(10);

SELECT l1.log_id AS start_id,l2.log_id AS end_id
FROM (SELECT log_id
FROM Logs
WHERE log_id-1 NOT IN (SELECT * FROM Logs)
) AS l1,
(SELECT log_id
FROM Logs
WHERE log_id+1 NOT IN (SELECT * FROM Logs)
)AS l2
WHERE l1.log_id<=l2.log_id
GROUP BY l1.log_id;

-- to off the sql_mode=only_full_group_by use SET sql_mode = '';
-- to undo use SET sql_mode = @@global.sql_mode;


-- 1294 Write an SQL query to find the type of weather in each country for November 2019.
-- The type of weather is Cold if the average weather_state is less than or equal 15, Hot if the average weather_state is greater than or equal 25 and Warm otherwise.
CREATE TABLE Countries (country_id  int PRIMARY KEY ,country_name varchar(50));
INSERT INTO Countries VALUES(2,'USA'),
(3,'Australia'),
(7,'Peru'),
(5,'China'),
(8,'Morocco'),
(9,'Spain');

CREATE TABLE Weather (country_id int NOT NULL,weather_state int,day date NOT NULL,PRIMARY KEY(country_id,day));
INSERT INTO Weather VALUES(2,15,'2019-11-01'),
(2,12,'2019-10-28'),
(2,12,'2019-10-27'),
(3,-2,'2019-11-10'),
(3,0,'2019-11-11'),
(3,3,'2019-11-12'),
(5,16,'2019-11-07'),
(5,18,'2019-11-09'),
(5,21,'2019-11-23'),
(7,25,'2019-11-28'),
(7,22,'2019-12-01'),
(7,20,'2019-12-02'),
(8,25,'2019-11-05'),
(8,27,'2019-11-15'),
(8,31,'2019-11-25'),
(9,7,'2019-10-23'),
(9,3,'2019-12-23');
DROP TABLE Weather;
SELECT * FROM weather;

SELECT DISTINCT c.country_name,CASE WHEN w.weather_state<=15 THEN 'Cold'
			WHEN w.weather_state>=25 THEN 'Hot'
            ELSE 'Warm'  END AS weather_type
FROM countries c LEFT JOIN weather w
ON c.country_id=w.country_id
WHERE w.day BETWEEN '2019-11-01' AND '2019-11-30'; 

-- 1303 Write an SQL query to find the team size of each of the employees.
CREATE TABLE Employee(employee_id int PRIMARY KEY,team_id int);
INSERT INTO Employee VALUES(1,8),
(2,8),
(3,8),
(4,7),
(5,9),
(6,9);
WITH cte AS (
SELECT team_id,COUNT(*) AS cnt
FROM Employee
GROUP BY team_id)
SELECT e.employee_id,c.cnt AS team_size
FROM Employee e JOIN cte c
ON e.team_id=c.team_id;

-- 1308 Write an SQL query to find the total score for each gender at each day. Order the result table by gender and day.
CREATE TABLE Scores(player_name varchar(50),gender varchar(50) NOT NULL,day date NOT NULL,score_points int,PRIMARY KEY(gender,day));
INSERT INTO Scores VALUES('Aron','F','2020-01-01',17),
('Alice','F','2020-01-07',23),
('Bajrang','M','2020-01-07',7),
('Khali','M','2019-12-25',11),
('Slaman','M','2019-12-30',13),
('Joe','M','2019-12-31',3),
('Jose','M','2019-12-18',2),
('Priya','F','2020-12-31',23),
('Priyanka','F','2020-12-30',17);
SELECT * FROM Scores;

SELECT s1.gender,s1.day,SUM(s2.score_points) AS total
FROM scores s1 JOIN scores s2
ON s1.gender=s2.gender AND s1.day>=s2.day
GROUP BY s1.gender,s1.day
ORDER BY gender,day;



-- 1322 Write an SQL query to find the ctr of each Ad.
-- Round ctr to 2 decimal points. 
-- Order the result table by ctr in descending order and by ad_id in ascending order in case of a tie.

CREATE TABLE Ads(ad_id int,user_id int,action enum('Clicked', 'Viewed', 'Ignored'));
INSERT INTO Ads VALUES (1,1,'Clicked'),
(2,2,'Clicked'),
(3,3,'viewed'),
(5,5,'Ignored'),
(1,7,'Ignored'),
(2,7,'viewed'),
(3,5,'Clicked'),
(1,4,'viewed'),
(2,11,'viewed'),
(1,2,'Clicked');

WITH cte1 AS (
    SELECT
        ad_id,
        SUM(IF(action = 'clicked', 1, 0)) AS clicks_cnt,
        SUM(IF(action = 'viewed', 1, 0)) AS views_cnt,
        SUM(IF(action = 'ignored', 1, 0)) AS ignore_cnt
    FROM
        Ads
    GROUP BY
        ad_id
)
SELECT
    ad_id,
    COALESCE(ROUND((clicks_cnt / (clicks_cnt + views_cnt)) * 100, 2), 0.00) AS ctr
FROM
    cte1
GROUP BY
    ad_id
ORDER BY
    ctr DESC,
    ad_id ASC;






