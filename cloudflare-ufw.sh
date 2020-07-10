#!/usr/bin/env bash

IFS=$'\n'

# Remove exsisting rules
while true; do
        i=$(sudo ufw status numbered | grep -m1 'Cloudflare IP' | awk -F"[][]" '{print $2}')
        if ! [ -z "$i" ]; then
                echo "removing cloudflare rule"
                sudo ufw --force delete $i
        else
                break
        fi
done

# Add new rules

curl -s https://www.cloudflare.com/ips-v4 -o /tmp/cf_ips
curl -s https://www.cloudflare.com/ips-v6 >> /tmp/cf_ips

# Allow all traffic from Cloudflare IPs (no ports restriction)
while read line;
do ufw allow proto tcp from $line to any port 443 comment 'Cloudflare IP' && ufw allow proto tcp from $line to any port 80 comment 'Cloudflare IP';
done < /tmp/cf_ips

ufw reload > /dev/null
