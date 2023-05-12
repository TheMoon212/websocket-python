#!/bin/bash
# SlowDNS
# Creator : hideSSH
# Date : 2022 -01
# ==========================================
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
clear

# Getting
IP=$(wget -qO- ipinfo.io/ip);
echo "Checking VPS"
# Download File Ohp

apt install jq -y
DOMAIN=iphide.co
NS=ns
read -rp "Masukkan Subdomain: " -e sub
SUB_DOMAIN=${sub}.${DOMAIN}
NS_DOMAIN=${NS}${sub}.${DOMAIN}
CF_ID=dedi4susanto@gmail.com
CF_KEY=c039ad263788426c377f0052295bfabb7980a
set -euo pipefail
IP=$(wget -qO- ipinfo.io/ip);
echo "Pointing DNS Untuk Domain ${SUB_DOMAIN}..."
echo "Pointing DNS Untuk Domain ${NS_DOMAIN}..."
ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)

RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${SUB_DOMAIN}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)

#create DNS A Recond
if [[ "${#RECORD}" -le 10 ]]; then
     RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}' | jq -r .result.id)
fi

RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}')

#create DNS NS Recond     
if [[ "${#RECORD}" -le 10 ]]; then
     RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${SUB_DOMAIN}'","ttl":120,"proxied":false}' | jq -r .result.id)
fi

RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${SUB_DOMAIN}'","ttl":120,"proxied":false}')
echo "Host : $SUB_DOMAIN"
echo "NS : $NS_DOMAIN"

NS2="s/dddddddd/$NS_DOMAIN/g";

#cd /var/lib/
#mkdir premium-script
#echo "IP=$SUB_DOMAIN" >> /var/lib/premium-script/ipvps.conf
#echo "NS=$NS_DOMAIN" >> /var/lib/premium-script/ipvps.conf

clear

cd
#install golang
apt-get install golang-go -y

# Download File Ohp
wget https://github.com/Mygod/dnstt/archive/refs/heads/plugin.zip
unzip plugin.zip
chmod +x dnstt-plugin
cp -r dnstt-plugin /usr/local/bin/dnstt-plugin
cd /usr/local/bin/dnstt-plugin/dnstt-server
go build
./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub

#izin firewall
apt install iptables-persistent -y
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
#iptables -I INPUT -p udp --dport 53 -j ACCEPT

iptables -t nat -I PREROUTING -i eth0 -p udp --dport 53 -j REDIRECT --to-ports 5300
#ip6tables -I INPUT -p udp --dport 5300 -j ACCEPT
#ip6tables -t nat -I PREROUTING -i eth0 -p udp --dport 53 -j REDIRECT --to-ports 5300
netfilter-persistent save
netfilter-persistent reload

#run slowdns OpenSSH
 #./dnstt-server -udp :5300 -privkey-file server.key t.example.com 127.0.0.1:22

 # Installing Service
# SSH OHP Port 8181 OpenSSH
#cat > /etc/systemd/system/slowdns.service << END
wget -O /etc/systemd/system/slowdns.service https://gitlab.com/hidessh/baru/-/raw/main/slowdns.service 
sed -i $NS2 /etc/systemd/system/slowdns.service
chmod +x /etc/systemd/system/slowdns.service
#restart service
systemctl daemon-reload
systemctl enable slowdns.service
systemctl restart slowdns.service

clear

