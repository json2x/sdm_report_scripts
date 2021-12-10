#!/usr/bin/env /home/jcm/env/sdmreports/bin/python

import os, glob, sys, re, time
from mydataframe import dataframe
from oracle import Oracle
from database import database
from datetime import datetime, timedelta
from sqlalchemy import create_engine
import paramiko

APP_ROOT_DIR = '/home/jcm/projects/SDMReports'
OUTPUT_DIR = ''
DB = {
	'OVIM': {'Host': '10.150.20.102', 'User': 'ovimadmin', 'Password': '0vimadmin!', 'Database': 'sdm_reports', 'Port': '3306'},
	'SDM': {'Host': '10.150.6.23', 'User': 'inoc_sdm_servicedesk_1', 'Password': 'DB_Service_!23', 'Database': 'sdm', 'Port': '1550'},
}
#---------------------------
def main():
	asof_dt = time.strftime("%Y-%m-%d")
	sdmTT = dataframe()
	oracle = Oracle()
	renameCols = {
		'Parent Ticket ID': 'parent_ticket_id',
		'Ticket ID': 'ticket_id',
		'Site ID': 'site_id',
		'Site Name': 'site_name',
		'Domain': 'domain',
		'Technology': 'technology',
		'Band': 'band',
		'Device': 'device',
		'Device Owner': 'device_owner',
		'City': 'city',
		'Province': 'province',
		'Area': 'area',
		'Service Affecting': 'service_affecting',
		'Site Down': 'site_down',
		'Cause of Outage': 'cause_of_outage',
		'Sub Cause 1': 'sub_cause_1',
		'Sub Cause 2': 'sub_cause_2',
		'Sub Cause 3': 'sub_cause_3',
		'Ticket Status': 'ticket_status',
		'SubProcessWO': 'subprocess_wo',
		'SubProcessWO_Status': 'subprocess_wo_status',
		'SubProcessWO_CurrentProcessor': 'subprocess_wo_currentprocessor',
		'Ticket Created Time': 'ticket_created_time',
		'Fault First Occur Time': 'fault_first_occur_time',
		'Fault Recovery Time': 'fault_recovery_time',
		'Assign To': 'assign_to',
		'TT_CurrentProcessor': 'tt_currentprocessor',
		'Relationship Type': 'relationship_type',
		'AsOf': 'asof'
	}
	
	try:
		
		print('Connecting to SDM Database...')
		oracle.connect(DB['SDM']['User'], DB['SDM']['Password'], DB['SDM']['Host'], DB['SDM']['Port'], DB['SDM']['Database'])
		
		if oracle.connection:
			print('Connection Successful!')
			
			#get sql query and store in variable
			with open(APP_ROOT_DIR + '/SQL/sdm.tt.with.frt.no.coo.sql', 'r') as myfile:
				sql=myfile.read()
			print('Querying database and storing result to dataframe...', end="", flush=True)
			sdmTT.createSQLResultDataframe(sql, oracle.db)
			print('[OK]')
			print('Adding as of date...', end="", flush=True)
			sdmTT.df['AsOf'] = asof_dt
			print('[OK]')
			oracle.disconnect()
			
			filename = 'SDM-TT-WITH-FRT-NO-COO.xlsx'
			print('Writing DataFrame to Excel...', end="", flush=True)
			sdmTT.df.to_excel(APP_ROOT_DIR + '/' + filename, sheet_name="Export Worksheet", index=False)
			print('[OK]')
			
			print('Sending File to SMBNOC ftp directory...')
			SendFile(APP_ROOT_DIR + '/' + filename)
			
			#Store to local database
			print('Storing data to OVIM Database.', end="", flush=True)
			sdmTT.setColsToRename(renameCols)
			sdmTT.renameCols()
			sdmTT.df.fillna('')
			
			sqlEngine = create_engine('mysql+mysqldb://ovimadmin:0vimadmin!@10.150.20.102:3306/sdm_reports')
			sdmTT.df.to_sql(name='tt_wfrt_no_coo', con=sqlEngine, if_exists = 'append', index=False)
			print('[OK]')
		else:
			print('Connection Failed!')
			
	except:
		exc_type, exc_obj, exc_tb = sys.exc_info()
		print("{}: {}".format(exc_type, exc_obj))
		print('Script terminated.')
	
#--- --- ---
# Sending file via paramiko sftp
#--- --- ---
def SendFile(localFilename):
	remoteFilename = "SDM-TT-WITH-FRT-NO-COO_{}.xlsx".format(time.strftime("%Y-%m-%d"))
	SERVER_ADDRESS = ['10.150.20.104']
	SERVER_UNAME = 'smbnoc'
	SERVER_PSWD = 'smbnoc'
	SERVER_DIR = 'TT_WITH_FRT_NO_COO' 
	#'SDM_REPORTS/TT_WITH_FRT_NO_COO'
	print("")
	print('Preparing to send file to NOC SDM reports repository.')
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
	print("SDM TT WITH FRT NO COO")
	print("-------------------------")
	
	main()
	
	endTime = datetime.now()
	deltaDt = endTime - starTime
	print(deltaDt)
	print("<<<<< End of Script >>>>>")
