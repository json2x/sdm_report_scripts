SELECT 
a.createtitle_ as "Title", 
a.orderid as "TicketID", 
get_ds_name(a.operationmodeapprovecr_) as "Action", 
get_userfullname(a.cr004_user_cr004) as "Operator",
to_char(CF_LOCAL_TIME(a.cr004_submit_cr004), 'YYYY-MM-DD HH24:MI:SS') as "OperationTime"
FROM tbl_changerequest_datasource a
WHERE CF_LOCAL_TIME(a.cr004_submit_cr004) >= TO_DATE('{startDate}', 'YYYY-MM-DD HH24:MI:SS')
AND CF_LOCAL_TIME(a.cr004_submit_cr004) <= TO_DATE('{endDate}', 'YYYY-MM-DD HH24:MI:SS')
AND (
    get_userfullname(a.cr004_user_cr004) = 'Eduardo Soriano Billo' OR
    get_userfullname(a.cr004_user_cr004) = 'Maida Simbulan Tortona' OR
    get_userfullname(a.cr004_user_cr004) = 'Maria Sairah Cerbito Balang' OR
    get_userfullname(a.cr004_user_cr004) = 'Jave Aron V Magsanay' OR
    get_userfullname(a.cr004_user_cr004) = 'Jan Marloe P Natividad' OR
    get_userfullname(a.cr004_user_cr004) = 'Roy Anes Claron' OR
    get_userfullname(a.cr004_user_cr004) = 'Turiano Gerard Joseph R' OR
    get_userfullname(a.cr004_user_cr004) = 'Grandeur Macaballug Estera' OR
    get_userfullname(a.cr004_user_cr004) = 'Marlon San Juan Lopez' OR
    get_userfullname(a.cr004_user_cr004) = 'Jesus Buitizon Secretario' OR
    get_userfullname(a.cr004_user_cr004) = 'Edrian Alindogan Tubianosa' OR
    get_userfullname(a.cr004_user_cr004) = 'Richard Daymon Nayve' OR
    get_userfullname(a.cr004_user_cr004) = 'Marites Pagulayan Arao' OR
    get_userfullname(a.cr004_user_cr004) = 'John Lloyd Cagayan Torida' OR
    get_userfullname(a.cr004_user_cr004) = 'Raymond Alejo Fermin' OR
    get_userfullname(a.cr004_user_cr004) = 'Crepa Joanna Marie S' OR
    get_userfullname(a.cr004_user_cr004) = 'Esteban Joerge Adrian M' OR
    get_userfullname(a.cr004_user_cr004) = 'Gene Khyron Clamor' OR
    get_userfullname(a.cr004_user_cr004) = 'Zerina R Paras' OR
    get_userfullname(a.cr004_user_cr004) = 'Randy Battung Sibbaluca' OR
    get_userfullname(a.cr004_user_cr004) = 'Cathleen Kate Q Edora'
)