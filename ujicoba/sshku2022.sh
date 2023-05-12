#!/bin/sh
#script auto installer SSH + SSLH
#created bye HideSSH.com and Kumpulanremaja.com
#OS Debian 9
apt-get update && apt-get upgrade -y
apt-get install wget curl -y

# initializing var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";

# detail nama perusahaan
country=ID
state=Semarang
locality=JawaTengah
organization=hidessh
organizationalunit=HideSSH
commonname=hidessh.com
email=admin@hidessh.com

cd
# set time GMT +7 jakarta
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale SSH
cd
sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 88' /etc/ssh/sshd_config
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
/etc/init.d/ssh restart

cd
# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Ubah izin akses
chmod +x /etc/rc.local

cd
# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# instal php5.6 ubuntu 16.04 64bit
apt-get -y update

cd
# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

#package tambahan
echo "================  install Package Tambahan Penting Lain nya ======================"
apt-get -y install gcc
apt-get -y install make
apt-get -y install cmake
apt-get -y install git
apt-get -y install wget
apt-get -y install screen
apt-get -y install unzip
apt-get -y install curl
apt-get -y install unrar
apt-get -y install dnsutils net-tools tcpdump grepcidr
apt-get install dsniff -y

echo "================  install Dropbear ======================"
echo "========================================================="

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=44/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 77 "/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/ssh restart
/etc/init.d/dropbear restart


# install squid
cd
apt -y install squid3
wget -O /etc/squid/squid.conf "https://gitlab.com/hidessh/baru/-/raw/main/squid.conf"
sed -i $MYIP2 /etc/squid/squid.conf
/etc/init.d/squid restart
echo "=================  install stunnel  ====================="
echo "========================================================="

# install stunnel
apt-get install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
[sslopenssh]
accept = 222
connect = 127.0.0.1:22
[ssldropbear]
accept = 443
connect = 127.0.0.1:44
[ssldropbear]
accept = 777
connect = 127.0.0.1:77

END

echo "=================  membuat Sertifikat OpenSSL ======================"
echo "========================================================="
#membuat sertifikat
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

# konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

cd
# simple password minimal
wget -O /etc/pam.d/common-password "https://gitlab.com/hidessh/baru/-/raw/main/password"
chmod +x /etc/pam.d/common-password


# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://gitlab.com/hidessh/baru/-/raw/main/badvpn-udpgw64"
chmod +x /usr/bin/badvpn-udpgw
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500' /etc/rc.local
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500

cd
# Custom Banner SSH
echo "================  Banner ======================"
wget -O /etc/issue.net "https://gitlab.com/hidessh/baru/-/raw/main/banner.conf"
chmod +x /etc/issue.net

echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
echo "DROPBEAR_BANNER="/etc/issue.net"" >> /etc/default/dropbear

# install fail2ban
apt-get -y install fail2ban
service fail2ban restart

cd


# download script
cd /usr/bin
wget -O add-host "https://gitlab.com/hidessh/baru/-/raw/main/add-host1"
wget -O about "https://gitlab.com/hidessh/baru/-/raw/main/about.sh"
wget -O menu "https://gitlab.com/hidessh/baru/-/raw/main/menu.sh"
wget -O usernew "https://gitlab.com/hidessh/baru/-/raw/main/usernew.sh"
wget -O trial "https://gitlab.com/hidessh/baru/-/raw/main/trial.sh"
wget -O hapus "https://gitlab.com/hidessh/baru/-/raw/main/hapus.sh"
wget -O member "https://gitlab.com/hidessh/baru/-/raw/main/member.sh"
wget -O delete "https://gitlab.com/hidessh/baru/-/raw/main/delete.sh"
wget -O cek "https://gitlab.com/hidessh/baru/-/raw/main/cek.sh"
wget -O restart "https://gitlab.com/hidessh/baru/-/raw/main/restart.sh"
wget -O speedtest "https://gitlab.com/hidessh/baru/-/raw/main/speedtest_cli.py"
wget -O info "https://gitlab.com/hidessh/baru/-/raw/main/info.sh"
wget -O ram "https://gitlab.com/hidessh/baru/-/raw/main/ram.sh"
wget -O renew "https://gitlab.com/hidessh/baru/-/raw/main/renew.sh"
wget -O autokill "https://gitlab.com/hidessh/baru/-/raw/main/autokill.sh"
wget -O ceklim "https://gitlab.com/hidessh/baru/-/raw/main/ceklim.sh"
wget -O tendang "https://gitlab.com/hidessh/baru/-/raw/main/tendang.sh"
wget -O clear-log "https://gitlab.com/hidessh/baru/-/raw/main/clear-log.sh"
wget -O change-port "https://gitlab.com/hidessh/baru/-/raw/main/change.sh"
wget -O port-ovpn "https://gitlab.com/hidessh/baru/-/raw/main/port-ovpn.sh"
wget -O port-ssl "https://gitlab.com/hidessh/baru/-/raw/main/port-ssl.sh"
wget -O port-wg "https://gitlab.com/hidessh/baru/-/raw/main/port-wg.sh"
wget -O port-tr "https://gitlab.com/hidessh/baru/-/raw/main/port-tr.sh"
wget -O port-sstp "https://gitlab.com/hidessh/baru/-/raw/main/port-sstp.sh"
wget -O port-squid "https://gitlab.com/hidessh/baru/-/raw/main/port-squid.sh"
wget -O port-ws "https://gitlab.com/hidessh/baru/-/raw/main/port-ws.sh"
wget -O port-vless "https://gitlab.com/hidessh/baru/-/raw/main/port-vless.sh"
wget -O wbmn "https://gitlab.com/hidessh/baru/-/raw/main/webmin.sh"
wget -O xp "https://gitlab.com/hidessh/baru/-/raw/main/xp.sh"
wget -O update "https://gitlab.com/hidessh/baru/-/raw/main/update.sh"
wget -O user-limit "https://gitlab.com/hidessh/baru/-/raw/main/user-limit.sh"
wget -O cfd "https://gitlab.com/hidessh/baru/-/raw/main/cfd.sh"
wget -O cff "https://gitlab.com/hidessh/baru/-/raw/main/cff.sh"
wget -O cfh "https://gitlab.com/hidessh/baru/-/raw/main/cfh.sh"
#tambahan baru
wget -O userdelexpired "https://gitlab.com/hidessh/baru/-/raw/main/userdelexpired.sh"
wget -O autoreboot "https://gitlab.com/hidessh/baru/-/raw/main/autoreboot.sh"
wget -O autoservice "https://gitlab.com/hidessh/baru/-/raw/main/autoservice.sh"


#permission
chmod +x autoservice
chmod +x userdelexpired
chmod +x user-limit
chmod +x add-host
chmod +x menu
chmod +x usernew
chmod +x trial
chmod +x hapus
chmod +x member
chmod +x delete
chmod +x cek
chmod +x restart
chmod +x speedtest
chmod +x info
chmod +x about
chmod +x autokill
chmod +x tendang
chmod +x ceklim
chmod +x ram
chmod +x renew
chmod +x clear-log
chmod +x change-port
chmod +x port-ovpn
chmod +x port-ssl
chmod +x port-wg
chmod +x port-sstp
chmod +x port-tr
chmod +x port-squid
chmod +x port-ws
chmod +x port-vless
chmod +x wbmn
chmod +x xp
chmod +x update
chmod +x cfd
chmod +x cff
chmod +x cfh
chmod +x autoreboot

#auto reboot cronjob
echo "0 5 * * * root clear-log && reboot" >> /etc/crontab
echo "0 17 * * * root clear-log && reboot" >> /etc/crontab
echo "50 * * * * root userdelexpired" >> /etc/crontab
echo "5 * * * * root autoservice" >> /etc/crontab

# finishing
cd
chown -R www-data:www-data /home/vps/public_html
/etc/init.d/nginx restart
/etc/init.d/openvpn restart
/etc/init.d/cron restart
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/fail2ban restart
/etc/init.d/stunnel4 restart
/etc/init.d/squid restart

screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500

history -c
echo "unset HISTFILE" >> /etc/profile

#hapus file instalasi
cd
rm -f /root/key.pem
rm -f /root/cert.pem
rm -f /root/ssh-vpn.sh
rm -f /root/ihide
rm -rf /root/vpnku.sh

#tambahan package nettools
cd
apt-get install dnsutils jq -y
apt-get install net-tools -y
apt-get install tcpdump -y
apt-get install dsniff -y
apt-get install grepcidr -y

# remove unnecessary files
cd
apt autoclean -y
apt -y remove --purge unscd
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove bind9*;
apt-get -y remove sendmail*
apt autoremove -y

# finihsing
clear
add-host