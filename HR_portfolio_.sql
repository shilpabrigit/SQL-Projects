-- One of the major challenges faced by companies around the world is attrition. 
-- It is known that employee attrition lead to high costs on business
-- To study this problem further, we study a dataset which details a number of criteria and facts pertaining to the employee.
-- We study the attrition data of the past years to come up with valuable insights to explain the major factors that lead to attrition.

--IMPORT THE DATA 
--   CREATE A NEW DATABASE CALLED HR
--     ADD THE TABLE 

-- CREATE TWO TABLES FOR NO-ATTRITION AND YES-ATTRITION
use HR
SELECT * INTO yes_att
FROM HR
WHERE Attrition='Yes'

use HR
SELECT * INTO no_att
FROM HR
WHERE Attrition='NO'

--1. What is the overall attrition rate? How does attrition vary with department?

SELECT 
    CONCAT((COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) *1.0/ COUNT(*))*100,'%') AS OverallAttritionRate
FROM 
    HR


SELECT Department,COUNT(Attrition) AS count_of_attrition_by_dept,COUNT(Attrition) * 1.0 / (SELECT COUNT(*) FROM yes_att) *100 AS percentage_of_attritions_by_dept
FROM yes_att
GROUP BY Department


--2. Are there any specific job roles that are prone to higher attrition ?  Is there any correlation for the field of study, job role and attrition.

SELECT A.EducationField,A.Department,A.JobRole,ROUND(CAST(TotalCount AS FLOAT)/Total_AttritionCount*100,2) AS Percentage_of_attrition
FROM(
SELECT Attrition,EducationField,JobRole,Department,COUNT(*) AS TotalCount
FROM yes_att
GROUP BY 
    EducationField, Department,Attrition,JobRole) AS A
LEFT OUTER JOIN
(SELECT DISTINCT Attrition, Count(*) AS Total_AttritionCount
FROM HR
GROUP BY Attrition) AS B
ON A.Attrition=B.Attrition
ORDER BY A.Attrition,Percentage_of_attrition DESC

--3. What is the average monthly income of each department?

SELECT A.Department,A.monthlyincome_attrition,B.monthlyincome_no_attrition --creating an inner join of the two above tables
FROM (SELECT Department, AVG(MonthlyIncome) AS monthlyincome_attrition
FROM HR WHERE Attrition='Yes' GROUP BY Department) AS A 
INNER JOIN 
(SELECT Department,AVG(MonthlyIncome) AS monthlyincome_no_attrition 
FROM HR WHERE Attrition='NO' GROUP BY Department) AS B 
ON A.Department=B.Department

-- It is seen that there is a vast difference between the monthly income for cases with and without attrition.

--4. How do you explain this gap in monthly income between the attritted and non attritted?

SELECT Department, AVG(CAST(YearsAtCompany AS INT)) AS avg_years_at_company_attrited,(SELECT(AVG(CAST(YearsAtCompany AS INT))) FROM HR WHERE Attrition='No') AS avg_years_at_company_nonattrited
FROM yes_att
GROUP BY Department

--5. Does percentage hike in salary impacted attrition?

SELECT A.Department,A.avg_salary_hike_for_attrition,B.avg_salary_hike_for_noattrition
FROM (SELECT Department, AVG(PercentSalaryHike) AS avg_salary_hike_for_attrition 
FROM HR WHERE Attrition='Yes' GROUP BY Department) AS A 
INNER JOIN
(SELECT Department, AVG(PercentSalaryHike) AS Avg_salary_hike_for_noattrition 
FROM HR WHERE Attrition='NO' GROUP BY Department) AS B
ON A.Department=B.Department

--6. What is average age of the employee who leaves the company?  

SELECT JobRole,Department,AVG(Age) AS avg_age,COUNT(*) AS count_of_employees
FROM HR
WHERE Attrition='Yes'
GROUP BY Department,JobRole
ORDER BY avg_age


--WORK ENVIRONMENT FACTORS

--7. What can you say about work environment and attrition?

SELECT Attrition,EnvironmentSatisfaction, Count(EnvironmentSatisfaction) AS Votes
FROM yes_att
GROUP BY Attrition,EnvironmentSatisfaction
ORDER BY EnvironmentSatisfaction
--We can see the those who attrited had a very low environment satisfaction

--8. How does the environment satisfaction among the attritted by department look like?

SELECT A.Department,A.EnvironmentSatisfaction,A.Votes,B.total_per_dept, ROUND(CAST(A.Votes AS FLOAT)/B.total_per_dept*100,2) AS percentage_of_votes
FROM (SELECT Department,EnvironmentSatisfaction, Count(EnvironmentSatisfaction) AS Votes
FROM HR
WHERE Attrition='Yes'
GROUP BY EnvironmentSatisfaction,Department) AS A
LEFT OUTER JOIN
(SELECT Department,COUNT(*) AS total_per_dept 
FROM HR
WHERE Attrition='Yes'
GROUP BY Department) AS B
ON A.Department=B.Department

--9. Is there any correlation between attritions and overtime?

CREATE TABLE t1
(
    Department NVARCHAR(255),  
    percentage_of_ovetime_att FLOAT  
);


INSERT INTO t1
SELECT A.Department,ROUND(CAST (A.count_of_overtime_bydept AS FLOAT)/B.total_per_dept*100,2) AS percentage_of_ovetime_att
FROM (SELECT Department,COUNT(OverTime) AS count_of_overtime_bydept
FROM HR
WHERE Attrition='YES' AND OverTime LIKE 'Yes'
GROUP BY Department) AS A
INNER JOIN
(SELECT Department,COUNT(*) AS total_per_dept 
FROM HR
WHERE Attrition='Yes'
GROUP BY Department) AS B
ON A.Department=B.Department


CREATE TABLE t2 
(
    Department NVARCHAR(255),  
    percentage_of_ovetime_no_attrition FLOAT  

)
INSERT INTO t2
SELECT A.Department,ROUND(CAST (A.count_of_overtime_bydept AS FLOAT)/B.total_per_dept*100,2) AS percentage_of_ovetime_by_dept_no_attrition
FROM (SELECT Department,COUNT(OverTime) AS count_of_overtime_bydept
FROM HR
WHERE Attrition='No' AND OverTime LIKE 'Yes'
GROUP BY Department) AS A
INNER JOIN
(SELECT Department,COUNT(*) AS total_per_dept 
FROM HR
WHERE Attrition='No'
GROUP BY Department) AS B
ON A.Department=B.Department

SELECT *
FROM t1
SELECT A.Department,A.percentage_of_ovetime_att AS per_overtime_att,B.percentage_of_ovetime_no_attrition AS per_overtime_no_att
FROM t1 AS A INNER JOIN t2 AS B
ON A.Department=B.Department
