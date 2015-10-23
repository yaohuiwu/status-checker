How to run a status check?
=========================

+ create your cluster config file like cluster.ini, for example, mycluster.ini:
	
		192.168.9.19 master
		192.168.9.20 slave0
		192.168.9.23 slave1 

   please note that first line of mycluster should be the master.

+ add coprocessors and tables you want to check in config.ini.

+ run the following command in status-checker directory on master host:
	
		./status-checker.sh mycluster.ini

