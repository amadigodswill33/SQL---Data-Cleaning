# SQL Data Cleaning Project Documentation

## Overview

This document outlines the processes and steps undertaken in the SQL Data Cleaning Project for the Nashville Housing dataset.

### Client Goal
The client aimed to enhance the quality and usability of the Nashville Housing dataset by addressing inconsistencies and standardizing key data elements. The primary objectives were to ensure accurate analysis and reporting, as well as to improve overall data integrity.

## Table of Contents

1. [Standardizing Sales Date](#standardizing-sales-date)
2. [Populating Property Addresses](#populating-property-addresses)
3. [Breaking down Addresses](#breaking-down-addresses)
    - [Property Addresses](#property-addresses)
    - [Owners' Addresses](#owners-addresses)
4. [Updating 'Sold As Vacant' Values](#updating-sold-as-vacant-values)
5. [Removing Duplicate Records](#removing-duplicate-records)
6. [Deleting Unnecessary Columns](#deleting-unnecessary-columns)

---

## 1. Standardizing Sales Date

### Objective

The aim is to standardize the format of sales dates in the Nashville table. This ensures a consistent representation for better clarity and analysis.

### Steps

- A new column, `StandardSaleDate`, is added to the table.
- The data in the `SaleDate` column is then updated to conform to the standard date format.

---

## 2. Populating Property Addresses

### Objective

To fill in missing values in the `PropertyAddress` column by leveraging available data within the dataset.

### Steps

- The SQL script updates the `PropertyAddress` column by using non-null values from corresponding records in the dataset.
```UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Data Cleaning Project]..Nashville AS a
JOIN [Data Cleaning Project]..Nashville AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;
```
---

## 3. Breaking down Addresses

### Property Addresses

#### Objective

To break down the `PropertyAddress` into distinct components like Address and City for better granularity.

#### Steps

- Two new columns, `PropertySplitAddress` and `PropertyCity`, are added to the table.
- The `PropertyAddress` is then split into these new columns.
```ALTER TABLE [Data Cleaning Project]..Nashville
ADD PropertySplitAddress VARCHAR(255),
    PropertyCity VARCHAR(255);

UPDATE [Data Cleaning Project]..Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));
```
### Owners' Addresses

#### Objective

Breaking down the `OwnerAddress` into individual components like Address, City, and State.

#### Steps

- Three new columns (`OwnersplitAddress`, `OwnersplitCity`, and `OwnersplitState`) are added.
- The `OwnerAddress` is then parsed and split into these new columns.

---

## 4. Updating 'Sold As Vacant' Values

### Objective

To update the values in the `SoldAsVacant` column from 'Y' and 'N' to 'Yes' and 'No' respectively for better readability.

### Steps

- The SQL script utilizes a `CASE` statement to update the values accordingly.
```UPDATE [Data Cleaning Project]..Nashville
SET SoldAsVacant = CASE
                    WHEN SoldAsVacant = 'Y' THEN 'Yes'
                    WHEN SoldAsVacant = 'N' THEN 'No'
                    ELSE SoldAsVacant
                  END;
---

## 5. Removing Duplicate Records

### Objective

Identifying and eliminating duplicate records based on specific criteria to maintain data integrity.

### Steps

- The SQL script employs a common table expression (CTE) to assign row numbers based on certain fields.
- The script then selects records from the CTE, effectively eliminating duplicates.
```WITH RownumCTE AS (
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
```
---

## 6. Deleting Unnecessary Columns

### Objective

To streamline the dataset by removing unnecessary columns that do not contribute to the analysis.

### Steps

- The SQL script removes the Original `SaleDate`, `OwnerAddress`, `PropertyAddress`, and `TaxDistrict` columns from the table.
``` ALTER TABLE [Data Cleaning Project]..Nashville
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict;
```
---

## Conclusion

This documentation provides a comprehensive overview of the SQL Data Cleaning Project. Each section details the specific objective, steps taken, and the impact on the NashvilleHousing dataset. Following these steps ensures a cleaner and more standardized dataset for further analysis.
