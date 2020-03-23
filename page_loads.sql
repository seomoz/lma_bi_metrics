/* Grab users and page loads for LMA */
SELECT
	p.user_id
	, u.email
--	, anonymous_id
	, min(trunc(p.received_at)) AS first_visit
	, max(trunc(p.received_at)) AS last_visit
	, max(trunc(p.received_at)) - min(trunc(p.received_at)) AS total_lifetime
	, count(*) AS page_loads
FROM mozdotcom_prod_client.pages AS p
INNER JOIN mozro.users_curr AS u
ON p.user_id = u.user_id
WHERE 1=1
AND p.path like '/pro/local-market-analytics%'
AND p.received_at >= '2019-10-01'
AND lower(u.email) NOT LIKE '%@moz.com'
GROUP BY p.user_id, u.email
ORDER BY page_loads DESC;
