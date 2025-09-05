-- Question 1: Write a query to calculate the bounce rate for a website using session and page view data.
-- Table: sessions
CREATE TABLE sessions (
    session_id VARCHAR(50) PRIMARY KEY,
    start_time TIMESTAMP,
    user_id VARCHAR(50)
);

-- Table: page_views
CREATE TABLE page_views (
    page_view_id VARCHAR(50) PRIMARY KEY,
    session_id VARCHAR(50),
    page_url VARCHAR(255),
    view_time TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);


INSERT INTO sessions (session_id, start_time, user_id) VALUES
('S001', '2025-06-19 10:00:00', 'U101'),
('S002', '2025-06-19 10:05:00', 'U102'),
('S003', '2025-06-19 10:10:00', 'U101'),
('S004', '2025-06-19 10:15:00', 'U103'),
('S005', '2025-06-19 10:20:00', 'U102');
SELECT * FROM sessions;

INSERT INTO page_views (page_view_id, session_id, page_url, view_time) VALUES
('PV001', 'S001', '/home', '2025-06-19 10:00:15'),
('PV002', 'S001', '/product', '2025-06-19 10:01:00'),
('PV003', 'S002', '/about', '2025-06-19 10:05:30'),
('PV004', 'S003', '/contact', '2025-06-19 10:10:20'),
('PV005', 'S003', '/faq', '2025-06-19 10:11:00'),
('PV006', 'S003', '/privacy', '2025-06-19 10:11:45'),
('PV007', 'S004', '/index', '2025-06-19 10:15:40'),
('PV008', 'S005', '/services', '2025-06-19 10:20:10'),
('PV009', 'S005', '/pricing', '2025-06-19 10:21:00');
SELECT * FROM page_views;


SELECT ROUND(COUNT(CASE WHEN page_view_count=1 THEN session_id ELSE NULL END)*1.0/(COUNT(DISTINCT session_id)),2) AS bounce_rate
FROM (
SELECT session_id,COUNT(DISTINCT page_view_id) AS page_view_count
FROM page_views
GROUP BY session_id
)AS spc;


-- 2:From a user_activity table, find the number of users who were active on at least 15 days in a given month.
-- Table: user_activity
CREATE TABLE user_activity (
    activity_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    activity_date DATE,
    activity_type VARCHAR(100)
);

-- Table: search_logs
CREATE TABLE search_logs (
    log_id INT PRIMARY KEY,
    query VARCHAR(255),
    timestamp TIMESTAMP,
    user_id VARCHAR(50)
);

INSERT INTO user_activity (activity_id, user_id, activity_date, activity_type) VALUES
('1', 'U101', '2025-05-01', 'login'),
('2', 'U101', '2025-05-01', 'view_product'),
('3', 'U102', '2025-05-01', 'login'),
('4', 'U101', '2025-05-02', 'add_to_cart'),
('5', 'U103', '2025-05-03', 'login'),
('6', 'U101', '2025-05-10', 'purchase'),
('7', 'U101', '2025-05-15', 'login'),
('8', 'U101', '2025-05-16', 'logout'),
('9', 'U101', '2025-05-17', 'Login'),
('10', 'U101', '2025-05-18', 'view_product'),
('11', 'U101', '2025-05-19', 'add to cart'),
('12', 'U101', '2025-05-20', 'purchase'),
('13', 'U101', '2025-05-21', 'login'),
('14', 'U101', '2025-05-22', 'logout'),
('15', 'U101', '2025-05-23', 'login'),
('16', 'U101', '2025-05-24', 'view_product'),
('17', 'U101', '2025-05-25', 'add_to_cart'),
('18', 'U101', '2025-05-26', 'purchase'),
('19', 'U101', '2025-05-27', 'login'),
('20', 'U101', '2025-05-28', 'logout'),
('21', 'U102', '2025-05-05', 'login'),
('22', 'U102', '2025-05-10', 'view_product'),
('23', 'U102', '2025-05-12', 'purchase'),
('24', 'U102', '2025-05-14', 'login'),
('25', 'U103', '2025-05-05', 'login'),
('26', 'U103', '2025-05-10', 'view_product'),
('27', 'U103', '2025-05-12', 'purchase');
SELECT * FROM user_activity;

SELECT COUNT(user_id) AS no_of_active_users
FROM (
SELECT user_id
FROM user_activity
GROUP BY user_id
HAVING COUNT(DISTINCT activity_date)>=15);

INSERT INTO search_logs (log_id, query, timestamp, user_id) VALUES
(1, '"data analyst"', '2025-06-03 10:00:00', 'U101'),
(2, '"SQL basics"', '2025-06-03 11:00:00', 'U102'),
(3, '"data analyst"', '2025-06-04 09:30:00', 'U103'),
(4, '"Python"', '2025-06-05 14:00:00', 'U101'),
(5, '"data analyst"', '2025-06-05 16:00:00', 'U102'),
(6, '"SQL basics"', '2025-06-06 10:00:00', 'U101'),
(7, '"Python"', '2025-06-06 11:00:00', 'U103'),
(8, '"machine learning"', '2025-06-07 10:00:00', 'U101'),
(9, '"data analyst"', '2025-06-10 09:00:00', 'U102'),
(10, '"SQL advanced"', '2025-06-10 10:00:00', 'U101'),
(11, '"SQL advanced"', '2025-06-11 11:00:00', 'U103'),
(12, '"Python"', '2025-06-11 12:00:00', 'U102'),
(13, '"data analyst"', '2025-06-12 13:00:00', 'U101'),
(14, '"machine learning"', '2025-06-13 14:00:00', 'U103'),
(15, '"Python"', '2025-06-13 15:00:00', 'U101'),
(16, '"data visualization"', '2025-06-14 16:00:00', 'U102');
SELECT * FROM search_logs;

--3:You have a search_logs table with query, timestamp, and user_id. Find the top 3 most frequent search queries per week.
SELECT
    week_start_date,
    query,
    query_count
FROM (
   SELECT
        TO_CHAR(timestamp, 'YYYY-WW') AS week_identifier,
        DATE_TRUNC('week', timestamp) AS week_start_date,
        query,
        COUNT(query) AS query_count,
        ROW_NUMBER() OVER (
            PARTITION BY TO_CHAR(timestamp, 'YYYY-WW') -- Partition by week
            ORDER BY COUNT(query) DESC, query ASC -- Order by frequency (desc) then query name (asc) for ties
        ) AS rn
    FROM
        search_logs
    GROUP BY
        TO_CHAR(timestamp, 'YYYY-WW'), -- Group by week identifier
        DATE_TRUNC('week', timestamp), -- Also group by week start date to ensure consistency
        query -- Group by query to count occurrences
) AS weekly_query_counts
WHERE
    rn <= 3 -- Filter for the top 3 ranked queries
ORDER BY
    week_start_date,
    query_count DESC;




