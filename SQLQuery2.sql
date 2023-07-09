 

 select *
 from PortfolioProject1..CovidDeaths
 where continent is not null
 order by 3,4

 select Location, date, total_cases, new_cases,total_deaths,population
 from PortfolioProject1..CovidDeaths
 where continent is not null
 order by 1,2;

 -- Looking at Total Cases vs Total Deaths
 -- Shows Likelihood of dying with covid
SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT))*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%india%' and continent is not null
ORDER BY 1, 2;

-- Looking at total Cases VS Population
-- Shows what percentage of people has got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%india%'
where continent is not null
ORDER BY 1, 2;

-- looking at countries with hishest infection rates

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT))*100) AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%india%'
where continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc;

-- Showing countries with Hishest Death count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%india%'
where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc;

-- breaking by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%india%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;

--show continent with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%india%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;

--Global numbers

SELECT date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%india%' and 
where continent is not null and new_cases!=0
Group By date
ORDER BY 1, 2;

--total percent of deaths world wide
SELECT sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast (new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%india%' and 
where continent is not null and new_cases!=0 
ORDER BY 1, 2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea 
JOIN PortfolioProject1..CovidVaccination vac 
		ON dea.location = vac.location 
		AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 