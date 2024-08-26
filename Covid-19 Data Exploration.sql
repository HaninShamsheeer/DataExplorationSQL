select * 
from CovidPortfolioProject..CovidDeaths
order by 3, 4

select * 
from CovidPortfolioProject..CovidVaccinations
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from CovidPortfolioProject..CovidDeaths
order by 1, 2

-- Total Cases vs. Total Deaths 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths
order by 1, 2

-- Total Death Percentage in Canada 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths
where location like 'Canada' and total_deaths is not null
order by 2

-- Total Cases vs. Population 
-- Shows percentge of the whole population that got Covid

select location, date, population, total_cases, (total_cases/population)*100 as CasesPerPopulation
from CovidPortfolioProject..CovidDeaths
order by 1, 2

-- CasesPerPopulation in Canada 

select Location, Date, Population, total_cases,  (total_cases/population)*100 as CasesPerPopulation
from CovidPortfolioProject..CovidDeaths
where location like 'Canada' 
order by 2

-- Countries with highest Infection Rate per Population

select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as CasePerPopulation 
from CovidPortfolioProject..CovidDeaths
group by location, population
order by 4 DESC

-- Countries with highest Death Count per Population

select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 DESC

-- Countries with highest Death Count per Population

select Location, Max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population)) * 100 as DeathCountPerPopulation
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 DESC

-- Total Death Count Per Continent

select Continent, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by Continent
order by TotalDeathCount DESC

-- Total Global Cases & Deaths by Date 

select Date, sum(new_cases) as WorldTotalCases, sum(cast(new_deaths as int)) as WorldTotalDeaths
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1

-- Global Death Percentage by Date 

select Date, sum(new_cases) as WorldTotalCases, sum(cast(new_deaths as int)) as WorldTotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as WorldDeathPercentage
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1

-- Global Death Percentage

select sum(new_cases) as WorldTotalCases, sum(cast(new_deaths as int)) as WorldTotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as WorldDeathPercentage
from CovidPortfolioProject..CovidDeaths
where continent is not null

-- Total Populations vs. Total Vaccinated

select dea.Continent, dea.Location, dea.date, population, vac.new_vaccinations
from CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
order by 2, 3

-- Create Total Vaccinated by Location and Date 

select dea.Continent, dea.Location, dea.date, population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.Location, dea.date) as RollingPeopleVaccinated
from CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
order by 2, 3

-- Total Population vs. Vaccinations Using CTE 

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.Continent, dea.Location, dea.date, population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.Location, dea.date) as 
RollingPeopleVaccinated
from CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
)

Select *, (RollingPeopleVaccinated/Population)*100 as TotalVaccinationsPerPopulation
from PopVsVac

-- Total Population vs. Vaccinations Using Temp Table 

Drop Table if exists #PercentPopulationVaccinated
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
select dea.Continent, dea.Location, dea.date, population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.Location, dea.date) as 
RollingPeopleVaccinated
from CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100 as TotalVaccinationsPerPopulation
from #PercentPopulationVaccinated

-- Creating view to store data for visualisation

Create View PercentPopulationVaccinated as
select dea.Continent, dea.Location, dea.date, population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.Location, dea.date) as 
RollingPeopleVaccinated
from CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 


