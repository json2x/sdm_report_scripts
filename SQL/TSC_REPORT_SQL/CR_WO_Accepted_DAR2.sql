SELECT 
a.createtitle_ as "Title", 
a.orderid as "TicketID", 
a.processstatus as "Status",
GET_USERFULLNAME(a.wo004_user_wo004) as "Operator", 
to_char(CF_LOCAL_TIME(a.wo004_submit_wo004), 'YYYY-MM-DD HH24:MI:SS') as "OperationTime"
FROM tbl_wo_datasource a
WHERE a.fixedwireless_ = 'Wireless' 
AND CF_LOCAL_TIME(a.wo004_submit_wo004) >= TO_DATE('{startDate}', 'YYYY-MM-DD HH24:MI:SS')
AND CF_LOCAL_TIME(a.wo004_submit_wo004) <= TO_DATE('{endDate}', 'YYYY-MM-DD HH24:MI:SS')
AND (
    get_userfullname(a.wo004_user_wo004) = 'Eduardo Soriano Billo' OR
    get_userfullname(a.wo004_user_wo004) = 'Maida Simbulan Tortona' OR
    get_userfullname(a.wo004_user_wo004) = 'Maria Sairah Cerbito Balang' OR
    get_userfullname(a.wo004_user_wo004) = 'Jave Aron V Magsanay' OR
    get_userfullname(a.wo004_user_wo004) = 'Jan Marloe P Natividad' OR
    get_userfullname(a.wo004_user_wo004) = 'Roy Anes Claron' OR
    get_userfullname(a.wo004_user_wo004) = 'Turiano Gerard Joseph R' OR
    get_userfullname(a.wo004_user_wo004) = 'Grandeur Macaballug Estera' OR
    get_userfullname(a.wo004_user_wo004) = 'Marlon San Juan Lopez' OR
    get_userfullname(a.wo004_user_wo004) = 'Jesus Buitizon Secretario' OR
    get_userfullname(a.wo004_user_wo004) = 'Edrian Alindogan Tubianosa' OR
    get_userfullname(a.wo004_user_wo004) = 'Richard Daymon Nayve' OR
    get_userfullname(a.wo004_user_wo004) = 'Marites Pagulayan Arao' OR
    get_userfullname(a.wo004_user_wo004) = 'John Lloyd Cagayan Torida' OR
    get_userfullname(a.wo004_user_wo004) = 'Raymond Alejo Fermin' OR
    get_userfullname(a.wo004_user_wo004) = 'Crepa Joanna Marie S' OR
    get_userfullname(a.wo004_user_wo004) = 'Esteban Joerge Adrian M' OR
    get_userfullname(a.wo004_user_wo004) = 'Gene Khyron Clamor' OR
    get_userfullname(a.wo004_user_wo004) = 'Zerina R Paras' OR
    get_userfullname(a.wo004_user_wo004) = 'Randy Battung Sibbaluca' OR
    get_userfullname(a.wo004_user_wo004) = 'Cathleen Kate Q Edora'
)