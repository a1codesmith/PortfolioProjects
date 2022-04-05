Select *
 From [yt_portfolio_project 1]..covidDeaths
 Where continent is not null
 order by 3, 4

--Select *
-- From [yt_portfolio_project 1]..covidVaccinations
-- order by 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
 From [yt_portfolio_project 1]..covidDeaths
 order by 1,2

-- looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
 From [yt_portfolio_project 1]..covidDeaths
 where location like '%states%'
 order by 1,2

 -- looking at total cases vs population
 -- shows what percentage of population got Covid

 Select location, date, total_cases, population, (total_cases/population)*100 as percent_of_population_infected
 From [yt_portfolio_project 1]..covidDeaths
 --where location like '%states%'
 order by 1,2

 -- looking at countries with highest infection rate compared to population

 Select location, Max(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as percent_of_population_infected
 From [yt_portfolio_project 1]..covidDeaths
 --where location like '%states%'
 group by location, population
 order by percent_of_population_infected desc

 -- showing countries with highest death count per population

 Select location, MAX(cast(Total_deaths as int)) as total_death_count
 From [yt_portfolio_project 1]..covidDeaths
 --where location like '%states%'
 Where continent is not null
 group by location
 order by total_death_count desc

 -- Breaking things down by continent

 Select continent, MAX(cast(Total_deaths as int)) as total_death_count
 From [yt_portfolio_project 1]..covidDeaths
 --where location like '%states%'
 Where continent is not null
 group by continent
 order by total_death_count desc

 
 -- showing continents with the highest death count per population

  Select continent, MAX(cast(Total_deaths as int)) as total_death_count
 From [yt_portfolio_project 1]..covidDeaths
 --where location like '%states%'
 Where continent is not null
 group by continent
 order by total_death_count desc

 -- Global numbers

 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathPercentage
 From [yt_portfolio_project 1]..covidDeaths
 --where location like '%states%'
 Where continent is not null
 --Group by date
 order by 1,2

 -- Looking at total population vs vaccinations

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_people_vaccinated
 From [yt_portfolio_project 1]..covidDeaths dea
 Join [yt_portfolio_project 1]..covidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
	 Where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_people_vaccinated)
as
(
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_people_vaccinated --, (Rolling_people_vaccinated/population)*100
 From [yt_portfolio_project 1]..covidDeaths dea
 Join [yt_portfolio_project 1]..covidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
	 Where dea.continent is not null
--order by 2,3
)
Select *, (Rolling_people_vaccinated/Population)*100
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric,
)

Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_people_vaccinated --, (Rolling_people_vaccinated/population)*100
 From [yt_portfolio_project 1]..covidDeaths dea
 Join [yt_portfolio_project 1]..covidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
	 Where dea.continent is not null
--order by 2,3

Select *, (Rolling_people_vaccinated/Population)*100
From #PercentPopulationVaccinated

-- creating view for data viz

Create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_people_vaccinated --, (Rolling_people_vaccinated/population)*100
 From [yt_portfolio_project 1]..covidDeaths dea
 Join [yt_portfolio_project 1]..covidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
	 Where dea.continent is not null
--order by 2,3
