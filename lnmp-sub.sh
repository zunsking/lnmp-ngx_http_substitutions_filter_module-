#!/bin/bash
############### Debian install lnmp and add ngx_http_substitutions_filter_module ###############
#Author:https://github.com/zunsking
####################### END #######################
apt update && apt upgrade -y
##
apt-get install wget zip unzip git -y
cd /usr/local
git clone git://github.com/FRiCKLE/ngx_cache_purge.git
git clone git://github.com/yaoweibin/ngx_http_substitutions_filter_module
git clone git://github.com/openresty/headers-more-nginx-module.git
cd
wget https://raw.githubusercontent.com/zunsking/lnmp-add-module/master/bakup/backup.sh
#wget https://raw.githubusercontent.com/zunsking/lnmp-add-module/master/fail2ban.sh
wget http://soft.vpser.net/lnmp/lnmp1.8.tar.gz -cO lnmp1.8.tar.gz && tar zxf lnmp1.8.tar.gz
cd lnmp1.8/tools
sed -i 's#maxretry = 5#maxretry = 2#g' fail2ban.sh
cd ..
sed -i "s:Nginx_Modules_Options='':Nginx_Modules_Options='--add-module=/usr/local/ngx_http_substitutions_filter_module --add-module=/usr/local/ngx_cache_purge --add-module=/usr/local/headers-more-nginx-module':" lnmp.conf
#./install.sh lnmp
chmod +x *.sh
echo "Choose install:"
echo ""
echo " 1: Install full LNMP"
echo " 2: Install full LAMP"
echo " 3: Install full LNMPA"
echo " 4: Only install Nginx"
echo " 5: Only install DB"
echo ""
read -p "(Directly Enter to cancel), Enter 1 or 2,3,4,5:" install
if [[ '1' = "$install" ]]; then
    eval "./install.sh lnmp"
elif [[ '2' = "$install" ]]; then
    eval "./install.sh lamp"
elif [[ '3' = "$install" ]]; then
    eval "./install.sh lnmpa"
elif [[ '4' = "$install" ]]; then
    eval "./install.sh nginx"
elif [[ '5' = "$install" ]]; then
    eval "./install.sh db"
else
    echo "Install canceled."
    exit
fi
#Install fail2ban
echo "Install fail2ban..."
cd tools
. fail2ban.sh
sleep 3s
cd
#ufw
echo "Install ufw..."
apt install ufw -y
#Default set: deny all IN and allow all OUT
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80
#Enable ufw
ufw --force enable
#Status checking
ufw status verbose
#crontab
rM=$(($RANDOM%60))
rH=$(($RANDOM%12))
echo '#/etc/init.d/cron restart' >> /var/spool/cron/crontabs/root
echo $[rM] $[rH]  "* * * reboot" >> /var/spool/cron/crontabs/root && /etc/init.d/cron restart
#deny ip:80
echo "deny ip:80..."
sed -i "s:server_name _;:server_name _;\n return 444;:" /usr/local/nginx/conf/nginx.conf
lnmp nginx restart
rm -rf *
