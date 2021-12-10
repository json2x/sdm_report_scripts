select wo.ORDERID,
       to_char(CAST(CF_LOCAL_TIME(tt.OPERATIONTIME) as DATE),'YYYY-MM-DD HH24:MI:SS') as ENDORSE_TIME,
       GET_USERGROUP(RTRIM(substr(tt.ASSIGNTO,11,1000),'"}')) as ASSIGN_TO
  from T_TICKET_TASK tt, 
       TBL_WO_DATASOURCE wo
where tt.TICKETID = wo.TICKETID
   and wo.ORDERID = '{ticketid}'
   and NODEID = 'WO005'
   and UPPER(GET_USERGROUP(RTRIM(substr(tt.ASSIGNTO,11,1000),'"}'))) like '%TSC_TRANSPORT%'
