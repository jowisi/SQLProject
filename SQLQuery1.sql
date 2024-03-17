



-- Exploration of COVID 19 Dataset (accessed 08/03/24, www.ourworldindata.com/coronavirus)

-- With this SQL project I want to demonstrate my multi-variate EDA skills, improving my understanding of this third-party dataset

-- First, I check the data has been imported correctly

Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations$
Order by 3,4



-- Select the data I am going to be using.

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2



-- Looking at Total Cases vs Total Deaths
-- This shows the likelihood of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, (cast(total_deaths as int)/cast(total_cases as float))*100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%United Kingdom%'
Order by 1,2



-- Looking at Total Cases vs Population
-- This shows what percentage of population contracted Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 AS CasePercentage
From PortfolioProject..CovidDeaths$
Where location like '%United Kingdom%'
Order by 1,2



-- Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS CasePercentage
From PortfolioProject..CovidDeaths$
Where location like '%United Kingdom%'
Group by Location, Population
Order by CasePercentage DESC



-- Looking at countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths$
Where location like '%United Kingdom%'
-- Where continent is not null
Group by Location
Order by TotalDeathCount DESC



-- Breaking death rates down by continent

-- This shows continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths$
-- Where location like '%United Kingdom%'
Where continent is not null
Group by continent
Order by TotalDeathCount DESC



-- Global numbers
-- Looking at the percentage of cases that result in death.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths$
-- Where location like '%United Kingdom%'
Where continent is not null
-- Group by date
Order by 1,2



-- Looking at Total Population vs Vaccinations
-- This JOIN and window function looks at the number of vaccinated against each country's population.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
AS VaccinationsRollingTotal
FROM PortfolioProject..CovidDeaths$ AS dea
Join PortfolioProject..CovidVaccinations$ AS vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



-- Using a Common Table Expression (CTE) to perform calculation on above new column
-- Looking at the increase in the percentage of population vaccinated over time

With PopvsVac (continent, location, date, population, new_vaccinations, VaccinationsRollingTotal)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
AS VaccinationsRollingTotal
FROM PortfolioProject..CovidDeaths$ AS dea
Join PortfolioProject..CovidVaccinations$ AS vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (VaccinationsRollingTotal/Population)*100 AS PercentagePopulationVaccinated
From PopvsVac



-- Creating a Temp Table as an alternative to above query

Drop Table if exists #PopulationVaccinationPercentage

Create Table #PopulationVaccinationPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
VaccinationsRollingTotal numeric
)

Insert into #PopulationVaccinationPercentage

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
AS VaccinationsRollingTotal
FROM PortfolioProject..CovidDeaths$ AS dea
Join PortfolioProject..CovidVaccinations$ AS vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3


Select *, (VaccinationsRollingTotal/Population)*100
From #PopulationVaccinationPercentage



-- Creating View to store data for later visualisations

USE PortfolioProject
GO
Create View PopulationVaccinationPercentage AS
 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
AS VaccinationsRollingTotal
FROM PortfolioProject..CovidDeaths$ AS dea
Join PortfolioProject..CovidVaccinations$ AS vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


-- ENDS
-- Thank you for your time - Joe