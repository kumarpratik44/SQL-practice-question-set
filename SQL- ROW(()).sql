select * from employees_large_dataset;
-- Retrieve the top 3 highest-paid employees in each department using RANK().

WITH RankedEmployees AS (select emp_name, dept_name, salary,
RANK() OVER (partition by dept_name  order by salary desc) as Highest_salary
from employees_large_dataset)

SELECT *
FROM RankedEmployees
WHERE Highest_salary <= 3
ORDER BY dept_name, Highest_salary;

-- Assign a row number to employees in each department ordered by hire_date.
select emp_name, dept_name, hire_date,
row_number () over (partition by dept_name order by hire_date) as Joining_position 
from employees_large_dataset
ORDER BY dept_name, Joining_position;

-- For each employee, show their salary and the previous employee’s salary using LAG().

select emp_id, emp_name, salary, 
lag(salary,1,0) over (order by hire_date) as previous_employee’s_salary,
salary- lag(salary,1,0) over (order by hire_date) as salary_diff
from employees_large_dataset ;

-- For each employee, calculate the difference between their salary and 
-- the next employee’s salary in the same department using LEAD().

select emp_name, salary, dept_name,
lead(salary,1) over (partition by dept_name order by salary) as next_emp_salary,
salary - lead(salary,1) over (partition by dept_name order by salary) as salary_diff
from employees_large_dataset
order by dept_name, salary;

-- List employees whose salary is above the average salary of their department.

select emp_name, salary 
from employees_large_dataset as e
where salary > (select round(avg(salary),2) as avg_salary
from  employees_large_dataset
where dept_name = e.dept_name ) ;

-- Find the department that has the maximum number of employees.
select count(emp_id) as emp_num, dept_name
from employees_large_dataset
group by dept_name
order by emp_num desc
limit 1 offset 0;

-- Using a CTE, calculate the total salary by department and return only those departments 
-- where total salary > 2,000,000.

select dept_name, sum(salary) as total_salary 
from employees_large_dataset  
group by dept_name
having total_salary > 2000000
order by total_salary;

-- Find employees who earn more than the average salary of all employees.
select emp_name, salary
from employees_large_dataset as e 
where  salary > (select round(avg(salary),2) as avg_salary 
from employees_large_dataset  
where dept_name = e.dept_name);

-- Create a column salary_level with values: "High" if salary > 80,000 "Medium" if salary between 50,000 
-- and 80,000 "Low" otherwise.
select emp_name, salary, dept_name,
CASE 
when salary > 80000 then "High"
when salary between 50000 and 80000 then "Medium"
else "Low"
end as salary_levels
from employees_large_dataset ;

-- Find employees hired in the last 5 years

SELECT emp_name, hire_date
FROM employees_large_dataset 
WHERE hire_date > DATE_SUB(CURDATE(), INTERVAL 5 YEAR);

-- Calculate the average salary of employees hired each year.

select emp_name, round(avg(salary),2) as avg_salary, hire_date
from  employees_large_dataset
group by emp_name, hire_date;

-- Find employees whose bonus month (from hire_date or provided bonus column) is in December.
SELECT emp_name, bonus, hire_date
FROM employees_large_dataset
WHERE MONTH(hire_date) = 12;

-- Find the most recently hired employee in each department.

with ranked_one_emp as (select emp_name, dept_name, hire_date,
rank() over (partition by dept_name order by hire_date desc  ) as most_recent_emp
from  employees_large_dataset
order by hire_date)

select emp_name, dept_name, hire_date
from   ranked_one_emp 
where most_recent_emp =1;


-- Find the number of employees hired per quarter in the last 10 years.

select count(emp_name), YEAR(hire_date) AS hire_year,
    QUARTER(hire_date) AS hire_quarter
from employees_large_dataset
where hire_date >  DATE_SUB(CURDATE(), INTERVAL 10 YEAR)
group by  YEAR(hire_date), QUARTER(hire_date)
order by hire_year, hire_quarter;