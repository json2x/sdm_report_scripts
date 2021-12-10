#!/usr/bin/env /home/jcm/env/sdmreports/bin/python

import os, glob, sys, re, time
from mydataframe import dataframe
from oracle import Oracle
from datetime import datetime, timedelta
import paramiko

APP_ROOT_DIR = '/home/jcm/projects/SDMReports'
OUTPUT_DIR = '/home/jcm/mnt/DM_ADHOC_TEAM/REPORTS'

#---------------------------
def main():
	
	sdt = dataframe()
	sdmGrps = dataframe()
	sdmUsrDefGrp = dataframe()
	oracle = Oracle()
	
	print('Connecting to SDM Database...')
	oracle.connect('inoc_sdm_servicedesk_1', 'DB_Service_!23', '10.150.6.23', '1550', 'sdm')
	
	sdmGrps = getSDMGroups(sdmGrps, oracle.db)
	sdmUsrDefGrp = getSDMUsersAndDefaultGroups(sdmUsrDefGrp, oracle.db)
	
	if oracle.connection:
		print('Connection Successful!')
		
		#get sql query and store in variable
		with open(APP_ROOT_DIR + '/SQL/dm.adhoc.sdt.tickets.sql', 'r') as myfile:
			sql=myfile.read()
		sdt.createSQLResultDataframe(sql, oracle.db)
		
		for i, row in sdt.df.iterrows():
			#processing of result rows
			assign_to = str(row['CREATEASSIGNTO'])
			if assign_to.find(';') != -1:
				sdt.df.at[i, "CREATEASSIGNTO"] = get_groupnames_or_username(assign_to, sdmGrps.df, sdmUsrDefGrp.df)
				
			transfer_to = str(row['TRANSFERTO'])
			if transfer_to.find(';') != -1:
				transfer_to = transfer_to.replace('user:', '')
				transfer_to = transfer_to.replace('group:', '')
				sdt.df.at[i, "TRANSFERTO"] = get_groupnames_or_username(transfer_to, sdmGrps.df, sdmUsrDefGrp.df)
		
		print('Writing DataFrame to CSV.')
		
		#sdt.df.to_csv(APP_ROOT_DIR + '/output-sdt-dmadhoc.csv', index=False)
		sdt.df.to_csv(OUTPUT_DIR + '/DM-ADHOC_SDT' + time.strftime("%Y%m%d") + ".csv", index=False)
		#SendFile(APP_ROOT_DIR + '/output-sdt-dmadhoc.csv', 'DM-ADHOC_SDT', '/data/ovimdir/ovim/TCM/DM_ADHOC_TEAM/REPORTS')
		
		oracle.disconnect()
	else:
		print('Connection Failed!')
		
#---------------------------------------
def getSDMGroups(dfObj, dBCon):
	query = 'SELECT * FROM V_UM_GROUP WHERE ACTIVE = 1'
	dfObj.createSQLResultDataframe(query, dBCon)
	
	return dfObj
	
#---------------------------------------
def getSDMUsersAndDefaultGroups(dfObj, dBCon):
	query = 'SELECT user_id, fullname, inoc_sdm_servicedesk_1.get_default_gorup(user_id) as "user_default_group" \
		from v_um_user where active = 1 and inoc_sdm_servicedesk_1.get_default_gorup(user_id) is not null order by \
		user_id desc'
	dfObj.createSQLResultDataframe(query, dBCon)
	
	return dfObj
		
#---------------------------------------
def computeDuration(dfRow, endTime, startTime = None, deltaFormat = None):
		duration = None
		if startTime is None:
			deltaDt = datetime.today() - datetime.strptime(endTime ,"%Y-%m-%d %H:%M:%S")
		else:
			deltaDt = datetime.strptime(startTime ,"%Y-%m-%d %H:%M:%S") - datetime.strptime(endTime ,"%Y-%m-%d %H:%M:%S")
		
		if deltaFormat is None:
			duration = strfdelta(deltaDt, "{days} days {hours}:{minutes}")
		else:
			duration = strfdelta(deltaDt, deltaFormat)
			
		return duration
		
#---------------------------------------	
def get_groupnames_or_username(IdList, sdmGrps, sdmUsrDefGrp):
	group = ''
	groupIds = IdList.split(';')
	for id in groupIds:
		resultDf = sdmGrps[(sdmGrps['GROUP_ID']== int(id))]
		
		if not resultDf.empty:
			for i, row in resultDf.iterrows():
				group = group + row['GROUPNAME']
				break
		else:
			resultDf = sdmUsrDefGrp[(sdmUsrDefGrp['USER_ID']== int(id))]
			if not resultDf.empty:
				for i, row in resultDf.iterrows():
					group = group + row['FULLNAME']
					break
				
		if len(group) > 0:
			group = group + ';'
			
	if len(group) > 0:
		group = group[0:-1]
		
	return group

#---------------------------------------	
def get_user_defaultgroup(user, sdmUsrDefGrp):
	resultDf = sdmUsrDefGrp[(sdmUsrDefGrp['FULLNAME']==user)]
	group = 'NA'
	if not resultDf.empty:
		for i, row in resultDf.iterrows():
			group = row['user_default_group']
			break
	else:
		resultDf = sdmUsrDefGrp[(sdmUsrDefGrp['user_default_group']==user)]
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
def SendFile(localFilename, remoteFilename, remoteServerDir):
	remoteFilename = remoteFilename + time.strftime("%Y%m%d") + ".csv"
	SERVER_DIR = remoteServerDir
	SERVER_ADDRESS = ['10.150.20.104']
	SERVER_UNAME = 'smbtcm'
	SERVER_PSWD = 'P@ssw0rd'
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
	print("SDM AD HOC SDT TICKETS")
	print("-------------------------")
	
	main()
	
	endTime = datetime.now()
	deltaDt = endTime - starTime
	print(deltaDt)
	print("<<<<< End of Script >>>>>")
