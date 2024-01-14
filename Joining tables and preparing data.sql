--Joining tables and preparing data

WITH
	vendor_tab AS --TO PULL DATA FROM TABLE1
	(SELECT company_name,
			company_code,
			gcor_id,
			is_rmb,
			account_type,
			br_brand_name AS brand_name,
			parent_vendor_code,
			child_vendor_code,
			gcor_primary_gl AS owning_gl,
			snapshot_date
	FROM table1 
	WHERE snapshot_date = CAST(DATE_TRUNC('MONTH', CURRENT_DATE)-INTERVAL '1 day' as date)
	AND marketplace_id = 7
	AND account_type IN ('Brand Owner','Brand Supplier')
	AND is_rmb = 'Yes'
	GROUP BY 1,2,3,4,5,6,7,8,9,10),


	--TAKING ALL DATA FROM TABLE1 AND REPLACING GL NAMES
	vendor_gl AS
	(SELECT * 
		, CASE 
			WHEN owning_gl = '1 - wireless' THEN 'CA Wireless'
			WHEN owning_gl = '2 - home' THEN 'CA Home'
			WHEN owning_gl = '3 - office_product' THEN 'CA Office Products'
			WHEN owning_gl = '4 - electronics' THEN 'CA Consumer Electronics'
			WHEN owning_gl = '5 - home_entertainment' THEN 'CA Home Entertainment'
			WHEN owning_gl = '6 - video_games' THEN 'CA Video Games'
			WHEN owning_gl = '7 - grocery' THEN 'CA Grocery'
			WHEN owning_gl = '8 - tools' THEN 'CA Tools'
			WHEN owning_gl = '9 - pc' THEN 'CA Personal Computer'
			WHEN owning_gl = '10 - toy' THEN 'CA Toys'
			WHEN owning_gl = '11 - toys' THEN 'CA Toys'
			WHEN owning_gl = '12 - drugstore' THEN 'CA Health and Personal Care'
			WHEN owning_gl = '13 - kitchen' THEN 'CA Kitchen'
			WHEN owning_gl = '14 - furniture' THEN 'CA Furniture'
			WHEN owning_gl = '15 - apparel' THEN 'CA Apparel'
			WHEN owning_gl = '16 - pet_products' THEN 'CA Pets'
			WHEN owning_gl = '17 - camera' THEN 'CA Camera'
			WHEN owning_gl = '18 - beauty' THEN 'CA Beauty'
			WHEN owning_gl = '19 - baby_product' THEN 'CA Baby'
			WHEN owning_gl = '20 - shoes' THEN 'CA Shoes'
			WHEN owning_gl = '21 - outdoors' THEN 'CA Outdoors'
			WHEN owning_gl = '22 - home_improvement' THEN 'CA Home Improvement'
			WHEN owning_gl = '23 - automotive' THEN 'CA Automotive'
			WHEN owning_gl = '24 - sports' THEN 'CA Sporting Goods'
			WHEN owning_gl = '25 - luxury_beauty' THEN 'CA Luxury Beauty'
			WHEN owning_gl = '26 - biss' THEN 'CA BISS'
			WHEN owning_gl = '27 - lawn_and_garden' THEN 'CA Lawn and Garden'
			WHEN owning_gl = '27 - musical_instruments' THEN 'CA Musical Instruments'
			WHEN owning_gl = '28 - watch' THEN 'CA Watches'
			WHEN owning_gl = '29 - luggage' THEN 'CA Luggage'
			WHEN owning_gl = '30 - music' THEN 'CA Music'
			WHEN owning_gl = '31 - jewelry' THEN 'CA Jewelry'
			WHEN owning_gl = '32 - major_appliances' THEN 'CA Large Appliances'
			WHEN owning_gl = '33 - tires' THEN 'CA Tires'
			WHEN owning_gl = '34 - personal_care_appliances' THEN 'CA Personal Care Appliances'
			END AS brand_owning_gl
	FROM vendor_tab),

	--EXTRACTING ALL THE DETAILS OF VENDORS FROM 3 DIFF MAIN TABLES
	vendor_details AS 
	(SELECT
	v.primary_vendor_code,
	v.Vendor_Name,
	v.organization_tier,
	v.organization_owner,
	split_part(vm.full_company_code, '/', 2) AS company_codes,
	v.is_merchandise_ordering_active,
	v.is_dropship,
	v.vendor_id,
	am.type AS brand_type,
	vm.inventory_vendor_type_id,

	CASE when vm.inventory_vendor_type_id = '1' then 'WHOLESALER'
		 when vm.inventory_vendor_type_id = '2' then 'MANUFACTURER'
		 when vm.inventory_vendor_type_id = '3' then 'RETAILER'
		 when vm.inventory_vendor_type_id = '4' then 'SALES_HOUSE'
		 else 'other'
		 end as inventory_type,
		 
	CASE WHEN v.is_dropship = 'Y' AND v.is_merchandise_ordering_active IN ('Y','N') THEN 'TRUE'
		 WHEN v.is_dropship = 'N' AND v.is_merchandise_ordering_active = 'Y' THEN 'TRUE'
		 WHEN v.is_dropship = 'N' AND v.is_merchandise_ordering_active = 'N' THEN 'FALSE' 
		 WHEN v.is_dropship IS NULL AND v.is_merchandise_ordering_active = 'Y' THEN 'TRUE'
		 WHEN v.is_dropship IS NULL AND v.is_merchandise_ordering_active = 'N' THEN 'FALSE'
		 END AS is_dropship_filter
		 
	from table_v v
	join table_am am
	on v.a_business_group_id = am.id
	Join table_vm vm
	on v.vendor_id = vm.vendor_id
	),


	--EXTRACTING PARENT AND CHILD VENDOR CODES AS LIST FROM 2ND TEMP TABLE
	VENDOR_CODES_MASTER_COLUMN AS
	(
	SELECT parent_vendor_code AS VENDOR_CODES 
	FROM vendor_gl 
	UNION SELECT child_vendor_code AS VENDOR_CODES 
	FROM vendor_gl
	),


	--APPLYING REQUIRED FILTERS TO THE VENDOR DATA
	vendor_filter AS
	(SELECT A.*  FROM vendor_details A
	WHERE primary_vendor_code IN (SELECT VENDOR_CODES FROM VENDOR_CODES_MASTER_COLUMN)

	AND brand_type IN ('CA Apparel','CA Automotive','CA BISS','CA Baby','CA Beauty','CA Camera','CA Consumer Electronics','CA Furniture','CA Grocery','CA Health and Personal Care', 'CA Home', 'CA Home Entertainment','CA Home Improvement','CA Jewelry','CA Kitchen','CA Large Appliances','CA Lawn and Garden','CA Luggage','CA Luxury Beauty','CA Musical Instruments','CA Office Products','CA Outdoors','CA Personal Care Appliances','CA Personal Computer','CA Pets','CA Shoes','CA Sporting Goods','CA Tires','CA Tools','CA Toys','CA Video Games','CA Watches','CA Wireless')

	AND organization_owner = 'Retail Business' 
	AND inventory_type IN ('MANUFACTURER','WHOLESALER') 
	AND is_dropship_filter = 'TRUE'
	AND Vendor_Name NOT LIKE '%hazmat%'
	AND Vendor_Name NOT LIKE '%Hazmat%'
	AND Vendor_Name NOT LIKE '%HAZMAT%'
	AND Vendor_Name NOT LIKE '%PALLET%'
	AND Vendor_Name NOT LIKE '%Pallet%'
	AND Vendor_Name NOT LIKE '%pallet%'
	ORDER BY inventory_type),


	--Taking parent vendor codes from above temp table
	parent_vc_match AS
	(SELECT *, 
	CASE WHEN a.parent_vendor_code = b.primary_vendor_code THEN 'TRUE' END AS vendor_filter
	FROM vendor_gl a
	LEFT JOIN vendor_filter b
	ON a.parent_vendor_code = b.primary_vendor_code
	),


	--Taking child vendor codes from the child temp table
	child_vc_match AS
	(SELECT * ,
	CASE WHEN a.child_vendor_code = b.primary_vendor_code THEN 'TRUE' END AS vendor_filter
	FROM vendor_gl a
	LEFT JOIN vendor_filter b
	ON a.child_vendor_code = b.primary_vendor_code
	),


	--Joining parent & child vendor codes, and their details
	vc_match_union AS
	(SELECT * 
	FROM parent_vc_match WHERE vendor_filter = 'TRUE'
	UNION 
	SELECT * 
	FROM child_vc_match WHERE vendor_filter = 'TRUE'
	), 


	--Extracting vendor codes, company codes along with their business groups
	for_contacts AS
	(SELECT vendor_code
	 , vendor_id
	 , unprefixed_company_code AS company_codes
	 , business_group_name
	FROM table_vch
	WHERE retail_country_code = 'CA'
	 AND business_group_name IN ('CA Apparel'
								,'CA Automotive'
								,'CA BISS'
								,'CA Baby'
								,'CA Beauty'
								,'CA Camera'
								,'CA Consumer Electronics'
								,'CA Furniture'
								,'CA Grocery'
								,'CA Health and Personal Care'
								,'CA Home'
								,'CA Home Entertainment'
								,'CA Home Improvement'
								,'CA Jewelry'
								,'CA Kitchen'
								,'CA Large Appliances'
								,'CA Lawn and Garden'
								,'CA Luggage'
								,'CA Luxury Beauty'
								,'CA Musical Instruments'
								,'CA Office Products'
								,'CA Outdoors'
								,'CA Personal Care Appliances'
								,'CA Personal Computer'
								,'CA Pets'
								,'CA Shoes'
								,'CA Sporting Goods'
								,'CA Tires'
								,'CA Tools'
								,'CA Toys'
								,'CA Video Games'
								,'CA Watches'
								,'CA Wireless')
	),


	--Extracting VM & CSM data from table_pc
	table_pctc AS
	(SELECT company_code,
	 CASE
		 WHEN gl = 1 THEN 'CA Home Entertainment'
		 WHEN gl = 2 THEN 'CA Luggage'
		 WHEN gl = 3 THEN 'CA Office Products'
		 WHEN gl = 4 THEN 'CA BISS'
		 WHEN gl = 5 THEN 'CA Toys'
		 WHEN gl = 6 THEN 'CA Grocery'
		 WHEN gl = 7 THEN 'CA Beauty'
		 WHEN gl = 8 THEN 'CA Musical Instruments'
		 WHEN gl = 9 THEN 'CA Automotive'
		 WHEN gl = 10 THEN 'CA Tools'
		 WHEN gl = 11 THEN 'CA Personal Computer'
		 WHEN gl = 12 THEN 'CA Home'
		 WHEN gl = 13 THEN 'CA Consumer Electronics'
		 WHEN gl = 14 THEN 'CA Shoes'
		 WHEN gl = 15 THEN 'CA Kitchen'
		 WHEN gl = 16 THEN 'CA Health and Personal Care'
		 WHEN gl = 17 THEN 'CA Sporting Goods'
		 WHEN gl = 18 THEN 'CA Lawn and Garden'
		 WHEN gl = 19 THEN 'CA Baby'
		 WHEN gl = 20 THEN 'CA Pets'
		 WHEN gl = 21 THEN 'CA Furniture'
		 WHEN gl = 22 THEN 'CA Home Improvement'
		 WHEN gl = 23 THEN 'CA Wireless'
		 WHEN gl = 24 THEN 'CA Apparel'
		 WHEN gl = 25 THEN 'CA Luxury Beauty'
		 WHEN gl = 26 THEN 'CA Outdoors'
		 WHEN gl = 27 THEN 'CA Large Appliances'
		 WHEN gl = 28 THEN 'CA Camera'
		 WHEN gl = 29 THEN 'CA Watches'
		 WHEN gl = 30 THEN 'CA Jewelry'
		 WHEN gl = 31 THEN 'CA Tires'
		 WHEN gl = 32 THEN 'CA Personal Care Appliances'
		 WHEN gl = 33 THEN 'CA Video Games'
		 WHEN gl = 34 THEN 'CA Consumer Electronics'
		 END AS gl_product_groups
	 , LISTAGG(CASE WHEN role = 'VendorManager' THEN user_id END, ', ') WITHIN GROUP (ORDER BY user_id) AS VM
	 , LISTAGG(CASE WHEN role = 'AccountManager' THEN user_id END, ', ') WITHIN GROUP (ORDER BY user_id) AS CSM
	 
	 FROM table_pc
	 WHERE region = 'NA' AND marketscope = 'CA' AND gl IS NOT NULL
	 GROUP BY 1,2
	),


	--Tagging VM data to vendor codes
	vendor_contacts_tag AS
	(SELECT fmc.vendor_code
	 , fmc.vendor_id
	 , fmc.company_codes
	 , fmc.business_group_name
	 , pmc.VM
	FROM for_contacts fmc
	LEFT JOIN table_pctc pmc
	ON fmc.company_codes = pmc.company_code
	 AND fmc.business_group_name = pmc.gl_product_groups
	),


	--Separating CSM data
	vendor_contacts_tag2 AS
	(SELECT company_code, CSM
	 FROM table_pctc
	),


	--Joining VM & CSM data to the vendor codes
	final_contacts_tag AS
	(SELECT vmu.* ,
			vcpt.VM,
			vct.CSM
	 FROM vc_match_union vmu
	LEFT JOIN table_vcpt vcpt
	 ON vmu.primary_vendor_code = pc.vendor_code
	 AND vmu.vendor_id = pc.vendor_id
	LEFT JOIN vendor_contacts_tag2 vct
	 ON vmu.company_codes = vct.company_code
	)


--Final extraction of data by combining above tables (and converting the datatype to varchar to suit the local tables datatype)
SELECT SNAPSHOT_DATE 
, VENDOR_FILTER 
, GCOR_ID 
, BRAND_NAME 
, ORGANIZATION_OWNER 
, CHILD_VENDOR_CODE 
, IS_MERCHANDISE_ORDERING_ACTIVE 
, INVENTORY_VENDOR_TYPE_ID 
, ACCOUNT_TYPE 
, COMPANY_CODE 
, IS_DROPSHIP_FILTER 
, ORGANIZATION_TIER 
, VM  as vendor_manager
, OWNING_GL 
, IS_DROPSHIP 
, INVENTORY_TYPE 
, COMPANY_NAME 
, VENDOR_NAME 
, VENDOR_ID 
, BRAND_OWNING_GL 
, CSM  as account_manager
, BRAND_TYPE 
, IS_RMB 
, PRIMARY_VENDOR_CODE 
, PARENT_VENDOR_CODE 
FROM final_contacts_tag;
