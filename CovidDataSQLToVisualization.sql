-- Select data that we are going to be using.
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2



-- Looking at total cases vs total deaths.
-- Shows the likelihood of dying if you contract
-- COVID-19 in a country. 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Order by 1, 2



-- Looking at total cases vs total deaths. 
-- Shows the likelihood of dying if you contract Covid in Japan.
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Japan'
Order by 1, 2



-- Looking at total cases vs population.
-- Shows what percentage of population contracted
-- COVID-19 in Japan.
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%japan%'
Order by 1, 2



-- Looking at countries with the higest infection rates compared to the population.
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group By Location, Population
Order by PercentPopulationInfected DESC



-- Looking at countries with the highest death count per population.
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent IS NOT NULL
Group By Location
Order by TotalDeathCount DESC



-- Looking at continents with the highest death count per population.
Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent IS NOT NULL
Group By Continent
Order by TotalDeathCount DESC



-- Global number of new cases by date with death percentage.
Select date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent IS NOT NULL
Group by Date
Order by 1,2



-- Global total cases vs total deaths with percentage.
Select  
SUM(new_cases) as TotalNewCases, 
SUM(cast(new_deaths as int)) as Total_Deaths, 
Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Continent IS NOT NULL
Order by 1,2

With PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
-- Total population vs vaccination rate.
-- Values go above 100% while counting second and further vaccine doses.
Select CD.Continent, CD.Location, CD.Date, CD.Population, CV.New_Vaccinations, SUM(CONVERT(bigint,CV.New_Vaccinations)) OVER (Partition by CD.Location Order by CD.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.Continent IS NOT NULL
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentTotalVaccinated
From PopsVac


-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
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
Select 
	CD.Continent, 
	CD.Location, 
	CD.Date, 
	CD.Population, 
	CV.New_Vaccinations, 
	SUM(CONVERT(bigint,CV.New_Vaccinations)) 
		OVER 
		(Partition by CD.Location Order by CD.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.Continent IS NOT NULL

Select *, (RollingPeopleVaccinated/Population)*100 as PercentTotalVaccinated
From #PercentPopulationVaccinated



-- Creating view to store data to be used later visualization.
Create View PercentPopulationVaccinated as
Select CD.Continent, CD.Location, CD.Date, CD.Population, CV.New_Vaccinations, SUM(CONVERT(bigint,CV.New_Vaccinations)) OVER (Partition by CD.Location Order by CD.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.Continent IS NOT NULL
