CREATE DATABASE mydb;
USE mydb;

CREATE TABLE project(project_id int,employee_id int,FOREIGN KEY(employee_id) REFERENCES employee(employee_id));
INSERT INTO project VALUES(1,1),
(1,2),
(1,3),
(2,1),
(2,4);

CREATE TABLE employee(employee_id int PRIMARY KEY,name varchar(20),experience int);
INSERT INTO  employee VALUES(1,'Khaled',3),
(2 ,'Ali',2),
(3 ,'John',1),
(4,'Doe',2);
SELECT * FROM employee;
UPDATE employee
SET experience=3 WHERE experience=1;


-- 1069 Write an SQL query that reports the total quantity sold for every product id.
SELECT product_id,SUM(quantity)
FROM Sales
GROUP BY product_id

-- 1076 Write an SQL query that reports all the projects that have the most employees.
SELECT project_id
FROM project
GROUP BY project_id
HAVING COUNT(employee_id)>=(SELECT COUNT(employee_id) AS cnt
                 FROM project 
                 GROUP BY project_id
                 ORDER BY cnt DESC
                 LIMIT 1);
                 
-- 1077 Write an SQL query that reports the most experienced employees in each project. 
-- In case of a tie, report all employees with the maximum number of experience years.
WITH x AS (
   SELECT p.employee_id,p.project_id,e.experience, RANK() OVER(PARTITION BY p.project_id ORDER BY e.experience DESC) AS rnk
   FROM project p JOIN employee e 
   ON p.employee_id=e.employee_id
   )
SELECT project_id,employee_id
FROM x
WHERE rnk=1;

CREATE TABLE product(product_id int PRIMARY KEY,product_name varchar(20),unit_price int);
INSERT INTO product VALUES(1,'S8',1000),
(2,'G4',800),
(3,'iPhone',1400);
SELECT * FROM product;

CREATE TABLE sales(seller_id int,product_id int, buyer_id int,sale_date date,quantity int,price int,FOREIGN KEY(product_id) REFERENCES product(product_id));
INSERT INTO sales VALUES(1,1,1,'2019-01-21',2,2000),
(1,2,2,'2019-02-17',1,800),
(2,2,3,'2019-06-02', 1,800),
(3,3,4 ,'2019-05-13', 2,2800);
SELECT * FROM sales;

UPDATE sales
SET buyer_id=3 WHERE buyer_id=4;

UPDATE sales
SET product_id=1 WHERE seller_id=2;

-- 1082 Write an SQL query that reports the best seller by total sales price, If there is a tie, report them all.
WITH x as(
        SELECT seller_id,SUM(price) AS sum
		FROM sales
        GROUP BY seller_id),
y as(
      SELECT seller_id,sum,RANK() OVER(ORDER BY sum DESC) AS rnk
      FROM x
      )
      
SELECT seller_id
FROM y
WHERE rnk=1;
        
-- 1083 Write an SQL query that reports the buyers who have bought S8 but not iPhone. 
-- Note that S8 and iPhone are products present in the Product table.
SELECT s.buyer_id
FROM product p JOIN sales s
ON p.product_id=s.product_id
GROUP BY s.buyer_id
HAVING SUM(s.product_id=1)>0 AND SUM(s.product_id=3)=0;

CREATE TABLE Enrollments (student_id int,course_id int,grade int);
INSERT INTO Enrollments VALUES(2,2,95),
(2,3,95),
(1,1,90),
(1,2,99),
(3,1,80),
(3,2,75),
(3,3,82);




-- 1112 Write a SQL query to find the highest grade with its corresponding course for each student.
-- In case of a tie, you should find the course with the smallest course_id.
-- The output must be sorted by increasing student_id.
SELECT student_id,course_id,grade
FROM (
       SELECT student_id,course_id,grade,ROW_NUMBER() OVER(PARTITION BY student_id ORDER BY grade DESC,course_id ASC) AS rn
       FROM Enrollments
       ) AS x
WHERE x.rn=1
ORDER BY student_id ASC;


CREATE TABLE Actions (user_id int,post_id int,action_date date, action enum('view', 'like', 'reaction', 'comment', 'report', 'share'), extra varchar(20));
INSERT INTO Actions VALUES(1,1,'2019-07-01','view',null),
(1,1,'2019-07-01','like',null),
(1,1,'2019-07-01','share',null),
(2,4,'2019-07-04','view',null),
(2,4,'2019-07-04','report','spam'),
(3,4,'2019-07-04','view',null),
(3,4,'2019-07-04','report','spam'),
(4,3,'2019-07-02','view',null),
(4,3,'2019-07-02','report','spam'),
(5,2,'2019-07-04','view',null),
(5,2,'2019-07-04','report','racism'),
(5,5,'2019-07-04','view',null),
(5,5,'2019-07-04','report','racism');
SELECT * FROM Actions;


-- 1113 Write an SQL query that reports the number of posts reported yesterday for each report reason. 
-- Assume today is 2019-07-05.
SELECT extra AS report_reason,no_of_reports
FROM (
      SELECT extra,COUNT(extra) AS no_of_reports
      FROM Actions
      WHERE action='report' AND action_date='2019-07-04'
      GROUP BY extra) AS t
GROUP BY t.extra;

CREATE TABLE Events(business_id int,event_type varchar(20), occurences int);
INSERT INTO Events VALUES(1,'reviews',7),
(3,'reviews',3),
(1,'ads',11),
(2,'ads',7),
(3,'ads',6),
(1,'page views',3),
(2,'page views',12);
SELECT * FROM events;
-- 1126 Write an SQL query to find all active businesses.
-- An active business is a business that has more than one event type with occurences greater than the average occurences of that event type among all businesses.
SELECT business_id
FROM Events e,(
      SELECT event_type,ROUND(AVG(occurences),2) AS avg_occurences
      FROM Events
      GROUP BY event_type) AS a
WHERE e.event_type=a.event_type AND e.occurences>a.avg_occurences
GROUP BY e.business_id
HAVING COUNT(*)>1;





