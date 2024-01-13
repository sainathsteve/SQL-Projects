--Extraction and organizing of data

WITH 
	brand_coverage_details AS
	(SELECT 
		a.brand_name,
		a.SNAPSHOT_DAY,
		a.gcor_id,
		a.marketplace_id,
		a.brand_type,
		CAST(COUNT(DISTINCT CASE WHEN IS_HEAD_SELECTION ='Y' OR IS_HEAD_SELECTION ='N' THEN a.SMT_ITEM_ID END) as DECIMAL(10, 0)) AS TOTAL_KNOWN_UNIVERSE,
		CAST(COUNT(DISTINCT CASE WHEN IS_HEAD_SELECTION ='Y' THEN a.SMT_ITEM_ID END) as DECIMAL(10, 0)) AS HS_KNOWN_UNIVERSE,
		CAST(COUNT(DISTINCT CASE WHEN UPPER(a.BUCKET)  =  'RETAIL' THEN a.SMT_ITEM_ID END) as DECIMAL(10, 0)) AS TOTAL_OVERLAPS,
		CAST(COUNT(DISTINCT CASE WHEN UPPER(a.BUCKET)  =  'RETAIL' AND IS_HEAD_SELECTION ='Y' THEN a.SMT_ITEM_ID END) as DECIMAL(10, 0)) AS HS_OVERLAPS,
		CAST(COUNT(DISTINCT CASE WHEN UPPER(a.BUCKET)  != 'RETAIL' THEN a.SMT_ITEM_ID END) as DECIMAL(10, 0))AS TOTAL_GAPS,
		CAST(COUNT(DISTINCT CASE WHEN UPPER(a.BUCKET)  != 'RETAIL' AND IS_HEAD_SELECTION ='Y' THEN a.SMT_ITEM_ID END) as DECIMAL(10, 0)) AS HS_GAPS 
	FROM table1 a
	WHERE   
		a.IS_INVALID = 'N'
		AND a.SNAPSHOT_DAY = CAST(DATE_TRUNC('MONTH', CURRENT_DATE)-INTERVAL '1 day' as date)
		AND program_code != 'Unique'
		AND a.MARKETPLACE_ID = 7
	GROUP BY a.brand_name,
			 a.SNAPSHOT_DAY,
			 a.marketplace_id,
			 a.brand_type,
			 a.gcor_id),
				 
	   
	--Grouped the prev extracted data records further   
	BUCKET AS 
	(
	SELECT brand_name,
		   gcor_id,
		   SNAPSHOT_DAY,
		   marketplace_id,
		   brand_type,
		   TOTAL_KNOWN_UNIVERSE,
		   HS_KNOWN_UNIVERSE,
		   TOTAL_OVERLAPS,
		   HS_OVERLAPS,
		   TOTAL_GAPS,
		   HS_GAPS,
		   CASE
				WHEN TOTAL_KNOWN_UNIVERSE = 0 THEN 0
				ELSE CAST((TOTAL_OVERLAPS/TOTAL_KNOWN_UNIVERSE) *100 as DECIMAL(10, 2)) 
				END AS Selection_coverage, 
		   CASE 
				WHEN HS_KNOWN_UNIVERSE = 0 THEN 0
				ELSE CAST((HS_OVERLAPS/HS_KNOWN_UNIVERSE * 100) as DECIMAL(10, 2))
				END AS Head_coverage, 
		   
		   CASE WHEN Head_coverage <= 59.99 THEN '<60%' 
				WHEN Head_coverage >= 60 AND Head_coverage <=84.99 THEN '60% to 85%'
				WHEN Head_coverage >= 85 THEN '>85%' 
				END AS Head_Bucket
	FROM brand_coverage_details 
	),


	--Extracting data from RMC_RMB table
	brand_owning AS 
	(
	SELECT
	y.gcor_id AS GCOR_ID_1,
	y.gcor_primary_gl AS brand_owning_gl,
	y.gcor_primary_pf AS brand_pf,
	y.marketplace_id AS MP_ID,
	y.SNAPSHOT_DATE
	FROM table2 y
	WHERE y.SNAPSHOT_DATE = CAST(DATE_TRUNC('MONTH', CURRENT_DATE)-INTERVAL '1 day' as date)
	AND y.marketplace_id = 7
	GROUP BY 1,2,3,4,5
	)


--Final extraction of data by combining above 2 tables
SELECT 
a.brand_name,
a.SNAPSHOT_DAY,
a.gcor_id,
a.marketplace_id,
a.brand_type,
a.TOTAL_KNOWN_UNIVERSE,
a.HS_KNOWN_UNIVERSE,
a.TOTAL_OVERLAPS,
a.HS_OVERLAPS,
a.TOTAL_GAPS,
a.HS_GAPS,
a.Selection_coverage,
a.Head_coverage,
b.GCOR_ID_1,
b.brand_owning_gl,
b.brand_pf,
b.MP_ID,
b.SNAPSHOT_DATE,
a.Head_Bucket
FROM BUCKET a
LEFT JOIN brand_owning b
ON a.marketplace_id = b.MP_ID
AND a.SNAPSHOT_DAY = b.SNAPSHOT_DATE
AND a.gcor_id = b.GCOR_ID_1;