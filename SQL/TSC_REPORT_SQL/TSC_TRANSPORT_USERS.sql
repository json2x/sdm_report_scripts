SELECT user_id, fullname, get_default_gorup(user_id) as "user_default_group" 
from v_um_user 
where active = 1 
and get_default_gorup(user_id) = 'TSC_TRANSPORT'