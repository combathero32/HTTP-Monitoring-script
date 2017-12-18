#!/bin/bash

ctr=1
unreachable=0

for i in $(cat /etc/devicemonitor/devHTTPlist | xargs)
do
        status=$(curl http://$i -m 5 -s -f -o /dev/null && echo "SUCCESS" || echo "UNREACHABLE")
        if [ $ctr -eq 1 ]; then
                echo "$ctr. $i - $status" > /etc/devicemonitor/results.txt
        else
                echo "$ctr. $i - $status" >> /etc/devicemonitor/results.txt
        fi
        if [ "$status" = "UNREACHABLE" ]; then
                unreachable=$((unreachable + 1))
        fi

        ctr=$((ctr + 1))
done

if [ $unreachable -gt 0 ]; then
        d=$(date)
        echo "To:email@email.com" > /etc/devicemonitor/smtpmsg.txt
        echo "From:email@email.com" >> /etc/devicemonitor/smtpmsg.txt
        echo "Subject:Cron Alert (notification: Devices Unreachable) $d" >> /etc/devicemonitor/smtpmsg.txt
        echo "" >> /etc/devicemonitor/smtpmsg.txt
        uptime >> /etc/devicemonitor/smtpmsg.txt
        echo "" >> /etc/devicemonitor/smtpmsg.txt

        cat /etc/devicemonitor/smtpmsg.txt /etc/devicemonitor/results.txt > /etc/devicemonitor/msgfinal.txt

        ssmtp email@email.com < /etc/devicemonitor/msgfinal.txt
fi
