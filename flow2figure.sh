#!/usr/bin/bash

if [[ $# != 4 ]]; then
    echo "must provide IPs"
    exit 1
fi

ontA=$1
ontB=$2
server_ip=$3
file_name=$4

conf_file=/pcap2uml/conf/conf_uml.py

lockdir=/var/tmp/mylock
pidfile=/var/tmp/mylock/pid

function do_job
{
    cp -f /pcap2uml/conf/conf_uml_template.py ${conf_file}
    sed  -i "s/place_holder_ontA_ip/${ontA}/" ${conf_file}
    sed  -i "s/place_holder_ontB_ip/${ontB}/" ${conf_file}
    sed  -i "s/place_holder_sipserver_ip/${server_ip}/" ${conf_file}

    rm -fr /pcap2uml/output/*

    /pcap2uml/pcap2uml.py -i /pcap2uml/input/${file_name}.pcap -o /pcap2uml/output/${file_name}.uml -t png

}


i=1
wait_retry_before_exit=5
while [[ $i -lt ${wait_retry_before_exit} ]]; do
    if ( mkdir ${lockdir} ) 2> /dev/null; then
        echo $$ > $pidfile
        trap 'rm -rf "$lockdir"; exit $?' INT TERM EXIT
        do_job
        rm -rf "$lockdir" $pidfile
        trap - INT TERM EXIT
        exit 0
    else
      echo "Lock Exists: $lockdir owned by $(cat $pidfile)"
      sleep 5
      let "i+=1"
    fi
done

exit 1
