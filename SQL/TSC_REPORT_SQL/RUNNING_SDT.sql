SELECT 
a.createtitle_ as "Title", 
a.orderid as "TicketID", 
a.processstatus as "TicketStatus",
REPLACE(a.servicestatus, 'BusinessStatus', '') as "BusinessStatus",
GET_C_PROCESSOR(a.ticketid) as "ProcessBy",
get_userfullname(a.sdt001_user_sdt001) as "CreatedBy",
to_char(cf_local_time(a.createtime),'YYYY-MM-DD HH24:MI:SS') as "CreateTime"
FROM tbl_sdt_datasource a
WHERE a.processstatus = 'running'
AND GET_C_PROCESSOR(a.ticketid) LIKE '%TSC_TRANSPORT%'