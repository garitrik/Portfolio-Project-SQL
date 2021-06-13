--Cheking the data table


select * from [Portfolio-Project].dbo.[NashvilleHousing]

--Standardize date format 

select SaleDate,CONVERT(Date,SaleDate) from [Portfolio-Project].dbo.[NashvilleHousing]


ALTER TABLE [Portfolio-Project].dbo.[NashvilleHousing]
ADD SaleDateConverted Date

Update [Portfolio-Project].dbo.[NashvilleHousing]
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Porperty Address

select * from [Portfolio-Project].dbo.[NashvilleHousing]
where PropertyAddress is null 

--Filling up the propety address form previos known value using self join


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) from [Portfolio-Project].dbo.[NashvilleHousing] a
JOIN [Portfolio-Project].dbo.[NashvilleHousing] b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--Then updating the table


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio-Project].dbo.[NashvilleHousing] a
JOIN [Portfolio-Project].dbo.[NashvilleHousing] b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-- Formating address into city and address


select 
SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
From [Portfolio-Project].dbo.[NashvilleHousing]

Alter Table [Portfolio-Project].dbo.[NashvilleHousing]
ADD PropertySplitAddress Nvarchar(255);

Update [Portfolio-Project].dbo.[NashvilleHousing]
set PropertySplitAddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table [Portfolio-Project].dbo.[NashvilleHousing]
ADD PropertySplitCity Nvarchar(255);

Update [Portfolio-Project].dbo.[NashvilleHousing]
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



select * from [Portfolio-Project].dbo.[NashvilleHousing]



Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [Portfolio-Project].dbo.[NashvilleHousing]

Alter Table [Portfolio-Project].dbo.[NashvilleHousing]
ADD OwnerSplitAddress Nvarchar(255);

Update [Portfolio-Project].dbo.[NashvilleHousing]
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Alter Table [Portfolio-Project].dbo.[NashvilleHousing]
ADD OwnerSplitCity Nvarchar(255);

Update [Portfolio-Project].dbo.[NashvilleHousing]
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table [Portfolio-Project].dbo.[NashvilleHousing]
ADD OwnerSplitState Nvarchar(255);

Update [Portfolio-Project].dbo.[NashvilleHousing]
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


select * from [Portfolio-Project].dbo.[NashvilleHousing]


--Chnage the sold , vacant column

Select Distinct(SoldAsVacant),count(SoldAsVacant)
from [Portfolio-Project].dbo.[NashvilleHousing]
group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from [Portfolio-Project].dbo.[NashvilleHousing]

Update [Portfolio-Project].dbo.[NashvilleHousing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Removing Duplicates


WITH RowNumCTE AS(
Select *,
ROW_NUMBER() over (
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order BY UniqueID) row_num

from [Portfolio-Project].dbo.[NashvilleHousing]
)
Delete 
from RowNumCTE
where row_num > 1



--Delete Unused Columns


select *
from [Portfolio-Project].dbo.[NashvilleHousing]

ALTER Table [Portfolio-Project].dbo.[NashvilleHousing]
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress

ALTER Table [Portfolio-Project].dbo.[NashvilleHousing]
DROP COLUMN SaleDate