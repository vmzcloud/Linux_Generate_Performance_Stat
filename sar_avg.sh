file="/var/log/sa/sa$(date +%d -d yesterday)"
sar_date=$(sar -f $file | head -n 1 | awk '{print $4}')

cpu_avg=$(sar -u -f $file | awk '/Average:/{printf 100 - $8}')

#kbmemused - kbbuffers - kbcached / (kbmemfree + kbmemused)
mem_avg=$(sar -r -f $file | awk '/Average:/{printf("%.2f\n"),(($3-$5-$6)/($2+$3)) * 100 }')

#Create Daily Stat Folder if not exist
if [ ! -d "/var/log/sa/daily_stat/$(date +%Y%m)" ]
then
        mkdir -p /var/log/sa/daily_stat/$(date +%Y%m)
fi

#if first date of month, generate the data to the last month file
if [ $(date +%d) = "01" ]
then
        echo $sar_date , $cpu_avg >> /var/log/sa/cpu_avg_$(date +%Y%m -d yesterday).csv
        echo $sar_date , $mem_avg >> /var/log/sa/mem_avg_$(date +%Y%m -d yesterday).csv
        df -h > /home/admin/script/disk_$(date +%Y%m -d yesterday).csv

        sar -u -f $file > /var/log/sa/daily_stat/$(date +%Y%m -d yesterday)/$(date +%Y%m%d -d yesterday)_cpu.txt
        sar -r -f $file > /var/log/sa/daily_stat/$(date +%Y%m -d yesterday)/$(date +%Y%m%d -d yesterday)_mem.txt
else
        echo $sar_date , $cpu_avg >> /var/log/sa/cpu_avg_$(date +%Y%m).csv
        echo $sar_date , $mem_avg >> /var/log/sa/mem_avg_$(date +%Y%m).csv

        sar -u -f $file > /var/log/sa/daily_stat/$(date +%Y%m)/$(date +%Y%m%d -d yesterday)_cpu.txt
        sar -r -f $file > /var/log/sa/daily_stat/$(date +%Y%m)/$(date +%Y%m%d -d yesterday)_mem.txt
fi
