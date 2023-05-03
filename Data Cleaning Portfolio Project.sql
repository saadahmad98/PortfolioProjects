/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProject..nashvillehousing

----------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

ALTER TABLE nashvillehousing
ADD saledateconverted date;

UPDATE nashvillehousing
SET saledateconverted = CONVERT(date, saledate)

SELECT saledateconverted, CONVERT(date, saledate)
FROM PortfolioProject..nashvillehousing

----------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data

SELECT *
FROM PortfolioProject..nashvillehousing
--where propertyaddress is null
ORDER BY ParcelID


SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL (a.propertyaddress, b.propertyaddress)
FROM PortfolioProject..nashvillehousing AS a 
JOIN PortfolioProject..nashvillehousing AS b
	ON a.parcelid = b.parcelid
	AND a.[uniqueid] <> b.[uniqueid]
WHERE a.propertyaddress IS NULL 


UPDATE a
SET propertyaddress = ISNULL (a.propertyaddress, b.propertyaddress)
FROM PortfolioProject..nashvillehousing AS a 
JOIN PortfolioProject..nashvillehousing AS b
	ON a.parcelid = b.parcelid
	AND a.[uniqueid] <> b.[uniqueid]
WHERE a.propertyaddress IS NULL

----------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..nashvillehousing

SELECT 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) AS address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress)) AS address
FROM portfolioproject..nashvillehousing


ALTER TABLE nashvillehousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1)

ALTER TABLE nashvillehousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, LEN(propertyaddress))


SELECT *
FROM PortfolioProject..nashvillehousing

SELECT owneraddress
FROM PortfolioProject..nashvillehousing


SELECT
PARSENAME(Replace(owneraddress, ',', '.'), 3),
PARSENAME(Replace(owneraddress, ',', '.'), 2),
PARSENAME(Replace(owneraddress, ',', '.'), 1)
FROM PortfolioProject..nashvillehousing


ALTER TABLE nashvillehousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = PARSENAME(Replace(owneraddress, ',', '.'), 3)

ALTER TABLE nashvillehousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitCity = PARSENAME(Replace(owneraddress, ',', '.'), 2)

ALTER TABLE nashvillehousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitState = PARSENAME(Replace(owneraddress, ',', '.'), 1)


SELECT *
FROM PortfolioProject..nashvillehousing

----------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY soldasvacant
ORDER BY 2

SELECT soldasvacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..nashvillehousing

UPDATE NashvilleHousing
SET soldasvacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

----------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	Row_Number() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num	
FROM PortfolioProject..nashvillehousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY propertyaddress


SELECT *
FROM PortfolioProject..nashvillehousing

----------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns 

SELECT *
FROM PortfolioProject..nashvillehousing

ALTER TABLE PortfolioProject..nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..nashvillehousing
DROP COLUMN SaleDate

