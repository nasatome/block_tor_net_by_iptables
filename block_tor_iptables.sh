#!/bin/bash

#trap "set +x; sleep 3; set -x" DEBUG

if [ "$1" == "" ]; then
    echo "example: $0 [interface] [port [port2] [portN]]"
    exit 1
fi

if [ "$2" == "" ]; then
    echo "example: $0 [interface] [port [port2] [portN]]"
    exit 1
fi

if [ "$USER" != "root" ]; then
    echo "Must be root user  (you are $USER)."
    exit 1
fi

echo "Init script $(date)"

IP_TOR_LIST="/tmp/tor_ip_node_exit_list"
UFW_STATUS="/tmp/ufw_status_string"


IP_ADDRESS=$(dig +short myip.opendns.com @resolver1.opendns.com)
if [ -z "$IP_ADDRESS" ]; then
    IP_ADDRESS=$(curl checkip.amazonaws.com)
    if [ -z "$IP_ADDRESS" ]; then
    echo "Error To Obtain IP Public Address"
        IP_ADDRESS=$(ifconfig $1 | awk '/inet addr/ {split ($2,A,":"); print A[2]}')
        if [ -z "$IP_ADDRESS" ]; then
            IP_ADDRESS=$(ifconfig $1 | grep "inet " | cut -d 't' -f 2 | cut -d ' ' -f 2)
            if [ -z "$IP_ADDRESS" ]; then
                echo "Error To Obtain IP Local Address"
                exit 1
            fi
        fi
    fi
fi

echo "Public IP--> $IP_ADDRESS"

rm -f ${IP_TOR_LIST}
touch ${IP_TOR_LIST}

#rm -f ${UFW_STATUS}
#touch ${UFW_STATUS}

echo $(ufw status) > ${UFW_STATUS}

if grep -qFe "Status: inactive" ${UFW_STATUS} ; then
   echo "Error UFW Inactive"
   exit 1
fi

for PORT in "$@"
do
    echo ${PORT};

    if [ "$1" == "$PORT" ]; then
    echo "$1 is equal to $PORT"
       continue
    fi

    re='^[0-9]+$';
    if ! [[ ${PORT} =~ $re ]]; then
        continue
    fi

    echo >> ${IP_TOR_LIST}
    wget -q -O - "https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=$IP_ADDRESS&port=$PORT" -U wget >> ${IP_TOR_LIST}

done

sed -i 's|^#.*$||g' ${IP_TOR_LIST}
sed -i '/^$/d' ${IP_TOR_LIST}

echo $(cat ${IP_TOR_LIST} | sort -u) > ${IP_TOR_LIST}

for IP in $(cat ${IP_TOR_LIST})
do
    if ! grep -qFe "Anywhere DENY $IP" "$UFW_STATUS" ;
        then
            echo "IP to Block--> $IP"
            ufw deny from ${IP} to any
        else
            echo "IP: $IP --> is found in UFW...skip"
    fi
done

echo "Finish script $(date)"

