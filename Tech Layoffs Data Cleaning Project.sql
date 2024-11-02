######### DATA CLEANING ###############

SELECT * 
FROM world_layoffs.layoffs;

-- 1. Remove Duplicates 
-- 2. Statndardize the Data
-- 3. Null Values or blank Values
-- 4. Remove Any Column

CREATE TABLE world_layoffs.layoffs_staging
LIKE world_layoffs.layoffs;

SELECT *
FROM world_layoffs.layoffs_staging;

INSERT world_layoffs.layoffs_staging
SELECT *
FROM world_layoffs.layoffs;

###### Remove Duplicates ########

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off,'date') AS row_num
FROM world_layoffs.layoffs_staging;

SELECT *
FROM world_layoffs.layoffs_staging
WHERE company = 'Casper';


CREATE TABLE `world_layoffs``layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM world_layoffs.layoffs_staging2;

INSERT INTO world_layoffs.layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off,'date',
stage, country, funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_staging;

DELETE
FROM world_layoffs.layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM world_layoffs.layoffs_staging2
;

######## Standardizing Data #######

SELECT company, TRIM(company)
FROM world_layoffs.layoffs_staging2;

UPDATE world_layoffs.layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT(industry)
FROM world_layoffs.layoffs_staging2
ORDER BY 1;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE world_layoffs.layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location
FROM world_layoffs.layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY 1;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM world_layoffs.layoffs_staging2
ORDER BY 1;

UPDATE world_layoffs.layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM world_layoffs.layoffs_staging2;

UPDATE world_layoffs.layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM world_layoffs.layoffs_staging2;

ALTER TABLE world_layoffs.layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM world_layoffs.layoffs_staging2;

######### Null Values of Blank Values ##########

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';


SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL
OR industry = ' ';

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company = 'Airbnb';

SELECT *
FROM world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT *
FROM world_layoffs.layoffs_staging2;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM world_layoffs.layoffs_staging2;

###### Remove Columns ######

ALTER TABLE world_layoffs.layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM world_layoffs.layoffs_staging2;
