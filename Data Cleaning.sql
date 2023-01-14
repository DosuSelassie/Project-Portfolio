select *
from [portfolio project]..NashvilleHousing


--check for duplicate data BY unique ID
select DISTINCT UniqueID
from [portfolio project]..NashvilleHousing

--standardize date
ALTER TABLE NashvilleHousing
Add StandardDate Date;

update NashvilleHousing
set standardDate = CONVERT(Date,SaleDate);

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;


select *
from [portfolio project]..NashvilleHousing


--dealing with missing propeprty addresses
select tab1.ParcelID,tab1.PropertyAddress,tab2.ParcelID,tab2.PropertyAddress
from [portfolio project]..NashvilleHousing tab1
JOIN [portfolio project]..NashvilleHousing tab2
ON tab1.ParcelID = tab2.ParcelID
AND tab1.[UniqueID ] <> tab2.[UniqueID ]
where tab1.PropertyAddress is null


update tab1
set PropertyAddress = ISNULL(tab1.PropertyAddress,tab2.PropertyAddress)
from [portfolio project]..NashvilleHousing tab1
JOIN [portfolio project]..NashvilleHousing tab2
ON tab1.ParcelID = tab2.ParcelID
AND tab1.[UniqueID ] <> tab2.[UniqueID ]
where tab1.PropertyAddress is null

--checking updates
select *
from [portfolio project]..NashvilleHousing


--spiltting the property address colunm
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)- 1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from [portfolio project]..NashvilleHousing


ALTER TABLE NashvilleHousing
Add Address varchar(255);

update NashvilleHousing
set Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)- 1);

ALTER TABLE NashvilleHousing
Add City varchar(255);

update NashvilleHousing
set City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));



ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress;

--splitting owner Address
select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [portfolio project]..NashvilleHousing

--creating new columns for the splitted columns
ALTER TABLE NashvilleHousing
Add OwnersAddress Nvarchar(255);

update NashvilleHousing
SET OwnersAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerCity Nvarchar(255);

update NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerState Nvarchar(255);

update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerStae

select *
from [portfolio project]..NashvilleHousing


--correcting spelling errors in SoldAsVacant column
select distinct SoldAsVacant,
count(SoldAsVacant) as Tally
from [portfolio project]..NashvilleHousing
group by SoldAsVacant
order by 2

update NashvilleHousing
SET SoldAsVacant= CASE WHEN SoldAsVacant = 'N' THEN 'No'
                       WHEN SoldAsVacant = 'Y' THEN 'Yes'
					   ELSE SoldAsVacant
					   END

--remove duplicates
With num_of_rows AS 
 ( select *,
   ROW_NUMBER() OVER (PARTITION BY ParcelID,Address,SalePrice,StandardDate,LegalReference ORDER BY UniqueID) Num_rows
   from [portfolio project]..NashvilleHousing)
   
   DELETE
   from num_of_rows
   where Num_rows > 1

 --remove more unused columns
 ALTER TABLE NashvilleHousing
 DROP COLUMN TaxDistrict

 --cleaned data
 select * 
 from [portfolio project]..NashvilleHousing
                                 
  