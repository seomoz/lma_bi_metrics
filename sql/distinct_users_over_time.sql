/* LMA metrics for team leads */


/* Get distinct users over time */
SELECT
	TRUNC(received_at) AS dt
	, COUNT(DISTINCT anonymous_id) AS distinct_anon_ids
	, COUNT(DISTINCT user_id) AS distinct_users
FROM mozdotcom_prod_client.pages AS p
WHERE 1=1
/* After LMA launch */
AND RECEIVED_AT >= '2019-10-20'
AND url LIKE '%/pro/local-market-analytics%'
GROUP BY 1
ORDER BY 1;
