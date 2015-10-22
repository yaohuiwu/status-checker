#!/bin/bash
# A shell script that controll the process of cluster status checking.
# (1)Please note the format of file cluster.ini must like this:
#
# 192.168.10.164   HBase-pcp
# 192.168.10.165  HBase-pcp-165
# 192.168.10.166   HBase-pcp-166
#
# (2)First line is the master
#
# scp, ssh and python must be supported.

if [ $# -lt 1 ];then
	echo "usage: status_check.sh <cluster.ini>"
	exit 1
fi
cfg=$1
if [ ! -e $cfg ];then
	echo "file $cfg not exists."
	exit 1
fi

MASTER=`head -1 $cfg | awk '{print $2}'`
COP_JAR='coprocessor-1.0-SNAPSHOT.jar'

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
	ssh -o ConnectTimeout=5 -q $1 $2 < /dev/null
}

check_hosts(){
        #get remote hosts file to local
        destFile="${1}.hosts"
        #scp -o ConnectTimeout=5 -q "${1}:/etc/hosts" $destFile
	load_file_r ${1} '/etc/hosts' $destFile
        if [ -e $f ];then
                python cmphost.py $2 $destFile
                rm -rf $destFile
        else
                echo "can't get hosts file from $1"
        fi
}

check_time_sync(){
	lclTime=`date +%s`
	# redirect ssh input to /dev/null, not disturbe the while loop
	rmTime=`ssh ${1}  'date +%s' < /dev/null`
	behind=0
	let 'behind = lclTime - rmTime'
	behind=${behind#-}
	echo "TIME:$behind seconds different with the $MASTER."
	if [ $behind -gt 30 ];then
		echo "ERROR: the max allowed diffence of time between cluster members is 30 seconds. 
	change time of ${1} manaully or use ntp."
	fi
}

check_coprocessor(){
	#load hbase-site.xml
	siteFile="hbase-site.xml"
	load_file_r $1 "$HBASE_HOME/conf/$siteFile" $siteFile
	
	if [ -e $siteFile  ];then
		python checkCoprocessor.py $siteFile
	fi

	#clean up
	if [ -e $siteFile  ];then
		rm -f $siteFile
	fi
	
	coprocessor_jar=`ssh $1 "cd $SOFT_HOME/lib/; ls $COP_JAR" < /dev/null`
	#echo $coprocessor_jar
	if [ $COP_JAR ==  $coprocessor_jar ];then
		echo "find $coprocessor_jar"			
	else
		echo "no $COP_JAR find at $SOFT_HOME/lib"
	fi
}


hdfs_ls(){
	$HADOOP_HOME/bin/hadoop fs -ls $1 
}

check_hadoop(){
	echo '=========checking hadoop======'
	if [ -n $HADOOP_HOME ];then
		echo $HADOOP_HOME
	fi

	hdfs_ls '/'
	if [ $? -ne 0  ];then
		echo 'ERROR: hadoop not ok'
		return 0
	else
		echo 'HADOOP: ok'
	fi
	#echo "try uploading $0 to hdfs..."
	#$HADOOP_HOME/bin/hadoop fs -put $0 '/'

}

#need env HBASE_HOME
check_hbase(){
	echo '=========checking hbase========'
	test -n "$HBASE_HOME" || {
	    echo >&2 'The environment variable HBASE_HOME must be set.'
	    return 0
	}

	test -d "$HBASE_HOME" || {
	    echo >&2 "No such direcory: HBASE_HOME=$HBASE_HOME"
	    return 0 
	}

	exec "$HBASE_HOME/bin/hbase" shell <<EOF
	status 
	list
EOF
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

echo "Checking status of hbase cluster[MASTER:$MASTER]."

#the main process
while read LINE
do
	host=`echo $LINE | awk '{print $2}'`
	echo "===checking host $host==="

	check_hosts $host $cfg
	if [ $host != $MASTER ];then
		check_time_sync $host	
	fi
	check_coprocessor $host
	echo ''
	
done < $cfg

check_hadoop
check_hbase


echo 'done.'
