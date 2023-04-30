/*

Cleaning Data in SQL Queries

*/

-- Format the spacing and the Capitalization on queries

Select *
from PortfolioProject..nashvillehousing

----------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

alter table nashvillehousing
add saledateconverted date;

update nashvillehousing
set saledateconverted = convert(date, saledate)

Select saledateconverted, convert(date, saledate)
from PortfolioProject..nashvillehousing

-- format this part later and add the change variable transaction code to alter the current table instead of adding a new one
-- delete the newly added column


----------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
from PortfolioProject..nashvillehousing
--where propertyaddress is null
order by ParcelID


Select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull (a.propertyaddress, b.propertyaddress)
from PortfolioProject..nashvillehousing as a 
join PortfolioProject..nashvillehousing as b
	on a.parcelid = b.parcelid
	and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null


update a
set propertyaddress = isnull (a.propertyaddress, b.propertyaddress)
from PortfolioProject..nashvillehousing as a 
join PortfolioProject..nashvillehousing as b
	on a.parcelid = b.parcelid
	and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null





----------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from PortfolioProject..nashvillehousing

select 
substring(propertyaddress, 1, charindex(',', propertyaddress) -1) as address,
substring(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress)) as address
from portfolioproject..nashvillehousing


alter table nashvillehousing
add PropertySplitAddress nvarchar(255);

update nashvillehousing
set PropertySplitAddress = substring(propertyaddress, 1, charindex(',', propertyaddress) -1)

alter table nashvillehousing
add PropertySplitCity nvarchar(255);

update nashvillehousing
set PropertySplitCity = substring(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress))


select *
from PortfolioProject..nashvillehousing




select owneraddress
from PortfolioProject..nashvillehousing


select
parsename(Replace(owneraddress, ',', '.'), 3),
parsename(Replace(owneraddress, ',', '.'), 2),
parsename(Replace(owneraddress, ',', '.'), 1)
from PortfolioProject..nashvillehousing



alter table nashvillehousing
add OwnerSplitAddress nvarchar(255);

update nashvillehousing
set OwnerSplitAddress = parsename(Replace(owneraddress, ',', '.'), 3)

alter table nashvillehousing
add OwnerSplitCity nvarchar(255);

update nashvillehousing
set OwnerSplitCity = parsename(Replace(owneraddress, ',', '.'), 2)

alter table nashvillehousing
add OwnerSplitState nvarchar(255);

update nashvillehousing
set OwnerSplitState = parsename(Replace(owneraddress, ',', '.'), 1)


select *
from PortfolioProject..nashvillehousing



-- clean up query by removing the excess select * statements


----------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By soldasvacant
order by 2


select soldasvacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
from PortfolioProject..nashvillehousing

Update NashvilleHousing
set soldasvacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End


----------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE as (
select *,
	Row_Number() over(
	partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num	
from PortfolioProject..nashvillehousing
)
--Delete
--From RowNumCTE
--where row_num > 1

Select *
From RowNumCTE
where row_num > 1
order by propertyaddress




select *
from PortfolioProject..nashvillehousing



----------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns 


select *
from PortfolioProject..nashvillehousing

Alter Table PortfolioProject..nashvillehousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..nashvillehousing
Drop Column SaleDate

--Format this by adding Sale date to the orignal query






