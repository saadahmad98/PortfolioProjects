-- Data records are between February 24th, 2020 To April 30th, 2021

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- In case of Data Type Errors I use the following code to change the data types to its appropriate data type
-- (change table, column, and data type to appropriate kind)
-- Uncomment when needed

--begin transaction

--alter table portfolioproject..covidvaccinations
--alter column new_vaccinations float;

--commit transaction;


-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country based off death percentage 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Population (Canada)
-- Percentage of population that got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PerecentageCasesPerPop
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'can%'
ORDER BY 1,2


-- Countries with the Highest Infection Rate vs Population

SELECT location, population, max(total_cases) AS HighestInfectionCount, max((total_cases/population))*100 AS PercentPopInfection
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopInfection DESC


-- Highest Number of Deaths per Population (Grouped into its respective continent)

SELECT continent, max(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT SUM(new_cases) AS SumNewCases, SUM(new_deaths) AS SumNewDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS NewDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


SELECT date, SUM(new_cases) AS SumNewCases, SUM(new_deaths) AS SumNewDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS NewDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Highest Number of Deaths per Country

SELECT location, MAX(total_deaths) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount  DESC

-----

SELECT SUM(MaxTotalDeaths) AS TotalDeathCount
FROM (
  SELECT MAX(total_deaths) AS MaxTotalDeaths
  FROM PortfolioProject..CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY continent
) AS ContinentMaxTotalDeaths;


-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Total Pop vs Vac with CTE 

WITH PopvsVac (continent, location, date, population, new_vaccinations, rollingtotalvaccinations)
AS (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (rollingtotalvaccinations/population)*100 PopPercentageVac
FROM popvsvac


-- Temp Table

DROP TABLE IF exists #PercentPopVac
CREATE TABLE #PercentPopVac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingTotalVaccinations numeric
)

INSERT INTO #PercentPopVac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rollingtotalvaccinations/population)*100 PopPercentageVac
FROM #PercentPopVac


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopVac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths AS DEA
JOIN PortfolioProject..CovidVaccinations AS VAC
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT * 
FROM PercentPopVac
