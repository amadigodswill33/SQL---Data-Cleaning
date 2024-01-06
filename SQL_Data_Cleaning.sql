-- SQL DATA CLEANING PROJECT

-- Standardizing Sales Date
-- This way can have a standard date of '2013-08-28' instead of '2013-08-28 00:00:00.000'
ALTER TABLE [Data Cleaning Project]..NashvilleHousing
ADD StandardSaleDate DATE;

UPDATE [Data Cleaning Project]..NashvilleHousing
SET StandardSaleDate = CONVERT(DATE, SaleDate);

-- Populate PropertyAddress
-- We will try to populate the PropertyAddress for missing addresses
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Data Cleaning Project]..NashvilleHousing AS a
JOIN [Data Cleaning Project]..NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID];

-- Breaking out Address into Individual Columns (i.e., Address, City, and States)
-- PROPERTYADDRESS
ALTER TABLE [Data Cleaning Project]..NashvilleHousing
ADD PropertySplitAddress VARCHAR(255),
    PropertyCity VARCHAR(255);

UPDATE [Data Cleaning Project]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- OWNERSADDRESS
ALTER TABLE [Data Cleaning Project]..NashvilleHousing
ADD OwnersplitAddress VARCHAR(255),
    OwnersplitCity VARCHAR(255),
    OwnersplitState VARCHAR(255);

UPDATE [Data Cleaning Project]..NashvilleHousing
SET OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnersplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnersplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Change Y and N to Yes and No in 'Sold as Vacant' field
UPDATE [Data Cleaning Project]..NashvilleHousing
SET SoldAsVacant = CASE
                    WHEN SoldAsVacant = 'Y' THEN 'Yes'
                    WHEN SoldAsVacant = 'N' THEN 'No'
                    ELSE SoldAsVacant
                  END;

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
  FROM [Data Cleaning Project]..NashvilleHousing
)
-- DELETE
SELECT *
FROM RownumCTE;

-- Delete Columns
ALTER TABLE [Data Cleaning Project]..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict;

SELECT *
FROM [Data Cleaning Project]..NashvilleHousing;
