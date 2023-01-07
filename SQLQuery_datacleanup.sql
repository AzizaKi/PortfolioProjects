/*

Cleaning Data in SQL Queries

*/

select *
FROM PortfolioProject.dbo.NashvilleHousing


-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date





--Populate Property Adress data


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is NULL
Order by ParcelID


Select a.Parcelid, a.PropertyAddress, b.Parcelid, b.PropertyAddress, ISNULL(a.PropertyAddress, b.Propertyaddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[Uniqueid] <> b.[Uniqueid]
WHERE a.PropertyAddress is NULL



Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.Propertyaddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[Uniqueid] <> b.[Uniqueid]
WHERE a.PropertyAddress is NULL




--Breaking out Address into Individual Columns

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
--Order by ParcelID


SELECT
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1) 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar (255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar (255);


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing



ALTER Table NashvilleHousing
ADD OwnerSplitAddress nvarchar (255)


UPDATE  NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)



ALTER Table NashvilleHousing
ADD OwnerSplitCity nvarchar (255)

UPDATE  NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER Table NashvilleHousing
ADD OwnerSplitState nvarchar (255)

UPDATE  NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)





-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant) , COUNT(soldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2


SELECT SoldAsVacant
,CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
	 WHEN SoldasVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvilleHousing



Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
	 WHEN SoldasVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END



--Remove Duplicates

WITH 
RowNumCTE AS 
(
Select *,
	ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress, 
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					 UniqueID
					 ) Row_num

FROM PortfolioProject.dbo.NashvilleHousing
--Where Row_num >1
)


--select *
--FROM RowNumCTE
--Where Row_num > 1
--order by PropertyAddress


--DELETE
--FROM RowNumCTE
--Where Row_num > 1



--Delete unused Column



Select *
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing

DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict