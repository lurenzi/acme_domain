


#证书申请:bash acme_domain.sh + 域名
#!/bin/bash
#获取域名
if [ -z "$1" ];then
	echo "请输入需要申请证书的域名：(bash acme_domain.sh 域名)"
	exit
fi
domainName="$1"
#安装基础软件
apt install socat -y
#域名证书申请
chmod -R 777 /root
#下载acme脚本
curl https://get.acme.sh | sh -s email=$(date +%s%N | md5sum | cut -c 1-16)@gmail.com
source ~/.bashrc
#升级
bash ~/.acme.sh/acme.sh --upgrade --auto-upgrade
#申请证书的网站改为letsencrypt
bash ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
#证书申请
bash ~/.acme.sh/acme.sh --issue -d ${domainName} --standalone -k ec-256 --insecure
#域名证书路径
mkdir /root/ssl/
bash ~/.acme.sh/acme.sh --install-cert -d ${domainName} --key-file /root/ssl/private.key --fullchain-file /root/ssl/cert.crt --ecc
#定时执行脚本
sed -i '/--cron/d' /etc/crontab >/dev/null 2>&1
echo "0 0 * * * root bash /root/.acme.sh/acme.sh --cron -f >/dev/null 2>&1" >> /etc/crontab

echo "域名：$domainName" >> /root/infomation.log
echo "公钥：/root/ssl/cert.crt" >> /root/infomation.log
echo "私钥：/root/ssl/private.crt" >> /root/infomation.log
echo "证书信息存储：/root/infomation.log"
