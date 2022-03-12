
--SELECT * FROM CovidVaccinations
--order by 3,4

SELECT * FROM CovidDeaths
Where continent is not null
Order by 3,4

--1. % TotalDeath per TotalCases in Nigeria 
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as PercentageDeath FROM CovidDeaths
where location = 'Nigeria'
ORDER BY 1,2

--2, % TotalCases per Population in Nigeria
SELECT location,date,population,total_cases,(total_cases/population)*100 as '%GotCovid' FROM CovidDeaths
where location = 'Nigeria'
ORDER BY 1,2

--3  Infection rate of countries
SELECT location,Population,MAX(total_cases)AS 'TotalCases@Present',MAX((total_cases/population))*100 as '%gotcovid@Present' FROM CovidDeaths
Group by location,population
ORDER BY 4 desc

--4 Total Death count By Country
SELECT location,MAX(total_cases)AS 'TotalCasesCount',
MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM CovidDeaths
Where continent is not null
Group by location
ORDER BY 3 desc

--5 %TotalDeath per TotalCases for All Countries(CHance of you dying from covid)
SELECT location,MAX(total_cases)AS 'TotalCaseCount',MAX(CAST(total_deaths AS int)) AS 'TotalDeathCount',
(MAX(CAST(total_deaths AS int))/MAX(total_cases)*100) as '%DeathRate'
FROM CovidDeaths
Where continent is not null
Group by location
ORDER BY 4 desc

--6 Total Death count By Continent
SELECT continent,SUM(new_cases)AS 'TotalCasesCount',
SUM(CAST(new_deaths AS int)) as TotalDeathCount
FROM CovidDeaths
Where continent is not null
Group by continent
ORDER BY 2 desc

--7  DAILY GLOBAL NUMBERS
SELECT date,SUM(new_cases) AS 'DailyCasesCount',
SUM(CAST(new_deaths AS int)) as DailyDeathCount, (SUM(CAST(new_deaths AS int))/SUM(new_cases)*100) as DeathPercentage
FROM CovidDeaths
Where continent is not null
Group by date
ORDER BY 1

SELECT SUM(new_cases) AS 'DailyCasesCount',
SUM(CAST(new_deaths AS int)) as DailyDeathCount, (SUM(CAST(new_deaths AS int))/SUM(new_cases)*100) as DeathPercentage
FROM CovidDeaths
Where continent is not null

--8 JOIN WITH CovidVaccinations table
Select dea.continent,dea.location,dea.date, population,new_vaccinations,
SUM(cast(new_vaccinations as float)) OVER (PARTITION By dea.location order by dea.location,dea.date) as DailyTotalVaccinations
from CovidDeaths AS dea
JOIN CovidVaccinations vac ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null and new_vaccinations is not null
order by 2,3

--USING CTE
WITH PopvsVac (Continent,Location,Date,Population,new_vaccinations,DailyTotalVaccinations)
AS
(Select dea.continent,dea.location,dea.date, population,new_vaccinations,
SUM(cast(new_vaccinations as float)) OVER (PARTITION By dea.location order by dea.location,dea.date) as DailyTotalVaccinations
from CovidDeaths AS dea
JOIN CovidVaccinations vac ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)
Select *,(DailyTotalVaccinations/Population) *100
from PopvsVac

--Using Temp Table

DROP TABLE IF EXISTS #TotalVaccinations
CREATE TABLE #TotalVaccinations(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
DailyTotalVaccinated numeric
)
Insert into  #TotalVaccinations
Select dea.continent,dea.location,dea.date, population,new_vaccinations,
SUM(cast(new_vaccinations as float)) OVER (PARTITION By dea.location order by dea.location,dea.date) as DailyTotalVaccinations
from CovidDeaths AS dea
JOIN CovidVaccinations vac ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select *,(DailyTotalVaccinated/Population) *100
from #TotalVaccinations

--9 Creating VIEWS for Visualizatiom

Create View DailyTotalVaccinations as
Select dea.continent,dea.location,dea.date, population,new_vaccinations,
SUM(cast(new_vaccinations as float)) OVER (PARTITION By dea.location order by dea.location,dea.date) as DailyTotalVaccinations
from CovidDeaths AS dea
JOIN CovidVaccinations vac ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

CREATE VIEW PercentageDeathRate as
SELECT location,MAX(total_cases)AS 'TotalCaseCount',MAX(CAST(total_deaths AS int)) AS 'TotalDeathCount',
(MAX(CAST(total_deaths AS int))/MAX(total_cases)*100) as '%DeathRate'
FROM CovidDeaths
Where continent is not null
Group by location
