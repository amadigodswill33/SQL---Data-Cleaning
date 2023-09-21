-- SQL DATA CLEANING PROJECT

select *
from [Data Cleaning Project]..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------

--Standardizing Sales Date..This way can have a standard date of '2013-08-28' instead of '2013-08-28 00:00:00.000'..

alter table [Data Cleaning Project]..NashvilleHousing
Add StandardSaleDate Date;


select StandardSaleDate, CONVERT(DATE, SaleDate)
from [Data Cleaning Project]..NashvilleHousing

Update [Data Cleaning Project]..NashvilleHousing
set StandardSaleDate = CONVERT(DATE, SaleDate)


select *
from [Data Cleaning Project]..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------

--Populate PropertyAddress...We will try to populate the PropertyAddress for missing addresses...

select *
from [Data Cleaning Project]..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.PropertyAddress, a.ParcelID, ISNULL(a.propertyAddress, b.PropertyAddress)
from [Data Cleaning Project]..NashvilleHousing as a
Join [Data Cleaning Project]..NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
from [Data Cleaning Project]..NashvilleHousing as a
Join [Data Cleaning Project]..NashvilleHousing as b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]

select *
from [Data Cleaning Project]..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

---------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (i.e Address, City and States)
---PROPERTYADDRESS

--let's view the propertyaddress..
select PropertyAddress
from [Data Cleaning Project]..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(propertyaddress,1, charindex(',', propertyaddress) -1) as Address
, SUBSTRING(propertyaddress, charindex(',', propertyaddress)+1 , LEN(propertyaddress)) as City
from [Data Cleaning Project]..NashvilleHousing

alter table [Data Cleaning Project]..NashvilleHousing
Add PropertySplitAddress Varchar(255)

Update [Data Cleaning Project]..NashvilleHousing
set PropertySplitAddress = SUBSTRING(propertyaddress,1, charindex(',', propertyaddress) -1)

alter table [Data Cleaning Project]..NashvilleHousing
Add PropertyCity Varchar(255)

Update [Data Cleaning Project]..NashvilleHousing
set PropertyCity = SUBSTRING(propertyaddress, charindex(',', propertyaddress)+1 , LEN(propertyaddress))

select *
from [Data Cleaning Project]..NashvilleHousing

---OWNERSADDRESS

select OwnerAddress
from [Data Cleaning Project]..NashvilleHousing

SELECT
PARSENAME (replace(OwnerAddress, ',', '.'),3) as OwnersplitAddress,
PARSENAME (replace(OwnerAddress, ',', '.'),2) as City,
PARSENAME (replace(OwnerAddress, ',', '.'),1) as State
from [Data Cleaning Project]..NashvilleHousing

alter table [Data Cleaning Project]..NashvilleHousing
Add OwnersplitAddress Varchar(255)

Update [Data Cleaning Project]..NashvilleHousing
set OwnersplitAddress = PARSENAME (replace(OwnerAddress, ',', '.'),3)

alter table [Data Cleaning Project]..NashvilleHousing
Add OwnersplitCity Varchar(255)

Update [Data Cleaning Project]..NashvilleHousing
set OwnersplitCity = PARSENAME (replace(OwnerAddress, ',', '.'),2)

alter table [Data Cleaning Project]..NashvilleHousing
Add OwnersplitState Varchar(255)

Update [Data Cleaning Project]..NashvilleHousing
set OwnersplitState = PARSENAME (replace(OwnerAddress, ',', '.'),1)

select *
from [Data Cleaning Project]..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant' field

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from [Data Cleaning Project]..NashvilleHousing


Update [Data Cleaning Project]..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

select * from [Data Cleaning Project]..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates
With RownumCTE AS (
select *,
	row_number() over(
	partition by parcelID,
				SalePrice,
				SaleDate,
				legalReference
				Order by
				UniqueID
				) row_num
	
from [Data Cleaning Project]..NashvilleHousing
--order by ParcelID
)
--delete
select * 
from RownumCTE
--where row_num 
--order by PropertyAddress;


------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Columns

alter table [Data Cleaning Project]..NashvilleHousing
drop column OwnerAddress, PropertyAddress, TaxDistrict

select * 
from
[Data Cleaning Project]..NashvilleHousing