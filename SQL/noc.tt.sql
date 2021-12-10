SELECT
(SELECT DISTINCT v.orderid FROM v_ttreport_ticketid v WHERE tm.sourceticketid=v.ticketid AND tt.ticketid=tm.associateticketid) as "ParentTicketID",
tt.orderid as "TicketID",
(select  LISTAGG(c.orderid, ',') WITHIN GROUP(ORDER BY tt.orderid) from tbl_wo_datasource c where tt.ticketid=c.parentticketid) as "SubProcessWO",
tt.processstatus as "ProcessStatus",
REPLACE(tt.servicestatus, 'BusinessStatus') as "BusinessStatus",
tt.title_ as "Title",
tt.description_ as "Description",
tt.area_ as "Area",
tt.isassociated_ as "RelationshipType",
get_userfullname(REPLACE(tt.originator, 'user:', '')) as "CreatedBy",
to_char(CF_LOCAL_TIME(tt.createtime),'YYYY-MM-DD HH24:MI:SS') as "TicketCreatedTime",
to_char(CF_LOCAL_TIME(tt.FAULTFIRSTOCCURTIME_),'YYYY-MM-DD HH24:MI:SS') as "Fault First Occur Time",
to_char(CF_LOCAL_TIME(tt.faultlastoccurtime_), 'YYYY-MM-DD HH24:MI:SS') as "FaultLastOccurTime",
to_char(CF_LOCAL_TIME(tt.faultrecoverytime_), 'YYYY-MM-DD HH24:MI:SS') as "FaultRecoveryTime",
tt.siteid_ as "SiteID",
tt.sitename_ as "SiteName",
tt.alarmname_ as "AlarmName",
tt.technology_ as "Technology",
tt.band_ as "Band",
tt.sitemaintainergroup_ as "SiteMaintainerGroup",
tt.city_ as "City",
tt.province_ as "Province",
GET_DS_NAME(tt.causeofoutage_) as "CauseOfOutage",
tt.subcauseone_ as "SubCause1",
tt.Subcausetwo_ as "SubCause2",
GET_SEVERITY(tt.currentseverity_) as "CurrentSeverity",
tt.remarks_ as "Remarks"

FROM TBL_TROUBLETICKET_DATASOURCE tt
LEFT JOIN T_TICKET_ASSOCIATE tm
	ON tm.associateticketid=tt.ticketid

WHERE  tt.fixedwirelesscreate_='Wireless'
AND
(
    (CF_LOCAL_TIME(tt.FAULTFIRSTOCCURTIME_) <= TO_DATE('{end_date}', 'YYYY-MM-DD HH24:MI:SS')
    and
    CF_LOCAL_TIME(tt.FAULTRECOVERYTIME_) >= TO_DATE('{start_date}', 'YYYY-MM-DD HH24:MI:SS'))
OR
    (CF_LOCAL_TIME(tt.FAULTRECOVERYTIME_) is null or EXTRACT(YEAR from tt.faultrecoverytime_) = 1970)
)
ORDER BY "TicketID" ASC