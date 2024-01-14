


--Creating a temp table and inserting SME & VP data manually
DROP TABLE IF EXISTS SME_DETAILS;
CREATE TEMP TABLE SME_DETAILS (
    formatted_gls VARCHAR(1000) NOT NULL,
	product_family VARCHAR(1000) NOT NULL,
	vp VARCHAR(1000) NOT NULL,
	selection_sme VARCHAR(1000) NOT NULL
);

INSERT INTO SME_DETAILS VALUES ('CA Video Games',  'BEATS',  'VP1', 'sme1@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Personal Computer',  'BEATS',  'VP1', 'sme2@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Wireless',  'BEATS',  'VP1', 'sme2@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Camera',  'BEATS',  'VP1', 'sme2@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA BISS',  'BEATS',  'VP1', 'sme3@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Consumer Electronics',  'BEATS',  'VP1', 'sme2@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Automotive',  'BEATS',  'VP1', 'sme3@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Tires',  'BEATS',  'VP1', 'sme3@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Home Entertainment',  'BEATS',  'VP1', 'sme2@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Musical Instruments',  'BEATS',  'VP1', 'sme2@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Office Products',  'BEATS',  'VP1', 'sme2@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Baby',  'Consumables',  'VP2', 'sme4@abc.com ');
INSERT INTO SME_DETAILS VALUES ('CA Health and Personal Care',  'Consumables',  'VP2', 'sme4@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Luxury Beauty',  'Consumables',  'VP2', 'sme4@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Pets',  'Consumables',  'VP2', 'sme5@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Personal Care Appliances',  'Consumables',  'VP2', 'sme4@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Grocery',  'Consumables',  'VP2', 'sme4@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Beauty',  'Consumables',  'VP2', 'sme4@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Sporting Goods',  'Fashion & Fitness',  'VP3', 'sme3@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Outdoors',  'Fashion & Fitness',  'VP3', 'sme3@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Apparel',  'Fashion & Fitness',  'VP3', 'sme6@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Luggage',  'Fashion & Fitness',  'VP3', 'sme6@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Jewelry',  'Fashion & Fitness',  'VP3', 'sme6@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Watches',  'Fashion & Fitness',  'VP3', 'sme6@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Shoes',  'Fashion & Fitness',  'VP3', 'sme6@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Furniture',  'Home and Lifestyle',  'VP4', 'sme5@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Kitchen',  'Home and Lifestyle',  'VP4', 'sme5@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Toys',  'Home and Lifestyle',  'VP4', 'sme3@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Home',  'Home and Lifestyle',  'VP4', 'sme5@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Large Appliances',  'Home and Lifestyle',  'VP4', 'sme3@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Tools',  'Home and Lifestyle',  'VP4', 'sme3@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Lawn and Garden',  'Home and Lifestyle',  'VP4', 'sme3@abc.com');
INSERT INTO SME_DETAILS VALUES ('CA Home Improvement',  'Home and Lifestyle',  'VP4', 'sme3@abc.com');



WITH 
		--Extracting data from table1
		item_gap_filters AS 
		(SELECT parent_brand, gcor_id, gl_product_group, gl_product_group_desc, SNAPSHOT_DAY,
		(ROUND(gl_product_group,0) ||' - ' || gl_product_group_desc) AS gl_product_grp, 
		CAST(COUNT(DISTINCT CASE WHEN IS_HEAD_SELECTION = 'Y' and UPPER(BUCKET) != 'RETAIL' THEN ec_unique_id end)as DECIMAL(10, 0)) as head_item_gaps
		FROM  table1
		WHERE SNAPSHOT_DAY = CAST(DATE_TRUNC('MONTH', CURRENT_DATE)-INTERVAL '1 day' as date)
		AND program_code != 'Unique'
		AND MARKETPLACE_ID = 7
		AND bucket IN ('Prioritized Gap', 'Secondary Gap')
		AND IS_INVALID = 'N' 

		GROUP BY parent_brand, gcor_id, SNAPSHOT_DAY, gl_product_group, gl_product_group_desc
		),

		--Renaming the records of gl_product_grp column
		formatted_gl AS
		(SELECT SNAPSHOT_DAY, 
				parent_brand,
				gcor_id,
				head_item_gaps,
		CASE 
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
		FROM item_gap_filters),


		--Extracting gcor_id and gl from table_y
		brand_owning_1 AS 
		(SELECT
		y.gcor_id,
		y.gcor_primary_gl AS brand_owning_gl,
		y.SNAPSHOT_DATE
		FROM table_y y
		WHERE y.SNAPSHOT_DATE = CAST(DATE_TRUNC('MONTH', CURRENT_DATE)-INTERVAL '1 day' as date)
		AND y.marketplace_id = 7
		GROUP BY 1,2,3
		),


		--Joining the above two tables (table1 & table_y)
		final_item_gap_view AS
		(SELECT a.SNAPSHOT_DAY, 
				a.parent_brand,
				a.gcor_id,
				a.head_item_gaps,
				b.brand_owning_gl,
				a.gl_product_groups
		FROM formatted_gl a
		LEFT JOIN brand_owning_1 b
		ON a.SNAPSHOT_DAY = b.SNAPSHOT_DATE
		AND a.gcor_id = b.gcor_id
		GROUP BY 1,2,3,4,5,6
		),


		--Extracting company level data from table_y
		vendor_tab AS
		(SELECT company_name,
			   company_code,
			   gcor_id,
			   is_rmb, 
			   account_type,
			   br_brand_name AS brand_name,
			   parent_vendor_code,
			   child_vendor_code,
			   gcor_primary_gl AS owning_gl
		FROM table_y
		WHERE SNAPSHOT_DATE = CAST(DATE_TRUNC('MONTH', CURRENT_DATE)-INTERVAL '1 day' as date)
		AND marketplace_id = 7
		AND account_type IN ('Brand Owner','Brand Supplier')
		AND is_rmb = 'Yes'
		GROUP BY 1,2,3,4,5,6,7,8,9
		),


		--Adding a new column brand_owning gl to the prev table by renaming the records
		vendor_gl AS
		(SELECT * , 
		CASE 
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


		--Extracting data from couple of vendor data tables and adding conditions using case function
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


		--Gathering all vendor codes
		VENDOR_CODES_MASTER_COLUMN AS
		(
		SELECT parent_vendor_code AS VENDOR_CODES FROM vendor_gl 
		UNION 
		SELECT child_vendor_code AS VENDOR_CODES FROM vendor_gl
		),


		--Adding filters to vendor data
		vendor_filter AS
		(SELECT A.* 
		FROM vendor_details A
		WHERE primary_vendor_code IN (SELECT VENDOR_CODES 
									  FROM VENDOR_CODES_MASTER_COLUMN)

		AND brand_type IN ('CA Apparel',
							'CA Automotive',
							'CA BISS',
							'CA Baby',
							'CA Beauty',
							'CA Camera',
							'CA Consumer Electronics',
							'CA Furniture',
							'CA Grocery',
							'CA Health and Personal Care',
							'CA Home',
							'CA Home Entertainment',
							'CA Home Improvement',
							'CA Jewelry',
							'CA Kitchen',
							'CA Large Appliances',
							'CA Lawn and Garden',
							'CA Luggage',
							'CA Luxury Beauty',
							'CA Musical Instruments',
							'CA Office Products',
							'CA Outdoors',
							'CA Personal Care Appliances',
							'CA Personal Computer',
							'CA Pets',
							'CA Shoes',
							'CA Sporting Goods',
							'CA Tires',
							'CA Tools',
							'CA Toys',
							'CA Video Games',
							'CA Watches',
							'CA Wireless')

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


		--Pulling parent vendor codes
		parent_vc_match AS
		(SELECT *, 
		CASE WHEN a.parent_vendor_code = b.primary_vendor_code THEN 'TRUE' END AS vendor_filter
		FROM vendor_gl a
		LEFT JOIN vendor_filter b
		ON a.parent_vendor_code = b.primary_vendor_code
		),


		--Pulling child vendor codes
		child_vc_match AS
		(SELECT * ,
		CASE WHEN a.child_vendor_code = b.primary_vendor_code THEN 'TRUE' END AS vendor_filter
		FROM vendor_gl a
		LEFT JOIN vendor_filter b
		ON a.child_vendor_code = b.primary_vendor_code
		),


		--Union of list of parent & child vendor code
		vc_match_union AS
		(SELECT * FROM parent_vc_match WHERE vendor_filter = 'TRUE'
		UNION 
		SELECT * FROM child_vc_match WHERE vendor_filter = 'TRUE'
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
		pc_contacts AS
		(SELECT company_code
		 ,CASE
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
		-- , pmc.CSM
		FROM for_contacts fmc
		LEFT JOIN pc_contacts pmc
		ON fmc.company_codes = pmc.company_code
		 AND fmc.business_group_name = pmc.gl_product_groups
		),


		--Separating CSM data
		vendor_contacts_tag2 AS
		(SELECT company_code, CSM
		 FROM pc_contacts
		),


		--Joining VM & CSM data to the vendor codes
		final_contacts_tag AS
		(SELECT vmu.* ,
				pc.VM,
				vct.CSM
		 FROM vc_match_union vmu
		 LEFT JOIN vendor_contacts_tag pc
		 ON vmu.primary_vendor_code = pc.vendor_code
		 AND vmu.vendor_id = pc.vendor_id
		 LEFT JOIN vendor_contacts_tag2 vct
		 ON vmu.company_codes = vct.company_code
		),


		--Final extraction of data by combining above tables
		req_columns AS
		(SELECT x.company_name,	
				x.company_code,
				x.brand_name,
				x.gcor_id,
				x.is_rmb,
				x.account_type,
				x.parent_vendor_code,
				x.child_vendor_code,
				x.owning_gl,
				x.brand_owning_gl,
				x.primary_vendor_code,
				x.Vendor_Name,
				x.organization_tier,
				x.organization_owner,
				x.is_merchandise_ordering_active,
				x.is_dropship,
				x.vendor_id,
				x.brand_type,
				x.inventory_vendor_type_id,
				x.inventory_type,
				x.is_dropship_filter,	
				x.vendor_filter,
				x.VM,
				x.CSM
		FROM final_contacts_tag x
		GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
		),


		--Joining above two tables and grouping the data based on a condition
		final_output AS
		(
		SELECT a.SNAPSHOT_DAY, 
			   a.parent_brand,
			   a.gcor_id, 
			   a.brand_owning_gl,
			   a.gl_product_groups, 
			   a.head_item_gaps,
			   b.primary_vendor_code,
			   b.account_type,
			   b.company_code,
			   b.company_name, 
			   b.brand_type,
			   b.inventory_type,
			   b.VM,
			   b.CSM,
			   b.is_rmb,
			   CASE WHEN a.gl_product_groups = b.brand_type AND a.gcor_id = b.gcor_id THEN 'TRUE'
					WHEN a.gl_product_groups != b.brand_type AND a.gcor_id != b.gcor_id THEN 'FALSE'
					END AS GL_MATCHED
		FROM final_item_gap_view a
		LEFT JOIN req_columns b 
		ON a.gcor_id = b.gcor_id 
		GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
		)


--Final extraction of data from above tables and combining the temp table SME data
SELECT 
a.SNAPSHOT_DAY, 
a.parent_brand, 
a.gcor_id, 
a.brand_owning_gl, 
a.gl_product_groups, 
a.head_item_gaps, 
a.primary_vendor_code, 
a.account_type, 
a.company_code, 
a.company_name, 
a.brand_type, 
a.inventory_type, 
a.VM AS vendor_manager, 
a.CSM AS account_manager, 
a.GL_MATCHED, 
b.formatted_gls AS gl, 
b.product_family AS pf, 
b.vp, 
b.selection_sme
FROM final_output a
LEFT JOIN SME_DETAILS b 
ON a.gl_product_groups = b.formatted_gls
WHERE GL_MATCHED = 'TRUE'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19 ;
