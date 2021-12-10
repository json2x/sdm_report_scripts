select wo.ORDERID,
       to_char(CAST(CF_LOCAL_TIME(tt.OPERATIONTIME) as DATE),'DD-MON-YYYY HH24:MI:SS') as ENDORSE_TIME,
       (CASE WHEN tt.NODEID = 'WO002' THEN 'Create WO' 
             WHEN tt.NODEID = 'WO004' THEN 'Handle WO'
             WHEN tt.NODEID = 'WO005' THEN 'Process WO'
             ELSE 'Confirm WO'
        END) as PHASE,
		GET_USERFULLNAME(tt.OPERATOR) as PROCESSOR,
		GET_USERGROUP(RTRIM(substr(tt.ASSIGNTO,11,1000),'"}')) as ASSIGN_TO,
		wo.processdesct_ as PROCESSREMARKS
  from T_TICKET_TASK tt, 
       TBL_WO_DATASOURCE wo
where tt.TICKETID = wo.TICKETID
   and wo.ORDERID IN ({ticketid})
   and tt.NODEID in ('WO002','WO004','WO005')
   and UPPER(GET_USERGROUP(RTRIM(substr(tt.ASSIGNTO,11,1000),'"}'))) like '%TSC_TRANSPORT%'