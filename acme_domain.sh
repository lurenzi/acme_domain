#!/bin/bash
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
#获取IP
ip=$(curl -s4m8 ip.sb -k)
#获取域名
read -p "请输入需要申请证书的域名：" domainName
[[ -z $domainName ]] && red "未输入域名！" && exit 1
green "已输入的域名：$domainName" && sleep 1

domainIP=$(curl -sm8 ipget.net/?ip="${domainName}")

if [[ $domainIP == $ip ]]; then
    #安装基础软件
    apt update -y && apt install -y curl socat
    #域名证书申请
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
    echo -n '#!/bin/bash
             /etc/init.d/nginx stop
             "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
             /etc/init.d/nginx start
            ' > /usr/local/bin/ssl_renew.sh
    chmod +x /usr/local/bin/ssl_renew.sh
    (crontab -l;echo "0 0 15 * * /usr/local/bin/ssl_renew.sh") | crontab
    echo "域名：$domainName" >> /root/infomation.log
    echo "公钥：/root/ssl/cert.crt" >> /root/infomation.log
    echo "私钥：/root/ssl/private.key" >> /root/infomation.log
    echo "证书信息存储：/root/infomation.log"
else
    red "域名当前VPS使用的真实IP不匹配"
    yellow "1. 请检查CloudFlare小云朵是否为关闭状态(仅限DNS)"
    yellow "2. 请检查DNS解析域名的IP是否为VPS的真实IP"
    exit 1
fi



