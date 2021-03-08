file="/var/log/sa/sa$(date +%d -d yesterday)"
sar_date=$(sar -f $file | head -n 1 | awk '{print $4}')

cpu_avg=$(sar -u -f $file | awk '/Average:/{ total += $8; count++ } END {printf 100 - (total/count)}')

#kbmemused - kbbuffers - kbcached / (kbmemfree + kbmemused)
mem_avg=$(sar -r -f $file | awk '/Average:/{printf("%.2f\n"),(($3-$5-$6)/($2+$3)) * 100 }')

#Create Daily Stat Folder if not exist
if [ ! -d "/var/log/sa/daily_stat/$(date +%Y%m)" ]
then
        mkdir -p /var/log/sa/daily_stat/$(date +%Y%m)
fi

echo $sar_date , $cpu_avg >> /var/log/sa/cpu_avg_$(date +%Y%m -d yesterday).csv
echo $sar_date , $mem_avg >> /var/log/sa/mem_avg_$(date +%Y%m -d yesterday).csv
df -h > /home/admin/script/disk_$(date +%Y%m -d yesterday).csv

sar -u -f $file > /var/log/sa/daily_stat/$(date +%Y%m -d yesterday)/$(date +%Y%m%d -d yesterday)_cpu.txt
sar -r -f $file > /var/log/sa/daily_stat/$(date +%Y%m -d yesterday)/$(date +%Y%m%d -d yesterday)_mem.txt

#Logging
cpu_no_of_row=$(wc -l < /var/log/sa/cpu_avg_$(date +%Y%m -d yesterday).csv)
mem_no_of_row=$(wc -l < /var/log/sa/mem_avg_$(date +%Y%m -d yesterday).csv)

date_of_compare=$(date +%d -d yesterday)
timestamp=$(date +'%Y-%m-%d %T')
if [ $cpu_no_of_row == $date_of_compare ]
then
        echo "$timestamp Normal. cpu_avg got $cpu_no_of_row Rows data." >> /var/log/sa/sar-avg.log
else
        echo "$timestamp Please Check!!! cpu_avg got $cpu_no_of_row Rows data. Some Data may be missing" >> /var/log/sa/sar-avg.log
fi

if [ $mem_no_of_row == $date_of_compare ]
then
        echo "$timestamp Normal. mem_avg got $mem_no_of_row Rows data." >> /var/log/sa/sar-avg.log
else
        echo "$timestamp Please Check!!! mem_avg got $mem_no_of_row Rows data. Some Data may be missing" >> /var/log/sa/sar-avg.log
fi
