-- SQL DATA CLEANING PROJECT

-- View the initial dataset
SELECT *
FROM [Data Cleaning Project]..Nashville;

---------------------------------------------------------------------------------------------------------------------------------

-- Standardizing Sales Date: Set a standard date of '2013-08-28' instead of '2013-08-28 00:00:00.000'
ALTER TABLE [Data Cleaning Project]..Nashville
ADD StandardSaleDate DATE;

-- Update the new column with standardized dates
UPDATE [Data Cleaning Project]..Nashville
SET StandardSaleDate = CONVERT(DATE, SaleDate);

-- View the updated dataset
SELECT *
FROM [Data Cleaning Project]..Nashville;

---------------------------------------------------------------------------------------------------------------------------------

-- Populate PropertyAddress for missing addresses
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Data Cleaning Project]..Nashville AS a
JOIN [Data Cleaning Project]..Nashville AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- View the updated dataset
SELECT *
FROM [Data Cleaning Project]..Nashville
ORDER BY ParcelID;

---------------------------------------------------------------------------------------------------------------------------------

-- Splitting PropertyAddress into Address and City
ALTER TABLE [Data Cleaning Project]..Nashville
ADD PropertySplitAddress VARCHAR(255),
    PropertyCity VARCHAR(255);

UPDATE [Data Cleaning Project]..Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- View the updated dataset
SELECT *
FROM [Data Cleaning Project]..Nashville;

---------------------------------------------------------------------------------------------------------------------------------

-- Splitting OwnersAddress into Address, City, and State
ALTER TABLE [Data Cleaning Project]..Nashville
ADD OwnersplitAddress VARCHAR(255),
    OwnersplitCity VARCHAR(255),
    OwnersplitState VARCHAR(255);

UPDATE [Data Cleaning Project]..Nashville
SET OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnersplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnersplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- View the updated dataset
SELECT *
FROM [Data Cleaning Project]..Nashville;

-------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field
UPDATE [Data Cleaning Project]..Nashville
SET SoldAsVacant = CASE
                    WHEN SoldAsVacant = 'Y' THEN 'Yes'
                    WHEN SoldAsVacant = 'N' THEN 'No'
                    ELSE SoldAsVacant
                  END;

-- View the updated dataset
SELECT *
FROM [Data Cleaning Project]..Nashville;

-----------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates
WITH RownumCTE AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY ParcelID,
                        SalePrice,
                        SaleDate,
                        LegalReference
           ORDER BY UniqueID
         ) AS row_num
  FROM [Data Cleaning Project]..Nashville
)
-- Delete duplicates
SELECT * 
FROM RownumCTE;

------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Columns
ALTER TABLE [Data Cleaning Project]..Nashville
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict;

-- Rename the column StandardSaleDate to SaleDate
USE [Data Cleaning Project];
EXEC sp_rename 'Nashville.StandardSaleDate', 'SaleDate', 'COLUMN';

-- View the final dataset
SELECT * 
FROM [Data Cleaning Project]..Nashville
ORDER BY UniqueID;
