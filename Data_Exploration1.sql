SELECT*
FROM PortfolioProject..CovidDeaths
WHERE continent IS not null
ORDER BY 3, 4
--A simple query to ensure the data imported properly

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4
--Selecting the Data I'll be using.
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2


-- Looking at the Total Cases vs Total Deaths
--How many total cases are there in this country? how many deaths do they have per case?
--This Shows the likelihood of dying if contracting covid in my country.

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2

--Total Cases Vs Population
--This shows what percentage of population got covid.

SELECT location, date, population, total_deaths, (total_deaths/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1,2
--This is the Countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100 
AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY continent, population
ORDER BY PercentPopulationInfected DESC

-- This shows the countries with the highest death count per population--

SELECT location, MAX(cast (total_deaths AS INT)) AS TotalDeathCount
--^^Here I added a CAST as INT due to the data coming through as NULL instead of the needed numbers^^--
FROM PortfolioProject..CovidDeaths
 WHERE continent IS not null
 GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing Continents With Highest Death Count Per Population--

SELECT continent, total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
 WHERE continent IS NOT null
 GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Covid Numbers--

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, 
	SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2
---HERE I Calculate the total amount of new cases as Total_Cases with the Total Deaths to get the worlds 
--Death Percentage when faced with covid during this time.


--EXPLORING OUR VACCINATION DATA AND JOINING MY TABLES TOGETHER--

SELECT * 
FROM PortfolioProject..CovidVaccinations dea
JOIN PortfolioProject..CovidVaccinations vac
-- Here I'm going to join my tables together I'll be joining them on Location and Date because those are 
--More consistent than the other columns.
	ON dea.location = vac. location
	and dea.date = vac.date

	--Looking at Total Population Vs Vaccination
WITH PopvsVac (continent, location, date, popuation, new_vaccinations, RollingVaccinatedCount)
AS
(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinationS,
SUM( CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingVaccinatedCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
-- Here I'm going to join my tables together I'll be joining them on Location and Date because those are 
--More consistent than the other columns.
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3)
--Here I display a CTE or  "Common Table Expression" Because I can't use my 
--New table name in my calculation for  my rolling count.--

-- TEMP TABLE--
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinatedCount numeric,
)



INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM( CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingVaccinatedCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3)

SELECT *, (RollingVaccinatedCount/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store and visualize--
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM( CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingVaccinatedCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3)
SELECT *
FROM PercentPopulationVaccinated