--Cheking the imported data
SELECT *
FROM [Portfolio-Project]..[covid-deaths] 
WHERE continent IS NOT null
ORDER BY 3,4


SELECT location,date,total_cases,new_cases,total_deaths,population
from [Portfolio-Project]..[covid-deaths] 
ORDER BY 3,4

-- Total cases vs Total Deaths 
-- Likelihhod of dyning if you get covid in India 
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From [Portfolio-Project]..[covid-deaths] 
WHERE location = 'India'
ORDER BY 3,4

--Looking at Total cases vs Population
--percentage of population with covid
SELECT location,date,population,total_cases, (total_cases/population)*100 AS case_percentage
From [Portfolio-Project]..[covid-deaths] 
WHERE location = 'India'
ORDER BY 3,4

--Higest Infection rate
SELECT location,population,MAX(total_cases) AS Highestinfection, MAX((total_cases/population)*100) AS max_case_percentage
From [Portfolio-Project]..[covid-deaths] 
GROUP BY location,population
ORDER BY max_case_percentage desc

--Higest death count per population over country
SELECT location,MAX(total_deaths) AS Total_death_count
From [Portfolio-Project]..[covid-deaths] 
WHERE continent IS NOT null
GROUP BY location
ORDER BY Total_death_count DESC

--Higest death count per population over contitnet 
SELECT location,MAX(total_deaths) AS Total_death_count
From [Portfolio-Project]..[covid-deaths] 
WHERE continent is null
GROUP BY location
ORDER BY Total_death_count DESC


-- Global Numbers

SELECT date,SUM(new_cases) AS total_cases,sum(new_deaths) AS total_deaths, sum(new_deaths)/SUM(new_cases)*100 AS death_percentage_world
From [Portfolio-Project]..[covid-deaths] 
where continent IS not NULL
GROUP BY date
ORDER BY 3,4


-- Total pouplation vs vacination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.[date]) AS Rolling_vacinated

FROM [Portfolio-Project]..[covid-deaths] dea
JOIN  [Portfolio-Project]..[covid-vacination] vac
ON dea.location=vac.location AND dea.date=vac.date 
where dea.continent IS not NULL
ORDER BY 2,3

--Using cte to find portion of people vacinated
WITH pop_v_vac (continet,location,date,population,new_vaccinations,Rolling_vacinated)
AS (
  SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.[date]) AS Rolling_vacinated

FROM [Portfolio-Project]..[covid-deaths] dea
JOIN  [Portfolio-Project]..[covid-vacination] vac
ON dea.location=vac.location AND dea.date=vac.date 
where dea.continent IS not NULL
)
SELECT *,pvv.Rolling_vacinated/pvv.population AS proportion_vacinated FROM
pop_v_vac pvv

--Using temp table portion of tested
DROP TABLE IF EXISTS #percent_poulation_tested
CREATE TABLE #percent_poulation_tested
(
continet nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_tests numeric,
Rolling_tested numeric
)
INSERT INTO #percent_poulation_tested
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_tests
, Sum(Cast(vac.new_tests AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.[date]) AS Rolling_tested

FROM [Portfolio-Project]..[covid-deaths] dea
JOIN  [Portfolio-Project]..[covid-vacination] vac
ON dea.location=vac.location AND dea.date=vac.date 
where dea.continent IS not NULL

SELECT *,pvv.Rolling_tested/pvv.population AS proportion_tested FROM
#percent_poulation_tested pvv


--Creating view for later visualisation
CREATE View percent_poulation_vacinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations AS int)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.[date]) AS Rolling_vacinated

FROM [Portfolio-Project]..[covid-deaths] dea
JOIN  [Portfolio-Project]..[covid-vacination] vac
ON dea.location=vac.location AND dea.date=vac.date 
where dea.continent IS not NULL

SELECT * from
percent_poulation_vacinated