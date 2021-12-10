SELECT 
a.parentbpdtypeid as "Workflow",
/*CASE 
    WHEN a.parentbpdtypeid IS NOT NULL THEN a.parentbpdtypeid 
    ELSE  (CASE WHEN a.PARENTCRID_ IS NOT NULL THEN 'ChangeRequest' ELSE NULL END) 
END as "Workflow",*/
a.createtitle_ as "Title", 
a.orderid as "TicketID",
a.processstatus as "Status",
GET_USERFULLNAME(a.wo005_user_wo005) as "Operator",
REPLACE(a.processoptmode_, 'ProcessWOOptMode', '') as "Action",
CASE 
    WHEN a.parentorderid_ IS NOT NULL THEN a.parentorderid_ 
    ELSE b.orderid
END as "ParentTicket"
FROM tbl_wo_datasource a
LEFT JOIN tbl_troubleticket_datasource b ON b.ticketid = a.parentticketid
WHERE a.fixedwireless_ = 'Wireless' 
AND a.parentbpdtypeid IS NOT NULL
AND CF_LOCAL_TIME(a.finishtime_) <= TO_DATE('2030-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
AND 
    (a.createtitle_ LIKE '%Low%' OR
    a.createtitle_ LIKE '%Major%' OR
    a.createtitle_ LIKE '%Critical%' OR
    a.createtitle_ LIKE '%Link Utilization%' OR
    a.createtitle_ LIKE '%Others%' OR
    a.createtitle_ LIKE '%Requests%' OR
    a.createtitle_ LIKE '%NOC Assistance%' OR
    a.createtitle_ LIKE '%Minor%' OR
    a.createtitle_ LIKE '%Moderate%' OR
    a.createtitle_ LIKE '%Alarm Clearing%' OR
    a.createtitle_ LIKE '%Complaint%')
AND
    (a.createtitle_ NOT LIKE '%lower%' AND
    a.createtitle_ NOT LIKE '%TSC_%'
    )
AND GET_C_PROCESSOR(a.ticketid) LIKE '%TSC_TRANSPORT%'