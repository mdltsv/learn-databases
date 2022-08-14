-- https://thinketl.com/sql-analytic-functions-interview-questions/
-- 1
-- Average Salary of all employees Department wise
SELECT ROUND(AVG(salary)), AVG(salary), department_id
FROM employees
GROUP BY department_id
ORDER BY department_id;

-- 2
-- Displaying average salary against each employee record
WITH avg_salary_cte AS
( SELECT AVG(salary) as avg_sal, department_id as dep_id
  FROM employees
  GROUP BY department_id
  )
SELECT
    emp.employee_id,
    emp.last_name,
    emp.salary,
    emp.department_id,
    a_s_c.avg_sal
FROM employees emp
LEFT JOIN avg_salary_cte a_s_c
ON emp.department_id = a_s_c.dep_id
ORDER BY department_id ASC;
/
SELECT
    B.Employee_Id,
    B.First_Name,
    B.Department_Id,
    B.Salary,
    A.AVG_SAL
FROM
(SELECT Department_Id, AVG(Salary) as AVG_SAL FROM Employees GROUP BY Department_Id) A,
EMPLOYEES B
WHERE A.Department_Id = B.Department_Id;
-- Это их подход, а дальше понять, как сделать то же через аналитические функции!
/
SELECT
    Employee_Id,
    Last_name,
    Salary,
    Department_Id,
    AVG(Salary) OVER (PARTITION BY department_id) as anal
FROM employees
ORDER BY department_id ASC;
/
-- Интересно сравнить мой подход с CTE и аналитический: AVG_SAL с аналитическим не NULL.

-- 3
-- Calculate total sum and cumulative sum of salary department wise
SELECT
    Employee_Id,
    Last_name,
    Salary,
    Department_Id,
    AVG(Salary) OVER (PARTITION BY department_id) as avg_sal,
    SUM(Salary) OVER (PARTITION BY department_id) as sum_sal,
    SUM(Salary) OVER (PARTITION BY department_id ORDER BY SALARY) as cum_sum_sal,
    SUM(Salary) OVER (PARTITION BY department_id ORDER BY employee_id) as cum_sum_sal2
FROM employees
ORDER BY department_id ASC;
/

-- 4
-- Calculate cumulative sum of the organization
SELECT
    Employee_Id,
    Last_name,
    Salary,
    Department_Id,
    SUM(Salary) OVER (PARTITION BY employee_id) as cum_sum_org,
    SUM(Salary) OVER (ORDER BY employee_id) as cum_sum_org2
FROM employees
ORDER BY EMPLOYEE_ID DESC;
/

-- 5
-- Calculate cumulative average, average of the organization
SELECT
  employee_id,
  last_name,
  department_id,
  salary,
  AVG(salary) OVER(PARTITION BY department_id ORDER BY EMPLOYEE_ID) AS cum_avg,
  AVG(salary) OVER(PARTITION BY department_id) AS ordinary_avg
FROM employees ORDER BY EMPLOYEE_ID;
/

-- 6
-- Calculate average of salary for current and previous record department wise








