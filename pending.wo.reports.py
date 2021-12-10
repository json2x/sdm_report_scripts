#!/usr/bin/env /home/jcm/env/sdmreports/bin/python

import os, glob, sys, re, time
from mydataframe import dataframe
from oracle import Oracle
from datetime import datetime, timedelta
import paramiko

APP_ROOT_DIR = '/home/jcm/projects/SDMReports'

#---------------------------
def main():
	
	ttwo = dataframe()
	userGrp = dataframe()
	oracle = Oracle()
	
	print('Connecting to SDM Database...')
	oracle.connect('inoc_sdm_servicedesk_1', 'DB_Service_!23', '10.150.6.23', '1550', 'sdm')
	if oracle.connection:
		print('Connection Successful!')
		
		#get sql query and store in variable
		with open(APP_ROOT_DIR + '/SQL/pending.tt.wos.sql', 'r') as myfile:
			sql=myfile.read()
		ttwo.createSQLResultDataframe(sql, oracle.db)
		
		#query = 'SELECT user_id, fullname, inoc_sdm_servicedesk_1.get_default_gorup(user_id) as "user_default_group" \
		#from v_um_user where active = 1 and inoc_sdm_servicedesk_1.get_default_gorup(user_id) is not null'
		query = 'SELECT user_id, fullname, get_default_gorup(user_id) as "user_default_group" from v_um_user where active = 1 and get_default_gorup(user_id) is not null'
		userGrp.createSQLResultDataframe(query, oracle.db)
		#print(userGrp.error)
		
		#wo.df['Aging'] = datetime.today() - wo.pd.to_datetime(wo.df['WO_CreateTime'], format='%Y-%m-%d %H:%M:%S')
		if not ttwo.df.empty and not userGrp.df.empty:
			for i, row in ttwo.df.iterrows():
				ttwo.df.at[i, "Aging"] = computeDuration(row)
				if ttwo.pd.isnull(row['TT_TicketID']):
					#If TT_TicketID is empty, check query back to db its TT_TicketID(Orderid) using the parentticketid field.
					ttwo.df.at[i, "TT_TicketID"] = get_tt_orderid(row['PARENTTICKETID'], oracle.db)
				
				current_processor = str(row['WO_CurrentProcessor'])
				if current_processor.find(';') !=- 1:
					proccessors = row['WO_CurrentProcessor'].split(';')
					ttwo.df.at[i, "WO_CurrentProcessorGroup"] = get_user_defaultgroup(proccessors[0], userGrp.df)
				else:
					ttwo.df.at[i, "WO_CurrentProcessorGroup"] = get_user_defaultgroup(row['WO_CurrentProcessor'], userGrp.df)
					
			#ttwo.df = ttwo.df.merge(userGrp.df, on='WO_CurrentProcessor', how='left')
			#ttwo.df['WO_CurrentProcessorGroup'] = ttwo.df['GROUPNAME']
			#ttwo.df = ttwo.df.drop(columns=['GROUPNAME','PARENTTICKETID'])
			ttwo.df = ttwo.df.drop(columns=['PARENTTICKETID'])
			
			print('Writing DataFrame to CSV.')
			ttwo.df.to_csv(APP_ROOT_DIR + '/output.csv', index=False)
			
			SendFile(APP_ROOT_DIR + '/output.csv')
		else:
			print('Either or both dataframe is empty. Can not proceed with processing.')
			print('Script will terminate.')
			
		oracle.disconnect()
	else:
		print('Connection Failed!')
		
#---------------------------------------
def computeDuration(dfRow):
		duration = None
		
		deltaDt = datetime.today() - datetime.strptime(dfRow['WO_CreateTime'] ,"%Y-%m-%d %H:%M:%S")
		duration = strfdelta(deltaDt, "{days} days {hours}:{minutes}")
			
		return duration

#---------------------------------------		
def get_tt_orderid(ticketid, db):
	#If TT_TicketID is empty, check query back to db its TT_TicketID(Orderid) using the parentticketid field.
	cur = db.cursor()
	cur.execute('SELECT orderid FROM tbl_troubleticket_datasource WHERE ticketid = {}'.format(ticketid))
	results = cur.fetchall()
	TT_TicketID = ''
	for result in results:
		if not TT_TicketID:
			TT_TicketID = result[0]
		else:
			TT_TicketID = ';{}'.format(result[0])
	
	return TT_TicketID

#---------------------------------------	
def get_user_defaultgroup(user, userGrpDf):
	resultDf = userGrpDf[(userGrpDf['FULLNAME']==user)]
	group = 'NA'
	if not resultDf.empty:
		for i, row in resultDf.iterrows():
			group = row['user_default_group']
			break
	else:
		resultDf = userGrpDf[(userGrpDf['user_default_group']==user)]
		if not resultDf.empty:
			group = user
			
	return group
	
#---------------------------------------
def strfdelta(deltaDt, format):
	d = {"days": deltaDt.days}
	d['hours'], rem = divmod(deltaDt.seconds, 3600)
	d['minutes'], d['seconds'] = divmod(rem, 60)
	
	d['hours'] = '{:02d}'.format(d['hours'])
	d['minutes'] = '{:02d}'.format(d['minutes'])
	d['seconds'] = '{:02d}'.format(d['seconds'])
	
	return format.format(**d)
	
#--- --- ---
# Sending file via paramiko sftp
#--- --- ---
def SendFile(localFilename):
	remoteFilename = "PENDING_WOs_" + time.strftime("%Y%m%d") + ".csv"
	SERVER_ADDRESS = ['10.150.20.104']
	SERVER_UNAME = 'smbnoc'
	SERVER_PSWD = 'smbnoc'
	SERVER_DIR = 'PENDING_TT-WOs' 
	#'SDM_REPORTS/PENDING_TT-WOs'
	print("")
	print('Preparing to send file to Proj USA Datahub dump directory.')
	print('     {}'.format(localFilename))
	
	for ServerIP in SERVER_ADDRESS:
		try:
			print('Connecting to host: {} ... '.format(ServerIP), end="")
			t = paramiko.Transport((ServerIP, 22))
			t.connect(username=SERVER_UNAME, password=SERVER_PSWD)
			sftp = paramiko.SFTPClient.from_transport(t)
			sftp.chdir(SERVER_DIR)
			print('[OK]')
			
			print('Transferring {} to server... '.format(localFilename), end="")
			sftp.put(localFilename, remoteFilename)
			print('[OK]')
			
			print("")
			print("-- FILE SENT ---")
			print("")
			
			sftp.close()
		except Exception as e:
			print('[FAIL]')
			print('*** Caught exception: %s: %s' % (e.__class__, e))
				
		finally:
			t.close()

#---------------------------
if __name__ == "__main__":
	starTime = datetime.now()
	print("\nRun Datetime: {}".format(starTime))
	print("-------------------------")
	print("SDM Reports")
	print("Pending/Running TT-WOs")
	print("-------------------------")
	
	main()
	
	endTime = datetime.now()
	deltaDt = endTime - starTime
	print(deltaDt)
	print("<<<<< End of Script >>>>>")
