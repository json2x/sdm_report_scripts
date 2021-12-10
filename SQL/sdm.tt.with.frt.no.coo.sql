select
(select distinct v.orderid from v_ttreport_ticketid v 
where tm.sourceticketid=v.ticketid and t.ticketid=tm.associateticketid) as "Parent Ticket ID",
t.orderid as "Ticket ID",
(case  
    when t.siteid_ like '%A1%' then (select site_id from t_syc_site where t.siteid_=id and active=1 )
    when t.site_ like '%A1%' then (select site_id from t_syc_site where t.site_=id and active=1)
    when t.siteid_ is null then t.site_
    else t.siteid_ 
end)  as "Site ID",
NVL(sitenametest_,'-') as "Site Name",
NVL(Domain_,'-') as "Domain",
NVL(TECHNOLOGY_,'-') as "Technology",
NVL(BAND_,'-') as "Band",
NVL(deviceid_,'-') as "Device",
NVL(SITEMAINTAINERGROUP_,'-') as "Device Owner",
NVL(CITY_,'-') as "City",
(SELECT distinct PROVINCE_NAME FROM T_SYC_SITE S WHERE (S.Site_Id=T.SITEID_ or s.site_id=t.site_)  and active=1)  as "Province",
NVL(AREA_,'-') as "Area",
NVL(replace(initialserviceaffectingne_,'TTAffectedService'),'A100000029') as "Service Affecting", 
replace(NVL(ISSITEDOWN_,'-'),'is') as "Site Down",
t.causeofoutage_ as "Cause of Outage",
t.subcauseone_ as "Sub Cause 1",
t.Subcausetwo_ as "Sub Cause 2",
t.subcausethree_ as "Sub Cause 3",
replace(NVL(servicestatus,'-'),'BusinessStatus') as "Ticket Status",
(select  LISTAGG(c.orderid, ',') WITHIN GROUP(ORDER BY t.orderid) from tbl_wo_datasource c where t.ticketid=c.parentticketid) as "SubProcessWO",
(select  LISTAGG(c.processstatus, ',') WITHIN GROUP(ORDER BY t.processstatus) from tbl_wo_datasource c where t.ticketid=c.parentticketid) as "SubProcessWO_Status",
(select  LISTAGG(GET_C_PROCESSOR(c.ticketid), ',') WITHIN GROUP(ORDER BY GET_C_PROCESSOR(c.ticketid)) from tbl_wo_datasource c where t.ticketid=c.parentticketid) as "SubProcessWO_CurrentProcessor",
to_char(CF_LOCAL_TIME(createtime),'YYYY-MM-DD HH24:MI:SS') as "Ticket Created Time",
to_char(CF_LOCAL_TIME(FAULTFIRSTOCCURTIME_),'YYYY-MM-DD HH24:MI:SS') as "Fault First Occur Time",
to_char(CF_LOCAL_TIME(FAULTRECOVERYTIME_),'YYYY-MM-DD HH24:MI:SS') as "Fault Recovery Time",

get_assign_to(t.assignto_) "Assign To",
GET_C_PROCESSOR(t.ticketid) as "TT_CurrentProcessor",
(case when isassociated_ is null then 'NA' else isassociated_ end) as "Relationship Type" 

from tbl_troubleticket_datasource t left join t_ticket_associate  tm
on tm.associateticketid=t.ticketid  
where  t.fixedwirelesscreate_='Wireless'
and (servicestatus != 'BusinessStatusCompleted' AND servicestatus != 'BusinessStatusClosed' AND servicestatus != 'BusinessStatusCancel')
and (FAULTRECOVERYTIME_ is not NULL  OR extract(YEAR from CF_LOCAL_TIME(FAULTRECOVERYTIME_)) != 1970)
and extract(YEAR from CF_LOCAL_TIME(FAULTFIRSTOCCURTIME_)) >= 2019
and (t.causeofoutage_ is NULL or t.subcauseone_ is NULL)
ORDER BY "Ticket ID" ASC