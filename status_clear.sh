#!/bin/bash

# A script to kill hadoop and hbase process, recreate hdfs directory and
# remove all temporary directory of hadoop and hbase.

if [ $# -lt 1 ];then
	echo "usage: status_clean.sh <cluster.ini>"
	exit 1
fi
cfg=$1
if [ ! -e $cfg ];then
	echo "file $cfg not exists."
	exit 1
fi

# pre precess : remove all empty or blank lines
sed -i '/^\s*$/d' $cfg 

MASTER=`head -1 $cfg | awk '{print $2}'`

#get file from remote host via scp
load_file_r(){
	# $1 remote host
	# $2 remote file name
	# $3 local file name
	if [ -e $3  ];then
		rm -f $3
	fi
	scp -o ConnectTimeout=5 -q "${1}:$2" $3
}

command_r(){
	# $1 remote host
	# $2 command to execute
	ssh -o ConnectTimeout=5 $1 $2 < /dev/null
}


# requirement checking
if [ -z `which python`  ];then
	echo 'python required.'
	exit 1
fi
if [ -z `which ssh` ];then
	echo 'ssh required.'
	exit 1
fi
if [ -z `which scp` ];then
	echo 'scp required.'
	exit 1
fi

echo "Cleaning status of hbase cluster[MASTER:$MASTER]."

#the main process
while read LINE
do
	host=`echo $LINE | awk '{print $2}'`
	echo "===Cleaning host $host==="

	hps='hps.txt'
	command_r $host "$JAVA_HOME/bin/jps | awk  '{ if( \$2 !~ /Jps/) print \$1}'" > $hps
	hps_list=`python columns_to_string.py $hps 0`
	if [ -n "$hps_list" ];then
		echo "killing process: $hps_list"
		command_r $host "kill -9 $hps_list"
	fi

	echo "recreating hdfs directory.."
	hdfs_d="~/hdfs"
	remk_d="${hdfs_d}/name"
	if [ "$MASTER" != "$host" ];then
		remk_d="${hdfs_d}/data"
	fi
	command_r $host "rm -rf $hdfs_d; mkdir -p $remk_d; ls -l $hdfs_d;"

	echo "deleting temporary directory.."

	htmps='htmps.txt'
	command_r $host 'ls /tmp/ | egrep "(hadoop-|hbase-|Jetty)"' > $htmps
	
	htmp_files=`python columns_to_string.py $htmps 0`
	if [ -n "$htmp_files" ];then
		echo "deleting files :$htmp_files"
		command_r $host "cd /tmp; rm -rf $htmp_files ; ls"
	fi

	rm -rf $hps
	rm -rf $htmps

	echo ''
	
done < $cfg


echo 'done.'
