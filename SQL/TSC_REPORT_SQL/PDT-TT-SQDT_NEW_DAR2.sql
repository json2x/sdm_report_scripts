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
AND CF_LOCAL_TIME(a.wo005_submit_wo005) >= TO_DATE('{startDate}', 'YYYY-MM-DD HH24:MI:SS')
AND CF_LOCAL_TIME(a.wo005_submit_wo005) <= TO_DATE('{endDate}', 'YYYY-MM-DD HH24:MI:SS')
AND (
    get_userfullname(a.wo005_user_wo005) = 'Eduardo Soriano Billo' OR
    get_userfullname(a.wo005_user_wo005) = 'Maida Simbulan Tortona' OR
    get_userfullname(a.wo005_user_wo005) = 'Maria Sairah Cerbito Balang' OR
    get_userfullname(a.wo005_user_wo005) = 'Jave Aron V Magsanay' OR
    get_userfullname(a.wo005_user_wo005) = 'Jan Marloe P Natividad' OR
    get_userfullname(a.wo005_user_wo005) = 'Roy Anes Claron' OR
    get_userfullname(a.wo005_user_wo005) = 'Turiano Gerard Joseph R' OR
    get_userfullname(a.wo005_user_wo005) = 'Grandeur Macaballug Estera' OR
    get_userfullname(a.wo005_user_wo005) = 'Marlon San Juan Lopez' OR
    get_userfullname(a.wo005_user_wo005) = 'Jesus Buitizon Secretario' OR
    get_userfullname(a.wo005_user_wo005) = 'Edrian Alindogan Tubianosa' OR
    get_userfullname(a.wo005_user_wo005) = 'Richard Daymon Nayve' OR
    get_userfullname(a.wo005_user_wo005) = 'Marites Pagulayan Arao' OR
    get_userfullname(a.wo005_user_wo005) = 'John Lloyd Cagayan Torida' OR
    get_userfullname(a.wo005_user_wo005) = 'Raymond Alejo Fermin' OR
    get_userfullname(a.wo005_user_wo005) = 'Crepa Joanna Marie S' OR
    get_userfullname(a.wo005_user_wo005) = 'Esteban Joerge Adrian M' OR
    get_userfullname(a.wo005_user_wo005) = 'Gene Khyron Clamor' OR
    get_userfullname(a.wo005_user_wo005) = 'Zerina R Paras' OR
    get_userfullname(a.wo005_user_wo005) = 'Randy Battung Sibbaluca' OR
    get_userfullname(a.wo005_user_wo005) = 'Cathleen Kate Q Edora'
)