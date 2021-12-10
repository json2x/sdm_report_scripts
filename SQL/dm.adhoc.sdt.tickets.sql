SELECT 
t1.orderid as "ORDERID",
t1.createtitle_ as "CREATETITLE",
t1.servicestatus as "SERVICESTATUS",
t1.processstatus as "PROCESSSTATUS",
to_char(inoc_sdm_servicedesk_1.cf_local_time(t1.createtime),'YYYY-MM-DD HH24:MI:SS') as "CREATETIME",
to_char(inoc_sdm_servicedesk_1.cf_local_time(t1.lastupdatetime),'YYYY-MM-DD HH24:MI:SS') as "LASTUPDATETIME",
to_char(inoc_sdm_servicedesk_1.cf_local_time(t1.sdt005_submit_sdt005),'YYYY-MM-DD HH24:MI:SS') as "CLOSETIME",
t1.details_ as "DETAILS",
(select  LISTAGG(x.orderid, ',') WITHIN GROUP(ORDER BY t1.orderid) from inoc_sdm_servicedesk_1.tbl_wo_datasource x where t1.ticketid=x.parentticketid) as "SUBPROCESS_WO",
CASE 
    WHEN INSTR(t1.createassignto_, ';') > 0 THEN REPLACE(t1.createassignto_, 'group:', '') 
    ELSE inoc_sdm_servicedesk_1.get_assign_to(t1.createassignto_) 
END as "CREATEASSIGNTO",
CASE 
    WHEN INSTR(t1.transferto_, ';') > 0 THEN REPLACE(t1.transferto_, 'group:', '') 
    ELSE inoc_sdm_servicedesk_1.get_assign_to(t1.transferto_) 
END as "TRANSFERTO",
inoc_sdm_servicedesk_1.GET_C_PROCESSOR(t1.ticketid) as "CURRENTPROCESSOR",
inoc_sdm_servicedesk_1.get_userfullname(replace(t1.lastoperator, 'user:', '')) as "LASTOPERATOR",
inoc_sdm_servicedesk_1.get_userfullname(replace(t1.originator, 'user:', '')) as "ORIGINATOR",
t1.category_ as "CATEGORY",
t1.subcategory_ as "SUBCATEGORY",
t1.suplementaryinfo_ as "SUPLEMENTARYINFO",
t1.resolvesolutiondes_ as "RESOLVESOLUTION",
t1.closedescriptiona_ as "CLOSEDESCRIPTION",
t1.remarks_ as "REMARKS"
FROM TBL_SDT_DATASOURCE t1 WHERE t1.createassignto_ LIKE '%109487%' ORDER BY t1.createtime ASC