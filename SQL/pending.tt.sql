SELECT
a.orderid as "TicketID",
REPLACE(a.servicestatus, 'BusinessStatus') as "BusinessStatus",
a.title_ as "Title",
a.description_ as "Description",
a.area_ as "Area",
a.isassociated_ as "RelationshipType",
to_char(CF_LOCAL_TIME(a.faultlastoccurtime_), 'YYYY-MM-DD HH24:MI:SS') as "FaultLastOccurTime",
to_char(CF_LOCAL_TIME(a.faultrecoverytime_), 'YYYY-MM-DD HH24:MI:SS') as "FaultRecoveryTime",
a.siteid_ as "SiteID",
a.sitename_ as "SiteName",
a.alarmname_ as "AlarmName",
a.technology_ as "Technology",
a.band_ as "Band",
a.sitemaintainergroup_ as "SiteMaintainerGroup",
a.city_ as "City",
a.province_ as "Province",
GET_DS_NAME(a.causeofoutage_) as "CauseOfOutage",
GET_SEVERITY(a.currentseverity_) as "CurrentSeverity",
a.remarks_ as "Remarks"
FROM TBL_TROUBLETICKET_DATASOURCE a
WHERE  a.fixedwirelesscreate_='Wireless'
AND a.domain_ = 'RAN'
AND a.description_ like '%FULL OUTAGE%'
AND (a.faultrecoverytime_ is NULL or EXTRACT(YEAR from a.faultrecoverytime_) = 1970)
AND a.processstatus = 'running'