
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select the data we're going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

--Total Cases vs Total Deaths
--by the end of 2020 you had a 1.78% chance of dying from covid
--Shows the likelihood of dying if you contract covid in your country 

SELECT continent, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where location LIKE '%states%' 
and continent is not null
order by 1,2


--Looking at the total cases vs the population 
--Shows what percentage of poulation got Covid
--by the end of 2020 6% of the population contracted covid

SELECT continent, date, population, total_cases, (total_cases/population)*100 AS ContractionPercentage
FROM PortfolioProject..CovidDeaths
where location LIKE '%states%'
and continent is not null
order by 1,2


--Looking at Countries with Highest Infection Rate compared to the Population 

SELECT continent, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS ContractionPercentage
FROM PortfolioProject..CovidDeaths
--where location LIKE '%states%'
GROUP BY continent, population
ORDER BY ContractionPercentage desc

-- Showing Countries with Highest Death Rate per Population***************************************************************************************************************************

SELECT continent, population, MAX(total_deaths) AS HighesDeathCount, MAX((total_deaths/population))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location LIKE '%states%'
GROUP BY continent, population
ORDER BY DeathPercentage desc

-- Showing Countries with Highest Death Count 

SELECT continent, MAX(cast(total_deaths as int)) AS HighesDeathCount
FROM PortfolioProject..CovidDeaths
--where location LIKE '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY HighesDeathCount desc

--Breaking it down  

SELECT location, MAX(cast(total_deaths as int)) AS HighesDeathCount
FROM PortfolioProject..CovidDeaths
--where location LIKE '%states%'
WHERE continent is null
GROUP BY location
ORDER BY HighesDeathCount desc


-- Showing continents with highest death count

SELECT continent, MAX(cast(total_deaths as int)) AS HighesDeathCount
FROM PortfolioProject..CovidDeaths
--where location LIKE '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY HighesDeathCount desc





--GLOBAL NUMBERS


SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location LIKE '%states%' 
WHERE continent is not null
--GROUP BY date
order by 1,2

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location LIKE '%states%' 
WHERE continent is not null
GROUP BY date
order by 1,2

--Looking at the Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,1

Select *
FROM PercentPopulationVaccinated