SELECT
a.orderid as "WO_TicketID",
a.CREATETITLE_ as "WO_Title",
a.processstatus  as "WO_Status",
replace(a.servicestatus, 'BusinessStatus', '')  as "WO_BusinessStatus",
GET_SEVERITY(a.FAULTSEVERITYLEVELWO_) as "Fault_Severity_Level",
to_char(inoc_sdm_servicedesk_1.CF_LOCAL_TIME(a.createtime),'YYYY-MM-DD HH24:MI:SS') as "WO_CreateTime",
to_char(inoc_sdm_servicedesk_1.CF_LOCAL_TIME(a.lastupdatetime),'YYYY-MM-DD HH24:MI:SS') as "WO_LastUpdateTime",
Null as "Aging (Hrs)",
inoc_sdm_servicedesk_1.get_default_gorup(a.wo002_user_wo002) as "WO_OriginatorGroup",
inoc_sdm_servicedesk_1.GET_USERGROUP(a.lastoperator) as "WO_LastOperator",
inoc_sdm_servicedesk_1.GET_C_PROCESSOR(a.ticketid) as "WO_CurrentProcessor",
Null as "WO_CurrentProcessorGroup",
a.domain_ as "Domain",
a.area_ as "Area",
a.region_ as "Region",
a.PARENTTICKETID,
a.PARENTORDERID_ as "TT_TicketID",

b.site_id as "SiteID",
b.site_name as "SiteName",
b.technology_ as "Technology",
b.issitedown_ as "SiteDown",
b.processstatus as "TT_TicketStatus",
to_char(inoc_sdm_servicedesk_1.CF_LOCAL_TIME(b.faultfirstoccurtime_),'YYYY-MM-DD HH24:MI:SS')  as "TT_FaultFirstOccurTime",
to_char(inoc_sdm_servicedesk_1.CF_LOCAL_TIME(b.faultrecoverytime_),'YYYY-MM-DD HH24:MI:SS')  as "TT_FaultRecoveryTime",
to_char(inoc_sdm_servicedesk_1.CF_LOCAL_TIME(b.lastupdatetime),'YYYY-MM-DD HH24:MI:SS') as "TT_LastUpdateTime",
b.alarmname_ as "TT_AlarmName",
to_char(inoc_sdm_servicedesk_1.CF_LOCAL_TIME(a.createtime),'YYYY') as "WO_CreateYear"

FROM TBL_WO_DATASOURCE a
LEFT JOIN TBL_TROUBLETICKET_DATASOURCE b ON a.PARENTORDERID_= b.ORDERID

WHERE  a.fixedwireless_ = 'Wireless'
and a.parentbpdtypeid = 'TroubleTicket'
and inoc_sdm_servicedesk_1.get_default_gorup(a.wo002_user_wo002) = 'NOC_NAC_NSC'
and a.processstatus =  'running'
and extract(YEAR from CF_LOCAL_TIME(a.createtime)) >= 2019