--Standarize Date Format
SELECT SaleDateConverted
From DataCleaning_HousingData.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


------------------------------------------------------------------------------------------------------
--Populate Property Address data

SELECT PropertyAddress
FROM DataCleaning_HousingData.dbo.NashvilleHousing
Where PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning_HousingData.dbo.NashvilleHousing a
JOIN DataCleaning_HousingData.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning_HousingData.dbo.NashvilleHousing a
JOIN DataCleaning_HousingData.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]

------------------------------------------------------------------------------------------------------
--Address into Individual Columns (Address, City, State)

Select PropertyAddress
FROM DataCleaning_HousingData.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM DataCleaning_HousingData.dbo.NashvilleHousing

--PropertySplitAddress
ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

--PropertySplitCity
ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--Using Parsename with replace to create new columns
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM DataCleaning_HousingData.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerState

SELECT *
FROM DataCleaning_HousingData.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------
--Change Y to Yes, N to NO column: "Sold as Vacant"

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM DataCleaning_HousingData.dbo.NashvilleHousing
GROUP BY SoldAsVacant


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End
FROM DataCleaning_HousingData.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End


------------------------------------------------------------------------------------------------------
-- Remove Duplicates
WITH  RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM DataCleaning_HousingData.dbo.NashvilleHousing
)
--Delete
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
---------------------------------------------------------------------------------------
-- Delete Unused Columns

SELECT *
FROM DataCleaning_HousingData.dbo.NashvilleHousing

ALTER TABLE DataCleaning_HousingData.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE DataCleaning_HousingData.dbo.NashvilleHousing
DROP COLUMN SaleDate
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE DataCleaning_HousingData.dbo.NashvilleHousing
DROP COLUMN SaleDate
