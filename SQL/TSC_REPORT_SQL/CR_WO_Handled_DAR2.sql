SELECT 
a.createtitle_ as "Title", 
a.orderid as "TicketID", 
GET_DS_NAME(a.IMPLEMENTATIONTYPE_) as "ImplementationType",
GET_USERFULLNAME(a.wo005_user_wo005) as "Operator", 
to_char(CF_LOCAL_TIME(a.wo005_submit_wo005), 'YYYY-MM-DD HH24:MI:SS') as "OperationTime"
FROM tbl_wo_datasource a
WHERE a.fixedwireless_ = 'Wireless' 
AND get_assign_to(a.createassignto_) = 'TSC_TRANSPORT'
AND a.PARENTCRID_ IS NOT NULL
AND (
    a.createtitle_ NOT LIKE '%Protection Switching%'
    AND a.createtitle_ NOT LIKE '%Protection Switching%'
    AND a.createtitle_ NOT LIKE '%NMS Uploading and Remote%'
    AND a.createtitle_ NOT LIKE '%Low%'
    AND a.createtitle_ NOT LIKE '%TPE-AP%'
    AND a.createtitle_ NOT LIKE '%Link Utilization%'
    AND a.createtitle_ NOT LIKE '%Minor%'
    AND a.createtitle_ NOT LIKE '%Critical%'
    AND a.createtitle_ NOT LIKE '%Major%'
)
AND CF_LOCAL_TIME(a.wo005_submit_wo005) >= TO_DATE('{startDate}', 'YYYY-MM-DD HH24:MI:SS')
AND CF_LOCAL_TIME(a.wo005_submit_wo005) <= TO_DATE('{endDate}', 'YYYY-MM-DD HH24:MI:SS')