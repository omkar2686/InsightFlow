create database covid;
use COVID;

SELECT * FROM 
covid.coviddeaths_table1
ORDER BY 3, 4;

-- SELECT * FROM 
-- covid.covidvaccinations
-- ORDER BY 3, 4;


-- Select data that we will be using
SELECT location , date , population , total_cases, new_cases , total_deaths
FROM coviddeaths_table1
ORDER BY 1, 2;

-- Shows estimate of deaths in your country
SELECT location , date , total_cases , total_deaths , (total_deaths / total_cases ) * 100  as DeathPercentage
FROM coviddeaths_table1
WHERE location  like "india";

-- What percentage of population got COVID in a country 
SELECT location , date , population , total_cases , total_deaths , (total_cases / population ) * 100  as CovidPercentage
FROM coviddeaths_table1
WHERE location = "india";


SELECT location , population , MAX(total_cases) AS Infection_rate  , MAX((total_cases / population )) * 100  as PercentagePopulationInfected
FROM coviddeaths_table1
-- WHERE location = "india" 
GROUP BY location , population  
ORDER BY PercentagePopulationInfected DESC;

-- HOW many people died 
SELECT location , MAX(cast(total_deaths as UNSIGNED ))  AS Total_Death_Count   -- for casting in integers use 'UNSIGNED'
FROM 
coviddeaths_table1
GROUP BY location
ORDER BY Total_Death_Count DESC;

-- Now , lets look into continents

SELECT continent, MAX(cast(total_deaths as UNSIGNED ))  AS Total_Death_Count   -- for casting in integers use 'UNSIGNED'
FROM 
coviddeaths_table1
WHERE continent is  not null
GROUP BY continent
ORDER BY Total_Death_Count DESC;

-- Shhowing the continents with highest deaths
SELECT continent, MAX(cast(total_deaths as UNSIGNED ))  AS Total_Death_Count   -- for casting in integers use 'UNSIGNED'
FROM 
coviddeaths_table1
WHERE continent is  not null
GROUP BY continent
ORDER BY Total_Death_Count DESC;

-- Looking at  Global numbers

SELECT  date , sum(new_cases) , sum(new_deaths) , sum(cast(new_deaths as unsigned)) as total_deaths , 
sum(cast(new_deaths as unsigned))/sum(new_cases)*100 as  DeathPercentage  -- (total_deaths/ total_cases ) * 100  as DeathPercentage
FROM coviddeaths_table1
WHERE continent is not null
GROUP BY date
order by 1 , 2 ; 

SELECT * FROM 
covidvaccinations;

-- Now , joining both the tables of Coviddeaths and CovidVaccinations together 
SELECT * FROM 
coviddeaths_table1 as dea 
JOIN 
covidvaccinations as vac
ON dea.location  = vac.location 
AND dea.date = vac.date ;

-- Now lets look at Percentage of Population that have vaccinated 

SELECT dea.continent , dea.date , dea.location , dea.population , vac.new_vaccinations , (vac.new_vaccinations / dea.population) * 100 AS PercentageVaccinated , sum(convert( vac.new_vaccinations, UNSIGNED)) over (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population)*100 --> We cant do this , next command will do this thing 
FROM coviddeaths_table1 as dea  
INNER JOIN covidvaccinations  as vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL  ;

-- USE CTE --> using this we can use new column that we have created in query
WITH PopVsVac (continent , date , location , population , new_vaccinations , PercentageVaccinated, RollingPeopleVaccinated)
AS
(
SELECT dea.continent , dea.date , dea.location , dea.population , vac.new_vaccinations , (vac.new_vaccinations / dea.population) * 100 AS PercentageVaccinated , sum(convert( vac.new_vaccinations, UNSIGNED)) over (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM coviddeaths_table1 as dea  
INNER JOIN covidvaccinations  as vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 
) 
SELECT * , (RollingPeopleVaccinated / population ) * 100
FROM PopVsVac;





-- Creating view to store data for later visualization 
CREATE VIEW PercentPopVaccinated  AS
SELECT dea.continent , dea.date , dea.location , dea.population , vac.new_vaccinations , (vac.new_vaccinations / dea.population)  AS PercentageVaccinated , sum(convert( vac.new_vaccinations, UNSIGNED)) over (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM coviddeaths_table1 as dea  
INNER JOIN covidvaccinations  as vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL ;





