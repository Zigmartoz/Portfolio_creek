/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  --WHERE continent is not NULL
  ORDER BY 3,4


--Global data on covid19 showing country and progressive death over time

SELECT 
	location country, continent,
	date,
	new_cases,
	total_cases,
	total_deaths,
	population
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE continent is not NULL
	ORDER BY location,date


--Total cases, total death and likelihood of dying fron covid19 in Nigeria during the pandemic
--Show the death percentage of covid19 in Nigeria

SELECT
	location country, continent,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 DEATHpercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
	WHERE total_cases is not null and location='Nigeria'
		AND continent is not NULL
ORDER BY location,date


--Data on covid19 cases with respect to the population of country
--Also shows the percentage of population with covid19 in Nigeria

SELECT
	location country, continent,
	date,
	population,
	total_cases,
	(total_cases/population)*100 Case_percentage --percentage of population with covid19 in Nigeria
FROM [PortfolioProject].[dbo].[CovidDeaths]
	WHERE total_cases is not null and location='Nigeria'
		AND continent is not NULL
ORDER BY location,date



--Summary on infection cases and death cases of covid19, showing the highest cases on both infection and death cases per country
--Also showing the percentage of infection and percentage of death per country

SELECT
	location country, continent,
	MAX(total_cases) Highest_cases,
	MAX(total_deaths) Highest_no_of_deaths,
	population,
	MAX((total_cases/population))*100 Case_percentage, --percentage of population with covid19 per country
	MAX((total_deaths/total_cases))*100 Deathpercentage --percentage of infected cases that died from covid19
FROM [PortfolioProject].[dbo].[CovidDeaths]
	WHERE total_cases is not null
		AND continent is not NULL
GROUP BY continent, location, population
ORDER BY Case_percentage DESC

--Showing covid19 death count per country in descending order
				SELECT
					location country, continent,
					MAX(CAST(total_deaths AS INT)) Highest_no_of_deaths,
					population,
					MAX((total_deaths/total_cases))*100 Deathpercentage --percentage of infected cases that died from covid19
				FROM [PortfolioProject].[dbo].[CovidDeaths]
					WHERE total_cases is not null
						AND continent is not NULL
				GROUP BY continent, location, population
				ORDER BY Highest_no_of_deaths DESC


--Showing data of different continent based on their covid death in descending order

SELECT
	location continent,
	MAX(CAST(total_deaths AS INT)) Highest_no_of_deaths,
	MAX(population) population,
	MAX((total_deaths/total_cases))*100 Deathpercentage --percentage of infected cases that died from covid19
FROM [PortfolioProject].[dbo].[CovidDeaths]
	WHERE total_cases is not null
		AND continent is NULL
		AND location <> 'world'
		and location <> 'international'
	GROUP BY location
	ORDER BY Highest_no_of_deaths DESC



--Showing global data on new cases and death for each day

SELECT 
	date,
	SUM(new_cases) global_case_per_day,
	SUM(CAST(new_deaths AS INT)) global_death_per_day,
	(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 global_deathpercentage_per_day
FROM [PortfolioProject].[dbo].[CovidDeaths]
	WHERE new_cases is not null
	AND continent is not null
GROUP BY date
ORDER BY 1


--Summary of Global data on covid19
SELECT 
	SUM(new_cases) global_case_per_day,
	SUM(CAST(new_deaths AS INT)) global_death_per_day,
	(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 global_deathpercentage_per_day
FROM [PortfolioProject].[dbo].[CovidDeaths]
	WHERE new_cases is not null
	AND continent is not null
ORDER BY 1


SELECT *
  FROM [PortfolioProject].[dbo].[vaccination]
  --ORDER BY 3,4


SELECT
	A.continent,
	A.location,
	A.date,
	SUM(CAST(B.new_vaccinations AS INT)) vaccination,
	A.population
FROM [PortfolioProject].[dbo].[CovidDeaths] A -- A represent CovidDeaths table
	  JOIN [PortfolioProject].[dbo].[vaccination] B -- B represents vaccination table
		ON A.location=B.location
			AND A.date=B.date
	WHERE A.continent is not null
		--AND new_vaccinations is not null
GROUP BY A.continent, A.date, A.location, A.population
	ORDER BY A.location, A.date


--Showing data for vaccinated population, grouped by location and date

SELECT
	A.continent,
	A.location,
	A.date,
	A.population,
	new_vaccinations,
	SUM(CONVERT(INT,B.new_vaccinations)) OVER (PARTITION BY A.location ORDER BY A.location, A.date) cummulative_vaccination
FROM [PortfolioProject].[dbo].[CovidDeaths] A -- A represent CovidDeaths table
	  JOIN [PortfolioProject].[dbo].[vaccination] B -- B represents vaccination table
		ON A.location=B.location
			AND A.date=B.date
	WHERE A.continent is not null
		--AND new_vaccinations is not null
GROUP BY A.continent, A.date, A.location, A.population, B.new_vaccinations
	ORDER BY A.location, A.date


--Using CTE to analyse percentage of vaccinated population

WITH Vac_pop --Vac_pop means vaccinated population
			(
			continent,
			location,
			date,
			population,
			new_vaccinations,
			cummulative_vaccination
			)
AS
	(
SELECT
	A.continent,
	A.location,
	A.date,
	A.population,
	new_vaccinations,
	SUM(CONVERT(INT,B.new_vaccinations)) OVER (PARTITION BY A.location ORDER BY A.location, A.date) cummulative_vaccination
FROM [PortfolioProject].[dbo].[CovidDeaths] A -- A represent CovidDeaths table
	  JOIN [PortfolioProject].[dbo].[vaccination] B -- B represents vaccination table
		ON A.location=B.location
			AND A.date=B.date
	WHERE A.continent is not null
		--AND new_vaccinations is not null
GROUP BY A.continent, A.date, A.location, A.population, B.new_vaccinations

	)

SELECT*, (cummulative_vaccination/population)*100 Percentage_vaccinated
FROM Vac_pop



--Using temp table to analyse percentage of vaccinated population

DROP TABLE IF EXISTS #Vac_pop --Vac_pop means vaccinated population
CREATE TABLE #Vac_pop
	(
	continent nvarchar(255),
	location nvarchar(255),
	date Datetime,
	population numeric,
	new_vaccinations numeric,
	cummulative_vaccination numeric
	)
INSERT INTO #Vac_pop
SELECT
	A.continent,
	A.location,
	A.date,
	A.population,
	new_vaccinations,
	SUM(CONVERT(INT,B.new_vaccinations)) OVER (PARTITION BY A.location ORDER BY A.location, A.date) cummulative_vaccination
FROM [PortfolioProject].[dbo].[CovidDeaths] A -- A represent CovidDeaths table
	  JOIN [PortfolioProject].[dbo].[vaccination] B -- B represents vaccination table
		ON A.location=B.location
			AND A.date=B.date
	WHERE A.continent is not null
		AND new_vaccinations is not null
GROUP BY A.continent, A.date, A.location, A.population, B.new_vaccinations
SELECT*, (cummulative_vaccination/population)*100 Percentage_vaccinated
FROM #Vac_pop
ORDER BY location, date



--Creating view

CREATE VIEW Vac_pop --Vac_pop means vaccinated population
	AS
SELECT
	A.continent,
	A.location,
	A.date,
	A.population,
	new_vaccinations,
	SUM(CONVERT(INT,B.new_vaccinations)) OVER (PARTITION BY A.location ORDER BY A.location, A.date) cummulative_vaccination
FROM [PortfolioProject].[dbo].[CovidDeaths] A -- A represent CovidDeaths table
	  JOIN [PortfolioProject].[dbo].[vaccination] B -- B represents vaccination table
		ON A.location=B.location
			AND A.date=B.date
	WHERE A.continent is not null
		AND new_vaccinations is not null
GROUP BY A.continent, A.date, A.location, A.population, B.new_vaccinations


