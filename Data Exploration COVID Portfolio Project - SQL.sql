-- Data records are between February 24th, 2020 TO April 30th, 2021

Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- In case of Data Type Errors I use the following code to change the data types to its appropriate data type
-- (change table, column, and data type to appropriate kind)

--begin transaction

--alter table portfolioproject..covidvaccinations
--alter column new_vaccinations float;

--commit transaction;



-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- 

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country based off death percentage 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Total Cases vs Population (Canada)
-- Percentage of population that got covid

Select location, date, population, total_cases, (total_cases/population)*100 as PerecentageCasesPerPop
from PortfolioProject..CovidDeaths
where location like 'can%'
order by 1,2


-- Countries with the Highest Infection Rate vs Population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopInfection
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopInfection desc


-- Highest Number of Deaths per Population (Grouped into its respective continent)


Select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

Select sum(new_cases) as SumNewCases, sum(new_deaths) as SumNewDeaths, (sum(new_deaths)/sum(new_cases))*100 as NewDeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


Select date, sum(new_cases) as SumNewCases, sum(new_deaths) as SumNewDeaths, (sum(new_deaths)/sum(new_cases))*100 as NewDeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


-- Highest Number of Deaths per Country

Select location, max(total_deaths) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount  desc






-----

SELECT SUM(MaxTotalDeaths) AS TotalDeathCount
FROM (
  SELECT MAX(total_deaths) AS MaxTotalDeaths
  FROM PortfolioProject..CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY continent
) AS ContinentMaxTotalDeaths;


-- Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject..CovidDeaths as DEA
Join PortfolioProject..CovidVaccinations as VAC
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Total Pop vs Vac with CTE 

with PopvsVac (continent, location, date, population, new_vaccinations, rollingtotalvaccinations)
as (
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject..CovidDeaths as DEA
Join PortfolioProject..CovidVaccinations as VAC
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select *, (rollingtotalvaccinations/population)*100 PopPercentageVac
from popvsvac


-- Temp Table

Drop table if exists #PercentPopVac
Create Table #PercentPopVac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingTotalVaccinations numeric
)

Insert into #PercentPopVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject..CovidDeaths as DEA
Join PortfolioProject..CovidVaccinations as VAC
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (rollingtotalvaccinations/population)*100 PopPercentageVac
from #PercentPopVac


-- Creating View to store data for later visualizations

Create view PercentPopVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
From PortfolioProject..CovidDeaths as DEA
Join PortfolioProject..CovidVaccinations as VAC
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select * 
from PercentPopVac