/*
	LinkedIn Learning 
	Note after class
	Advanced SQL for Data Scientists
	Use PostgreSQL
*/

 
SELECT * FROM company_divisions
SELECT * FROM company_regions
SELECT * FROM staff

/* count, min and max */

SELECT * FROM staff LIMIT 10
-- count how many employees
SELECT COUNT(*) FROM staff 
SELECT gender, COUNT(*) FROM staff GROUP BY gender
SELECT department, COUNT(*) FROM staff GROUP BY department

-- what is the salary of the highest paid employee?
SELECT max(salary) FROM staff 
-- what is the minimum salary that any employee is paid?
SELECT min(salary) FROM staff 
-- show both max and min
SELECT min(salary), max(salary) FROM staff 
-- Max and min salary in each department or between gender
SELECT department,min(salary), max(salary) FROM staff GROUP BY department
SELECT gender,min(salary), max(salary) FROM staff GROUP BY gender

/* statistics */

-- How much does the company pay in salary to all of its staff, across a given year?
SELECT SUM(salary) FROM staff 
-- total salary and average salary in each department
SELECT department,SUM(salary),avg(salary) FROM staff GROUP BY department
-- check sum, avg, variance, SD, 
SELECT department,SUM(salary),avg(salary),var_pop(salary),stddev_pop(salary) FROM staff GROUP BY department
-- Keep just two decimal points 
SELECT department,SUM(salary),round(avg(salary),2),round(var_pop(salary),2),round(stddev_pop(salary),2)
	FROM staff GROUP BY department

/* filter group */

-- list salary greater than 100,000
SELECT last_name, department, salary FROM staff where salary > 100000
-- list all employee from tools department
SELECT last_name, department, salary FROM staff where department = 'Tools'
-- two conditions (salary>100000 and in tools department)
SELECT last_name, department, salary FROM staff where department = 'Tools' AND salary > 100000
-- reach one of two conditions (salary>100000 or in tools department)
SELECT last_name, department, salary FROM staff where department = 'Tools' OR salary > 100000
SELECT department,sum(salary) FROM staff where department LIKE 'Bo%' GROUP BY department
SELECT department,sum(salary) FROM staff where department LIKE 'B%y' GROUP BY department

/* reformat */

SELECT DISTINCT UPPER(department) FROM staff
SELECT DISTINCT LOWER(department) FROM staff
SELECT job_title || '-' || department title_dept FROM staff
SELECT length('  Software Engineer  ') # result=21
SELECT length(trim('  Software Engineer  ')) #result=17
SELECT job_title FROM staff WHERE job_title like 'Assistant%'
SELECT job_title, (job_title like '%Assistant%') is_asst FROM staff

/* extra_string */
/* about OVERLAY and SUBSTRING */

SELECT 'abcdefghijkl' test_string
SELECT SUBSTRING('abcdefghijkl' FROM 1 FOR 3) test_string --result:abc
SELECT SUBSTRING('abcdefghijkl' FROM 5) test_string --result:efghijkl
SELECT SUBSTRING(job_title FROM 10) FROM staff WHERE job_title LIKE 'Assistant%'
-- Change Assistant to Asst.
SELECT OVERLAY(job_title PLACING 'Asst.' FROM 1 FOR 9) FROM staff WHERE job_title LIKE 'Assistant%'

/* regular_expression */
/* SIMILAR */

SELECT job_title FROM staff WHERE job_title SIMILAR TO '%Assistant%(III|IV)'
-- list all Assistant with level II and IV (=I_)
SELECT job_title FROM staff WHERE job_title SIMILAR TO '%Assistant I_'
-- list all job title has E, S or P for first letter EX: sales, programmer, engineer...
SELECT job_title FROM staff WHERE job_title SIMILAR TO '[EPS]%'

/* reformat_number */
/* 
ROUND, CEIL, and TRUNC
round: with numbers can be round to the specified number of decimal places(加上數字可以取到指定的小數點位數)
ceil:  unconditional carry(無條件進位)
trunc: unconditional returns truncated to specified decimal places (無條件捨去,可指定小數點位數)
*/

-- round and always return the next larger integer (ceil)
SELECT department, avg(salary), ceil(avg(salary)) FROM staff GROUP BY department
SELECT department, avg(salary), round(avg(salary),2), trunc(avg(salary),2) FROM staff GROUP BY department

/* subqueries */

SELECT s1.last_name, s1.salary, s1.department, 
	(SELECT round(avg(salary))FROM staff s2 WHERE s2.department = s1.department)
	FROM staff s1

SELECT s1.department, round(avg(s1.salary)) 
	FROM (SELECT department, salary FROM staff WHERE salary > 100000) s1
	GROUP BY s1.department

SELECT s1.department, s1.last_name, s1.salary 
	From staff s1
	WHERE s1.salary = (SELECT max(s2.salary) FROM staff s2)

/* join */

SELECT s.last_name, s.department, cd.company_division FROM staff s
	JOIN company_divisions cd ON s.department = cd.department
SELECT s.last_name, s.department, cd.company_division FROM staff s
	LEFT JOIN company_divisions cd ON s.department = cd.department
	WHERE cd.company_division IS NULL

/* grouping */

--Create a view
CREATE VIEW staff_div_reg AS
SELECT s.* ,cd.company_division, cr.company_regions FROM staff s
	LEFT JOIN company_divisions cd ON s.department = cd.department
	LEFT JOIN company_regions cr ON s.region_id = cr.region_id
	
SELECT count(*) FROM staff_div_reg --result:1000

SELECT company_regions, count(*) 
	FROM staff_div_reg
	GROUP BY company_regions
	ORDER BY company_regions

SELECT company_division, company_regions, count(*) 
	FROM staff_div_reg
	GROUP BY GROUPING SETS (company_division, company_regions)
	ORDER BY company_regions, company_division

SELECT company_division, company_regions, gender, count(*) 
	FROM staff_div_reg
	GROUP BY GROUPING SETS (company_division, company_regions,gender)
	ORDER BY company_regions, company_division,gender


/* rollup cube (in group by) */

--Create a view
CREATE OR REPLACE VIEW staff_div_reg_country AS
	SELECT s.*, cd.company_division, cr.company_regions, cr.country
	FROM staff s
	LEFT JOIN company_divisions cd ON s.department = cd.department
	LEFT JOIN company_regions cr ON s.region_id = cr.region_id

SELECT company_regions, country, count(*)
	FROM staff_div_reg_country
	GROUP BY company_regions, country
	ORDER BY country, company_regions
 
SELECT company_regions, country, count(*)
	FROM staff_div_reg_country
	GROUP BY ROLLUP(company_regions, country)
	ORDER BY country, company_regions
 
SELECT company_division, company_regions, count(*)
	FROM staff_div_reg_country
	GROUP BY CUBE(company_division, company_regions)
 
/* fetch first */

SELECT last_name, job_title, salary FROM staff ORDER BY salary DESC
	FETCH FIRST 10 ROW ONLY

/*  An important point to remember is that fetch first 
	works with the order by clause to sort the result
	before selecting the rows to return. This is different from
	the way the limit clause works. Limit actually limits 
	the number of rows and then perform the operations. */
	
SELECT company_division, count(*)
	FROM staff_div_reg_country
	GROUP BY company_division
	ORDER BY COUNT(*) DESC
	
--Add fetch first
SELECT company_division, count(*)
	FROM staff_div_reg_country
	GROUP BY company_division
	ORDER BY COUNT(*) DESC
	FETCH FIRST 5 ROWS ONLY
	 
/* window */

-- average salary in that department
SELECT department, last_name, salary, avg(salary) OVER(PARTITION BY department) FROM staff
-- the maximum salary in that department
SELECT department, last_name, salary, max(salary) OVER(PARTITION BY department) FROM staff

SELECT company_regions, last_name, salary,
	min(salary) OVER (PARTITION BY company_regions) 
	FROM staff_div_reg

SELECT department, last_name, salary, first_value(salary) OVER (PARTITION BY department ORDER BY salary DESC)
	FROM staff
/* 
Here, first value returns the same ordering as if we had used the max function.
What's different about first value is that we can change the order by clause.
*/

SELECT department, last_name, salary, first_value(salary) OVER (PARTITION BY department ORDER BY last_name)
	FROM staff

--Rank function
SELECT department, last_name, salary, rank() OVER (PARTITION BY department ORDER BY salary DESC)
	FROM staff



/* lag, lead and NTile */

-- use the lag function to reference rows relative to the currently processed rows 
SELECT department, last_name, salary, lag(salary) OVER (PARTITION BY department ORDER BY salary DESC)
	FROM staff
	
-- lead is essentially the opposite of lag. Because it refers to the column that comes after the currently processed column 
SELECT department, last_name, salary, lead(salary) OVER (PARTITION BY department ORDER BY salary DESC)
	FROM staff

-- ntile  is the window function we use when we want to group rows into some number of buckets or ordered group 
SELECT department, last_name, salary, ntile(4) OVER (PARTITION BY department ORDER BY salary DESC)
	FROM staff














